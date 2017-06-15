## Project Instructions

##  You should create one R script called run_analysis.R that does the following.
##
##  1: Merges the training and the test sets to create one data set.
##  2: Extracts only the measurements on the mean and standard deviation for each measurement.
##  3: Uses descriptive activity names to name the activities in the data set
##  4: Appropriately labels the data set with descriptive variable names.
##  5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



## Load necessary packages
library(dplyr)

##
#### Read the data into R
features <- read.table("./UCI HAR Dataset/features.txt")
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
#### End of reading in section


##
#### Tidy the data 

## Give variables names
## For X_...  variable names are taken from features.txt where they are listed

madenames <- make.names(features$V2, unique = TRUE, allow_ = TRUE) ## To eliminate duplicate names
names(activity_labels) <- c("activityid", "activity")
names(subject_test) <- "subjectid"
names(y_test) <- "activityid"
names(X_test) <- madenames
names(subject_train) <- "subjectid"
names(y_train) <- "activityid"
names(X_train) <- madenames
## Done naming


##
## Merge 'test' data into one tidy set
## First make sure each activiy id is accompanied by it's name for clarity
activityidandlabels_test <- left_join(y_test, activity_labels)

## Merge data by column binding
test_data <- bind_cols(subject_test, activityidandlabels_test, X_test)
## Done tidying 'test'


## Merge 'training' data into one tidy set
## First make sure each activiy id is accompanied by it's name for clarity
activityidandlabels_train <- left_join(y_train, activity_labels)

## Merge data by column binding
train_data <- bind_cols(subject_train, activityidandlabels_train, X_train)
## Done tidying 'train'


## Merge test and train by row binding
trainandtest_data <- bind_rows("test" = test_data, "train" = train_data, .id = "set")
## Done merging test and train
#### Done tidying combined data

##
#### Extract measurements on mean and standard deviation
## Identify columns with mean or standard deviation
meanorstd <- grep("mean|std", names(trainandtest_data))
## Extract these columns and first four containing id information
selecteddata <- trainandtest_data[c(1:4, meanorstd)]
#### Done extracting

## Transform data into a tibble to take advantage of dplyr package
selecteddata <- tbl_df(selecteddata)

##
#### create a second, independent tidy data set with the average of each ...
#### ... variable for each activity and each subject.
secondset <- aggregate(selecteddata, list(
                                          subject = selecteddata$subjectid,
                                          activity = selecteddata$activity),
                                          mean)

## Remove redundant NA columns left over
secondset[6] <- NULL
secondset[3] <- NULL

## Write data to txt file
write.table(secondset, file = "tidydataset.txt", row.name=FALSE)

### finished