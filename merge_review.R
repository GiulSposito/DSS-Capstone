# Prepare and Merge Reviews
# Giuliano Sposito (gsposito@gmail.com)
# November, 2015
#
# R script to prepare and merge the Reviews dataset with to a pre filtered 
# version of Business dataset. This scripts also makes a subsetting of 200 thousand 
# Busines_x_Review that will be used in the analysis

# load the review dataset
load("./raw_data/review.rdata")

# renames the star column from Review to avoid the same name in the Business dataset
names(review)[4] <- "reviewStars"

# creates a two level feature based in the stars of a review
review$reviewEmotion <- ifelse(
    review$reviewStars < 3,
    "negative",
    ifelse(
      review$reviewStars > 3,
      "positive",
      "unknown"
    )
  )

# transform features in factors
review$reviewEmotion <- as.factor(review$reviewEmotion)
review$reviewStars <- as.factor(review$reviewStars)

# load the Business data set and merge with Review by 'business_id' key
load("./data/business.rdata")
business_review <- merge(business, review, by="business_id")
dim(business_review)

# free memory from loaded datasets (keeping the merged)
rm(business)
rm(review)

# for the study, we will take only 400 thousand Business x Review of all available data
set.seed(19121975) #for reproducible research
business_review <- business_review[sample(nrow(business_review),size=400000),]
dim(business_review)

# save the subset
save(business_review, file="./data/business_review.rdata")

