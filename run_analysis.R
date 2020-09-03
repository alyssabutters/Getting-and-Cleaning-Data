setwd("C:/Users/alyssa.butters/Desktop/Coursera/R Programming/Getting-and-Cleaning-Data")

library(dplyr)

filename <- "Coursera_DS3_Final.zip"

# Checking if archive already exists, and if not, downloading the zipfile.
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  

# If "UCI HAR Dataset" file doesn't exist, unzipping zipfile
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

#Reading in each individual txt file now that they are unzipped
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")


#Merge the x training and test datasets
X <- rbind(x_train, x_test)
#Merge the y training and test datasets
Y <- rbind(y_train, y_test)
#Merge the Subject training and test datasets
each_subject <- rbind(subject_train, subject_test)
#Merge the three datasets described above into a single dataset
all_subjects <- cbind(each_subject, Y, X)

#Extract the "subject" "code" and any columns containing "mean" and "std" from all_subjects and assign to a new dataset called all_data
all_data <- all_subjects %>% select(subject, code, contains("mean"), contains("std"))

# Assign the labels from "activity_labels" to the column 2 ("code") in the all_data and assign it to a new variable all_data$code
all_data$code <- activity_labels[all_data$code, 2]

# Replace the second column heading in all_data with "activity_performed"
names(all_data)[2] = "activity_performed"

# Replace all abbreviations with more descriptive labels using gsub() and, if necessary, ignoring the case of the abbreviation (ex. for mean)
names(all_data)<-gsub("Acc", "Accelerometer", names(all_data))
names(all_data)<-gsub("Gyro", "Gyroscope", names(all_data))
names(all_data)<-gsub("BodyBody", "Body", names(all_data))
names(all_data)<-gsub("Mag", "Magnitude", names(all_data))
names(all_data)<-gsub("^t", "Time", names(all_data))
names(all_data)<-gsub("^f", "Frequency", names(all_data))
names(all_data)<-gsub("tBody", "TimeBody", names(all_data))
names(all_data)<-gsub("-mean()", "Mean", names(all_data), ignore.case = TRUE)
names(all_data)<-gsub("-std()", "STD", names(all_data), ignore.case = TRUE)
names(all_data)<-gsub("-freq()", "Frequency", names(all_data), ignore.case = TRUE)
names(all_data)<-gsub("angle", "Angle", names(all_data))
names(all_data)<-gsub("gravity", "Gravity", names(all_data))

# Produce a file that details the first tidy dataset thus created
write.table(all_data, "Tidy_dataset_1.txt", row.name=FALSE)

# Split the all_data dataset by the categorical variables subject and activity, then take the average of each variable by activity and by subject (using summarize) both by
averages <- all_data %>%
  group_by(subject, activity_performed) %>%
  summarise_all(funs(mean))
write.table(averages, "Averages_by_activity_and_subject.txt", row.name=FALSE)