---
title: "ReadMe for Final Project -- Getting and Cleaning Data"
author: "Alyssa Butters"
date: "9/3/2020"
output: html_document
---

## Brief description of the data

The run_analysis.R document provides code to manipulate the dataset "Human Activity Recognition Using Smartphone Dataset Version 1.0" from Anguita et al 2012 [1] into an alternate, tidy format comprised of two separate datasets.  A complete description of the study and the dataset used can be found at: <http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>  

Briefly, 30 volunteers aged 19-48 years were evaluated while performing six tasks (walking, walking upstairs, walking downstairs, sitting, standing, laying).  A Samsung Galaxy S II smartphone was worn by each participant, and the accelerometer and gyroscope contained within the device collected linear acceleration and angular velocity measurements.  The experiments were manually labeled from videorecordings.

## Included files

The dataset includes the following files:

- Coursera_DS3_Final.zip: The zipped file containing the original datasets and descriptive files  
- CodeBook.md: Outlines the data, variables, and the manipulations performed to clean up the data and produce tidy datasets requested in the assignment  
- run_analysis.R: Provides the code used to produce the two tidy datasets requested of the assignment  
- Tidy_dataset_1.txt: Text file containing the tidy dataset detailing the values produced by run_analysis.R, before the dataset was split and averaged for each subject and each activity  
- Averages_by_activity_and_subject.txt:  Text file containing the table of the computed averages for each subject and each activity as produced using the run_analysis.R file  

Note: for more information about the original dataset, contact activityrecognition@smartlab.ws

## Explanation of scripts

To perform this analysis, the package "dplyr" must be installed and loaded into the library.

```{r}
library(dplyr)
```

As several files were presented in zip format, first it was checked if the zipfile existed in the archive and if not, the zipfile was downloaded: 

```{r}
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  
```

Next, the dataset was unzipped to extract individual files:

```{r}
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}
```

Each file was read individually and saved in separate tables: 

```{r}
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
```

Then the data manipulation was performed.

The original dataset was separated into a "Training" and "Testing" dataset, comprised of 70% and 30% of the volunteers respectively.  For this project, the two datasets were merged into a single dataset with all observations, first by merging the x_train and x_test variables for each subject, then merging the y_train and y_test variables for each subject, the merging the x and y variables for each subject, and finally merging all subjects into a single data frames (Merged_Data)

```{r}
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
each_subject <- rbind(subject_train, subject_test)
all_subjects <- cbind(each_subject, Y, X)
```

Next, only the measurements detailing the mean and standard deviation for each measurement were extracted into a new TidyData dataset:

```{r}
all_data <- all_subjects %>% select(subject, code, contains("mean"), contains("std"))
```

Descriptive activity names were applied to replace the activity values, making the labels more informative.  The labels from the "activity_label" file were assigned to column 2 ("code") in the all_data dataset and the second column name was updated to "activity_performed":

```{r}
all_data$code <- activity_labels[all_data$code, 2]
names(all_data)[2] = "activity_performed"
```

Next, the variable names were replaced with more descriptive names.  All abbreviations were replaced with more descriptive labels using gsub() and, if necessary, ignoring the case of the abbreviation (ex. for mean)

```{r}
names(all_data)<-gsub("Acc", "Accelerometer", names(TidyData))
names(all_data)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(all_data)<-gsub("BodyBody", "Body", names(TidyData))
names(all_data)<-gsub("Mag", "Magnitude", names(TidyData))
names(all_data)<-gsub("^t", "Time", names(TidyData))
names(all_data)<-gsub("^f", "Frequency", names(TidyData))
names(all_data)<-gsub("tBody", "TimeBody", names(TidyData))
names(all_data)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(all_data)<-gsub("-std()", "Standard_Deviation", names(TidyData), ignore.case = TRUE)
names(all_data)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(all_data)<-gsub("angle", "Angle", names(TidyData))
names(all_data)<-gsub("gravity", "Gravity", names(TidyData))
```

Finally, using the all_data dataset thus created, a second dataset was produced that details the average of each variable for each activity and each subject.  The all_data dataset was split by the categorical variables subject and activity, and the average was taken of each variable by activity and by subject.  This was saved to a new dataset called "averages":

```{r}
averages <- all_data %>%
  group_by(subject, activity_performed) %>%
  summarise_all(funs(mean))
write.table(averages, "Averages_by_activity_and_subject.txt", row.name=FALSE)
```

## Why these datasets are tidy datasets

Therefore, the two datasets thus created both fulfill the requirements of tidy datasets, as in each dataset:
- each variable forms a column (each measurement type has its own column)  
- each observation forms a row (each subject performing each activity is in a different row)  
- each type of observational unit forms a table (the dataset containing the average of each activity and each subject is separate from the dataset containing the individual observations)

### License:

As indicated in the original dataset, the use of this data must be acknowledged by referencing the following publication [1]:

Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra, and Jorge L. Reyes-Ortiz.  Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine.  International Workshop of Ambient Assisted Living (IWAAL 2012).  Vitoria-Gasteiz, Spain. Dec 2012.

This dataset was distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse.  Any commercial use is prohibited.