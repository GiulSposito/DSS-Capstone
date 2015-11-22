# This script pre-process the business dataset to prepare to analysis
#
# It will basically, normalize the category and attributes and select only the data that will
# used in the study
#
# Giuliano Sposito (gsposito@gmail.com) - Novembro, 2015
#

# load the raw business data
load("./raw_data/business.rdata")
size <- dim(business)[1]
dim(business)

# FIRST SUBSETTING: BUSINESS CATEGORY - 12 MOST IN USE
#
# The category of a business is a list of tags, so a business can have more than a category,
# the code below will count and select the top 12 most category tag in use and will reclassify
# the business in a unique category

# all category tags from the dataset
categories <- business$categories  # each business category
category_tags <- unlist(categories) # list of all categories in the dataset

# dictionary to count how many a category is used
category_counter <- vector() 

# function that uses the dictionary above to add or increment a category count
category.increment <- function (category){
  ifelse(
    is.na( category_counter[category] ),
    category_counter[category] <<- 1,
    category_counter[category] <<- category_counter[category] + 1
  )
  return () #returns noting
}

# count the category tag usage
temp <- lapply(category_tags, FUN=category.increment)
rm(temp)

# sort (desc) by occurency
category_counter <- sort(category_counter, decreasing=T)

# select the 12 most 'popular' category to use in the analysis
selected_categories <- names(category_counter[1:12])

# TRANSFORMATION: BUSINESS CATEGORY
#
# The category of a business is a list of tags, so a business can have more than a category,
# this transformation will take the selected categories and convert in a logical (T|F) column
# for each business. This will facilitate the counting and subsetting

temp <- lapply(selected_categories, FUN=function(catType){
  flags <- unlist(lapply(categories, FUN=function(x){
    catType %in% x
  })) # if a business has one of the selected category tag
  business[[catType]] <<- flags # A logical column with the category name will be created
})
rm(temp)
dim(business)

#creates a column to mark the numbers of classification has the business
business$categoriesCount <- rowSums(business[,16:dim(business)[2]])

# How much business has only one of the selected category classification?
filteredBusinessCount <- dim(business[business$categoriesCount==1,])[1]
filteredBusinessCount / size

# SUBSETTING: THE BUSINESS WITH ONLY ONE CATEGORY
#
# The code will take the business that has only one category tag
#
business <- business[business$categoriesCount==1,]
dim(business)


# TRANFORMATION: THE BUSINESS CATEGORY
#
# We'll create a CATEGORY column to reclassify the business
#

## get a business instance and return only one category tag as name
catClass <- function(b){
  selected_categories[which(t(b[,16:27])==T)] ## good code (is generic) but with bad performance (should be different?)
}

# creating a category column
business_category <- vector(length=filteredBusinessCount)
for(i in 1:filteredBusinessCount){
  business_category[i]<- catClass(business[i,])
}
rm(i)

# bind the classification
business$category <- business_category
business$category <- as.factor(business$category)

# TRANSFORMATION: THE BUSINESS ATTRIBUTES
#
# We'll select some attributes (stored in a nested dataframe) to perform 
# the text predictability analysis, we will transform in factors and unnest some of them
# also we will do some intermediary classification

# auxiliary function to conver a boolean var (T|F) in a factor var (transform NA in Unknown)
boolToFactor <- function(boolVar) 
  as.factor(ifelse(is.na(boolVar),"unknown", ifelse(boolVar,"yes","no")))

attributes <- business$attributes

# wi-fi
business$wifi <- attributes$"Wi-Fi"
business[is.na(business$wifi),]$wifi <- "unknown"
business$wifi <- as.factor(business$wifi)
business$hasWifi <- boolToFactor(attributes$"Wi-Fi"=="free" | attributes$"Wi-Fi"=="paid") # boolean (T F NA)

# TV boolean (T F NA)
business$hasTV <- boolToFactor(attributes$"Has TV")

# Smoking
business$smoking <- attributes$Smoking
business[is.na(business$smoking),]$smoking <- "unknown"
business$smoking <- as.factor(business$smoking)
business$goodForSmoking <- boolToFactor(attributes$Smoking =="yes" | attributes$Smoking == "outdoor") # boolean

# auxiliar funcion to check if there are a parking
verifyParking <- function(p){
  (p$garage | p$validate | p$lot | p$valet)
}

# parking: boolean has/hans't
business$hasParking <- boolToFactor(verifyParking(attributes$Parking))

# noise level: 4 levels: quiet average loud very_loud
business$noiseLevel <- attributes$"Noise Level"
business[is.na(business$noiseLevel),]$noiseLevel <- "unknown"
business$noiseLevel <- as.factor(business$noiseLevel)
business$noisy <- boolToFactor(attributes$"Noise Level" == "loud" | attributes$"Noise Level" == "very_loud") # boolean

# price range (1 to 4)
business$priceRange <- attributes$"Price Range"
business[is.na(business$priceRange),]$priceRange <- "unknown"
business$priceRange <- as.factor(business$priceRange)
business$pricy <- boolToFactor(attributes$"Price Range" == "3" |  attributes$"Price Range" == "4")

# Groups and Kids
business$goodForKids <- boolToFactor(attributes$"Good for Kids")
business$goodForGroups <- boolToFactor(attributes$"Good For Groups")

# subsetting the relevant columns
business <- business[,c(
  'business_id',
  'name',
  'full_address',
  'city',
  'state',
  'latitude',
  'longitude',
  'stars',
  'review_count',
  'category',
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
  'goodForSmoking'
)]

# save intermediary data
if (!file.exists("./data/")) dir.create("./data")
dim(business)
save(business, file="./data/business.rdata")

