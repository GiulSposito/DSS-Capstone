# "Library" of functions to perform the predictive analysis
# Giuliano Sposito (gsposito@gmail.com)
# Coursera Data Scrience Capstone Project
#
# To keep the code clean and readable the main code to create the analysis results
# was transformed in function do be called by a master script
#
# TO DO: would be nice to transform this in to a R Package
#
 
# dependencies
library(RTextTools) # the main lib for text mining
library(caret) # for data partition and confusion matrix
library(class) # for knn ML
library(e1071) # for naivesBayes ML
library(ggplot2) # to plot 

# constants for OUTPUT dir and filename
OUTPUT_DIR <- "./result/"
CM_FILENAME <- paste(OUTPUT_DIR, "cm.rdata", sep="")
SUMMARY_FILENAME <- paste(OUTPUT_DIR, "summary.rdata", sep="")
if (!file.exists(OUTPUT_DIR)) dir.create(OUTPUT_DIR)

# auxiliary function to create a C printf like function
printf <- function(...) invisible(print(sprintf(...)))

# auciliary function to generate a Unique Key based in the current timestamp
getTimeKey <- function() as.character(as.hexmode(round((as.numeric(Sys.time())-1440000000)*100)))

# save a comparation result to a dataframe file stored at output dir
# Receive a register that summarize the result of a ML analysis and 
# the Caret confusion matrix of the analisys
#
addResultsToDB <- function( summary, confusionMatrix ) {

  # creates a key to link simulation data to confusionMatrix (that will be stored appart)
  id <- getTimeKey()
  summary <- cbind(id,summary)
  
  # if the SUMMARY output file already exists, we load it. If not, creates new DataFrame
  if (!file.exists(SUMMARY_FILENAME)) {
    fitSummary <- summary
    names(summary)[1]<-"id"
  } else {
    load(SUMMARY_FILENAME)
    fitSummary <- rbind(fitSummary,summary)
  }
  
  # if the CONFUSION-MATRIX file already exists, we load it. If not, creates new DataFrame
  if (!file.exists(CM_FILENAME)) {
    fitCM <- list()
    fitCM[[id]] <- confusionMatrix
  } else {
    load(CM_FILENAME)
    fitCM[[id]] <- confusionMatrix
  }
  
  # save the dataframe structures
  save(fitSummary, file=SUMMARY_FILENAME)
  save(fitCM, file=CM_FILENAME)
  
  # free memory and return no value
  rm(fitSummary, fitCM)
  return()
  
}

# for each nParameter create one analysis
runMLComparations <- function(sizeParameters, algorithms, dataset, featureName, cycleName, levels, category)   
  apply(sizeParameters, 1, FUN=function(size, mla=algorithms, trainDS=dataset[["trainSet"]], testDS=dataset[["testSet"]], fLevels=levels, cat=category){
    
    # define the 'capable' size of training and testing samples
    train_sample_size <- min(size["train"],dim(trainDS)[1])
    test_sample_size <- min(size["test"],dim(testDS)[1])
    
    # subset the data by sampling following size especification
    train <- trainDS[sample(1:dim(trainDS)[1],train_sample_size),]
    test <- testDS[sample(1:dim(testDS)[1],test_sample_size),]
    
    # buildin the training and predicting matrixes (TDMs)
    t_tdm <- system.time( 
      trainMatrix <- create_matrix(train$text)
    )
    
    # creates a Document Term Matrix
    predMatrix <- create_matrix(test$text,originalMatrix=trainMatrix)
    
    # RTextTools ML containers
    traincontainer <- create_container(trainMatrix, train$y, trainSize=1:train_sample_size, virgin=F)
    predContainer <- create_container(predMatrix, test$y, testSize=1:test_sample_size, virgin=F)
    
    # loop on the ML Algorithms
    lapply(mla, FUN=function(alg, sampleSize=size, 
                             trainTDM = trainMatrix, trainCont=traincontainer, 
                             predTDM = predMatrix, predCont=predContainer,
                             trainY=train$y,validY= test$y, tdm.timer=t_tdm){
      
      #just log at console
      printf("Fitting %s with %d samples and %d terms",alg,sampleSize["train"],trainTDM[["ncol"]])
      
      # check what algorithm will be used
      if(alg %in% c("KNN","NAIVEBAYES")) {
        # specific ML fitting and evaluation
        if (alg=="KNN"){
          # KNN
          t_mod <- system.time(y_hat <- knn(as.matrix(trainTDM), as.matrix(predTDM), trainY))
          t_pred <- t_mod
        } else {
          #naiveBayes
          t_mod <- system.time(mod <- e1071::naiveBayes(as.matrix(trainTDM), trainY))
          t_pred <-system.time(y_hat <- predict(mod,as.matrix(predTDM)))
        }
      } else {
        # generic ML fitting and evaluation
        
        # fit and train
        t_mod <- system.time(
          mod <- train_model(container=trainCont, algorithm=alg, kernel="linear", cost=1)
        )
        
        # predict
        t_pred <- system.time(
          y_hat <- classify_model(predCont,mod)[[1]]
        )
      }
      
      #perform accuracy analysis
      cm <- confusionMatrix(y_hat,validY)
      
      # builds the loop result record
      result <- data.frame(
        feature.name = featureName,
        cycle.name = cycleName,
        business.category = cat,
        classification.levels = fLevels[["size"]],
        classification.names = fLevels[["names"]],
        train.sample.size = sampleSize["train"],
        test.sample.size =  sampleSize["test"],
        term.size = trainTDM[["ncol"]],
        algorithm = alg,
        time.tdm = tdm.timer[3],
        time.train = t_mod[3],
        time.pred = t_pred[3],
        accuracy = cm$overall["Accuracy"]
      )
      
      # store the results
      # saveModelFittingResult(result, cm, resultDit, cycleName)
      addResultsToDB(result,cm)
      
      # log on console
      printf("Accuracy: %f",cm$overall["Accuracy"])
      # free memory and return no value
      rm(mod, y_hat, cm, result)
      return(NULL)
    })
    
    # free memory and retunr no value
    rm(train, test, trainMatrix, predMatrix, traincontainer, predContainer)
    return()
  })


