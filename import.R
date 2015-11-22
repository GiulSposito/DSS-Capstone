# Script to import the Yelp Json into Data Frame files
# Giuliano sposito - gsposito@gmail.com
# November, 2015

# Setup
library(jsonlite)

# Original data filenames
DATA_DIR <- "./json_data/"
TIP_FILENAME <- paste(DATA_DIR,"yelp_academic_dataset_tip.json",sep="")
USER_FILENAME <- paste(DATA_DIR,"yelp_academic_dataset_user.json",sep="")
REVIEW_FILENAME <- paste(DATA_DIR,"yelp_academic_dataset_review.json",sep="")
CHECKIN_FILENAME <- paste(DATA_DIR,"yelp_academic_dataset_checkin.json",sep="")
BUSINESS_FILENAME <- paste(DATA_DIR,"yelp_academic_dataset_business.json",sep="")

# check the destination directory
SAVE_DIR <- "./raw_data/"
if (!file.exists(SAVE_DIR)) dir.create(SAVE_DIR)

# For Each DataSet: Importing the Json Data, Save RData, close Connection and Free memory

# BUSINESS
business <- stream_in(con <- file(BUSINESS_FILENAME, "r"))
save(business, file=paste(SAVE_DIR,"business.rdata",sep=""))
rm(business)
close(con)

# REVIEWS
review <- stream_in(con <- file(REVIEW_FILENAME, "r"))
save(review, file=paste(SAVE_DIR,"review.rdata",sep=""))
rm(review)
close(con)

## IN THIS STUDY WE WILL USE ONLY BUSINESS and REVIEWS data ##
## So the coded below are commented ##
## uncomment the block below if you want import the other datasets

# # TIPS
# tip <- stream_in(con <- file(TIP_FILENAME, "r"))
# save(tip, file=paste(SAVE_DIR,"tip.rdata",sep=""))
# rm(tip)
# close(con)
# 
# # USERS
# user <- stream_in(con <- file(USER_FILENAME, "r"))
# save(user, file=paste(SAVE_DIR,"user.rdata",sep=""))
# rm(user)
# close(con)
# 
# # CHECK INS
# checkin <- stream_in(con <- file(CHECKIN_FILENAME, "r"))
# save(checkin, file=paste(SAVE_DIR,"checkin.rdata",sep=""))
# rm(checkin)
# close(con)

# clean all objects im memory
rm(list = ls())

