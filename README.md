---
title: "run_analysis_markdown"
author: "sjk"
date: "February 22, 2015"
output: html_document
---

This is an R Markdown document for the script "run_analysis.R", which is to prepare the **UCI HAR dataset** that can be used for later analysis. This script does the following tasks:

* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement. 
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive variable names. 
* From the data set in the last step, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The script finishes the tasks by running the following parts of code in order: 

### 1. Load the package "plyr" and set working directory

```{r}
library(plyr)
setwd("/Users/sjk/Box Sync/Life in US/Study/Coursera/3. Getting and Cleaning Data/Exercises/UCI HAR Dataset")
```

### 2. Read data from the dataset directory

We first read data from the text files in the "test" and "train" directory, respectively, and store the data in the variables with the same names as the data files. The code for reading data from "test" directory is as follows, which is similar to that for "train" directory.

```{r}
setwd("./test")
subject_test <- read.table("subject_test.txt")
X_test <- read.table("X_test.txt")
y_test <- read.table("y_test.txt")
setwd("../")
```

Then we read the "feature.txt" and "activity_labels.txt" in the working directory.

```{r}
activity_labels <- read.table("activity_labels.txt", col.names = c("activity_label", "activity"))
features <- read.table("features.txt", col.names = c("index", "measurement"))
```

### 3. Merge the training and the test sets in one data set

We first create data frames for test and train data respectively, and then combine the two data frames.

```{r}
test <- data.frame(subject_test, X_test, y_test)
train <- data.frame(subject_train, X_train, y_train)
data <- rbind(test, train)
```

### 4. Appropriately labels the data set with descriptive variable names
We first name the X variables with the corresponding features in the feature_info.text. Then we name the 9 vectors of body acceleration signal and angular velocity, and total acceleration signal by adding number suffix for each dimension of a vector. Last we name the whole data frame by conbining the names for each set of variables.
```{r}
X_name <- as.character(features$measurement)
names(data) <- c("subject", X_name, "activity_label")
```

### 5. Extract measurements on the mean and standard deviation for each measurement

The idea of this extraction is picking out the features with string "mean()" or "std()" in their names, and use their indices (index_mean and index_std) to pick out the corresponding columns from the data while keeping all other columns.

```{r}
col_X <- ncol(X_test)
col_data <- ncol(data)
index_mean <- grep("mean()", features$measurement, fixed = TRUE)
index_std <- grep("std()", features$measurement, fixed = TRUE)
index_extract <- c(index_mean, index_std)
index_sort <- sort(index_extract)
index_keep <- c(1,index_sort+1,col_data)
data <- data[,index_keep]
```

### 6. Use descriptive activity names to name the activities in the data set

We do this by merging the data with the table "activity_labels" according to the activity labels.

```{r}
data <- merge(activity_labels, data, by = "activity_label", all=TRUE)
data <- arrange(data, activity_label, subject)
```

### 7. Create a tidy data set with the average of each variable for each activity and each subject
We first split the data by activity_label and subject into several groups, and calculate the mean of the columns for each variable within each group.
```{r}
spData <- split(data, list(data$activity_label, data$subject))
group_avg <- sapply(spData, function(x) colMeans(x[4:ncol(x)]))
```
Then we make some adjustments for the new dataset for later process. We first coerce the new data into a data frame. Then we transpose it so that each variable forms a column and each factor level forms a row. Then we rename the varibles and add columns for activity level and subject that shows the corresponding factor levels for each row. 

```{r}
group_avg <- as.data.frame(group_avg)
group_avg <- t(group_avg)

colnames(group_avg) <- paste(colnames(group_avg), "avg", sep = "_")
act_lab <- rep(activity_labels$activity_label, times = 30)
subj <- rep(1:30, times = 6)
group_avg <- cbind(activity_label = act_lab, subject = subj, group_avg)
group_avg <- merge(activity_labels, group_avg, by = "activity_label", all=TRUE)
group_avg <- arrange(group_avg, activity_label, subject)
```

Finally we write the new data into a text file.
```{r}
setwd("../")
write.table(group_avg, "group_average.txt", row.names = FALSE)
```