# function to plot a result set
plotAccuracyResults <- function(featureName, studyName, category=NULL, levels=NULL, algorithms=NULL) {
  
  # define the output file names
  load(file=SUMMARY_FILENAME)
  filter <- fitSummary$feature.name == featureName & fitSummary$cycle.name==studyName
  fitSummary <- fitSummary[filter,]
  
  # filter by algorithms
  if (!is.null(algorithms)) fitSummary <- fitSummary[fitSummary$algorithm%in%algorithms,]
  if (!is.null(category)) fitSummary <- fitSummary[fitSummary$business.category==category,]
  if (!is.null(levels)) fitSummary <- fitSummary[fitSummary$classification.levels==levels,]
  
  # plot accuracy by term.size grouped by algorithm
  g <- ggplot(data=fitSummary, aes(x=term.size, y=accuracy, group=algorithm, colour=algorithm)) 
  g <- g + geom_smooth(method="auto",se=F) + geom_point(aes(shape=algorithm), size=4) + theme_bw()
  g <- g + ggtitle(paste(featureName,studyName, sep="-"))
  
  return(g)
}

# function to prepare training and testing sets
#
getTrainingAndTestingDatasets <- function(reviews, featurename) {
  
  # separating training and validation datasets
  trainIdx <- createDataPartition(reviews[,featurename], p = 0.75, list=F)
  
  # datasets train and test datasets (Text Column, Predict Column)
  trainSet <- data.frame(text=reviews[trainIdx,]$text, y=reviews[trainIdx,featurename])
  testSet <- data.frame(text=reviews[-trainIdx,]$text, y=reviews[-trainIdx,featurename])
  
  trainSet$text <- as.character(trainSet$text)
  testSet$text <- as.character(testSet$text)
  trainSet$y <- as.factor(trainSet$y)
  testSet$y <- as.factor(testSet$y)
 
  return(list("trainSet"=trainSet,"testSet"=testSet))
}

# function to characterize the feature to be analyzed
characterizeFeature <- function(reviews,featurename) {
  s <- summary(reviews[,featurename])
  return(
      list(
        "size" = length(s),
        "factors" = names(s),
        "names" = paste(names(s), collapse=" | ")
      )
    )
}
# function to perform the analysis of a feature, with subcategory and removing 'unknown' levels
#
predictive_analysis <- function(feature, studyName, category=NULL, rm.unknown=FALSE, comparationSizes=NULL, algorithms=NULL) {
  
  # load dataset
  load("./data/business_review.rdata")
  
  # if there are a category, filters the dataset
  if(!is.null(category)) {
    business_review <- business_review[business_review$category==category,]
  } else {
    category <- "all"
  }
  
  # if the level 'unknown' should be excluded from dataset
  if(rm.unknown){
    business_review <- business_review[business_review[,feature]!="unknown",]
    business_review[,feature] <- as.factor(as.character(business_review[,feature]))
  }
  
  # caracterizes the feature that will be analysed (this info will be recorded with the results)
  featureLevels <- characterizeFeature(business_review,feature)
  
  # ballance the dataset to equal numbers of factors
#   ind <- ballanceDataset(business_review, business_review[,feature])
#   business_review <- business_review[ind,]
  
  # prepare dataset for analysis
  datasets <- getTrainingAndTestingDatasets(business_review,feature)
  
  # cleaning
  rm(business_review)
  
  # size parameters
  if(is.null(comparationSizes)){
    comparationSizes <- data.frame(
      train=c(10,50,100,500,1000,2000,3500,5000,7500,10000),
      test=rep(1000,10)
    )
  }
  
  # ML algorithms
  if (is.null(algorithms)) algorithms <- c("MAXENT", "SVM")
  
  # console log
  printf("Performing \'%s\' analisys of feature \'%s\' with category==\'%s\' and rm.unknown==\'%s\')", feature, studyName, category, rm.unknown)

  # perform study
  runMLComparations(comparationSizes, algorithms, datasets, feature, studyName, featureLevels, category)
  
  return()
}

# function that ballance a dataset returning the indexes to equals numbers of factors
ballanceDataset <- function(x,y){
  nr <- nrow(x)
  size <-  min(summary(y))
  idx <- lapply(split(seq_len(nr),y),function(.x)sample(.x,size))
  unlist(idx)
}
