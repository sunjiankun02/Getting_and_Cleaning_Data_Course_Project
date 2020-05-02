library(plyr)
setwd("/Users/jsun3/Box/Study/Coursera/DataScienceSpecialization/03_GettingAndCleaningData/quiz&assignments/assignment/Getting_and_Cleaning_Data_Course_Project/UCI HAR Dataset")

### Read data ###
setwd("./test")
subject_test <- read.table("subject_test.txt")
X_test <- read.table("X_test.txt")
y_test <- read.table("y_test.txt")
setwd("../")

setwd("./train")
subject_train <- read.table("subject_train.txt")
X_train <- read.table("X_train.txt")
y_train <- read.table("y_train.txt")
setwd("../")

activity_labels <- read.table("activity_labels.txt", col.names = c("activity_label", "activity"))
features <- read.table("features.txt", col.names = c("index", "measurement"))

### Merge data ###
test <- data.frame(subject_test, X_test, y_test)
train <- data.frame(subject_train, X_train, y_train)
data <- rbind(test, train)

### Add descriptive variable names ###
X_name <- as.character(features$measurement)
names(data) <- c("subject", X_name, "activity_label")

### Extract mean and standard deviation ###
col_X <- ncol(X_test)
col_data <- ncol(data)
index_mean <- grep("mean()", features$measurement, fixed = TRUE)
index_std <- grep("std()", features$measurement, fixed = TRUE)
index_extract <- c(index_mean, index_std)
index_sort <- sort(index_extract)
index_keep <- c(1,index_sort+1,col_data)
data <- data[,index_keep]

### Add descriptive activity names ###
data <- merge(activity_labels, data, by = "activity_label", all=TRUE)
data <- arrange(data, activity_label, subject)

### Create a second data set ###
spData <- split(data, list(data$activity_label, data$subject))
group_avg <- sapply(spData, function(x) colMeans(x[4:ncol(x)]))
group_avg <- as.data.frame(group_avg)
group_avg <- t(group_avg)
colnames(group_avg) <- paste(colnames(group_avg), "avg", sep = "_")
act_lab <- rep(activity_labels$activity_label, times = 30)
subj <- rep(1:30, times = 6)
group_avg <- cbind(activity_label = act_lab, subject = subj, group_avg)
group_avg <- merge(activity_labels, group_avg, by = "activity_label", all=TRUE)
group_avg <- arrange(group_avg, activity_label, subject)

setwd("../")
write.table(group_avg, "group_average.txt", row.names = FALSE)