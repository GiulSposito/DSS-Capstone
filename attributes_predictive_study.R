# This script will perform the analisys of the review text
# We'll verify the accuracy and process time of different Machine Learning algorithms 
# in the context of Text Classification for diverse sample size to predict several attributes from
# the business and from review itself


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

# we'll define the basic parameters
businessCategory <- "Restaurants"       # we'll limit this study to Restaurants review only

# attibutes to study
features <- c(#'category',
              'wifi',
              'hasWifi',
              'hasParking',
              'noiseLevel',
              'noisy',
              'priceRange',
              'pricy',
              'goodForKids',
              'goodForGroups',
              'hasTV',
              'smoking',
              'goodForSmoking',
              'reviewEmotion',
              'reviewStars')

# study name
studyName <- "attribute.analysis.unbalanced"

# sample sizes
sampleSizes <- data.frame(
  train=c(5000,5000),
  test=rep(2000,2)
)

# algorithms
algs <- c("SVM", "MAXENT")

# for each feature we perfome some analysis
# set.seed(19121975) # for reproducible research
lapply(features, FUN=function(feature){
  # for each feature we performe 
  rm_unknowns <- c(T,F)
  lapply(rm_unknowns, FUN=function(rm_unknown){
    predictive_analysis(feature, studyName, businessCategory, rm_unknown, sampleSizes, algs)
    predictive_analysis(feature, studyName, category=NULL, rm_unknown, sampleSizes, algs)
  })
  
})



