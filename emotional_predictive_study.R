# This script will perform an emotional analisys of the review text
# We'll verify the accuracy and process time of different Machine Learning algorithms 
# in the context of Text Classification for diverse sample size

## On step setup ##########################################################
#
# trace("create_matrix",edit=T) 
# 
# If you get an error "Error in if (attr(weighting, "Acronym") == "tf-idf") weight <- 1e-09 : argument is of length zero"
# Please, look at: http://stackoverflow.com/questions/32513513/rtexttools-create-matrix-got-an-error
#
##########################################################################

# define de analysis functions
source("./predictive_analysis_lib.R")

# this study will try to predic the emotion of a review
# An emotion is defined by the number of stars of the review
# if the star is 1 or 2 the emotion is classified as 'negative'
# if the review has 4 or 5 stars, the emotion are classified as 'positive'
# 3 stars aren't classified
# this info is alread processed in the Business_Review merge as 'reviewEmotion' dataframe column

# study parameters
feature <- "reviewEmotion"              # feature name in the dataset
studyName <- "algorithm.selection"    # study name
businessCategory <- "Restaurants"       # we'll limit this study to Restaurants review only
rm_unknown <- TRUE                      # we'll remove intermediary classes

# sample sizes
sampleSizes <- data.frame(
  train=c(10,50,100,200,500), #,1000,2000,3000,5000,10000),
  test=rep(2000,5)
)

# algorithms
algs <- c("SVM", "MAXENT", "TREE", "RF", "KNN", "NAIVEBAYES")

# we perform this study three times
set.seed(19121975) #for reproducible research
for (i in 1:3) predictive_analysis(feature, studyName, businessCategory, rm_unknown, sampleSizes, algs) 

# we perform all algorithm one time for each size
sampleSizes <- data.frame(
  train=c(800,1000), #,1000,2000,3000,5000,10000),
  test=rep(2000,2)
)
predictive_analysis(feature, studyName, businessCategory, rm_unknown, sampleSizes, algs) 

# we remove KNN and NAIVEBAYES because the time to process and accuracy
algs <- c("SVM", "MAXENT")

# we perform all algorithm one time for each size
sampleSizes <- data.frame(
  train=c(900,1200,2500,4000,8000,15000),
  test=rep(2000,6)
)

set.seed(19121975) #for reproducible research
predictive_analysis(feature, studyName, businessCategory, rm_unknown, sampleSizes, algs) 



