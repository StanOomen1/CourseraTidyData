# Made by Stan Oomen on 27-3-2020 for Coursera Course
# Load libraries used - make sure they are installed. Otherwise use install.packages("data.table") 
library(data.table)
library(dplyr)

#Set working directory on local machine
setwd("C:/Users/soomen/OneDrive - Capgemini/Desktop/Ontwikkeling/Coursera R/CleanData/week4/")

#Download zip file and unzip
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfile <- "Week4Datasets.zip"
if (!file.exists(zipfile)){
  download.file(url, destfile = zipfile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(zipfile)
}

#Set directory for importing datasets
setwd("./UCI HAR Dataset")

#Read datasets
featuresdata <- fread("./features.txt", header= FALSE ,col.names = c("Amount","Functionality"))
activities <- fread("./activity_labels.txt", header= FALSE , col.names = c("Code", "Activity"))

xtest <- fread("./test/X_test.txt",header = FALSE , col.names = featuresdata$Functionality)
ytest <- fread("./test/y_test.txt",header = FALSE , col.names = "Code")
subjecttest <- fread("./test/subject_test.txt", header = FALSE, col.names = "Subject")

xtrain <- fread("./train/X_train.txt", header = FALSE, col.names = featuresdata$Functionality)
ytrain <- fread("./train/y_train.txt", header = FALSE, col.names = "Code")
subjecttrain <- fread("./train/subject_train.txt", header = FALSE, col.names = "Subject")

# 1.  Merges the training and the test sets to create one data set.
#Combine datasets
xtesttrain <- rbind(xtest,xtrain)
ytesttrain <- rbind(ytest,ytrain)
subjecttesttrain <- rbind(subjecttest ,subjecttrain)
merged <- cbind(subjecttesttrain, xtesttrain,ytesttrain)

#Remove duplicate columns
merged <- subset(merged, select=which(!duplicated(names(merged)))) 

# 2.  Extracts only the measurements on the mean and standard deviation for each measurement.

tidier <- merged %>% dplyr::select(Subject, Code, dplyr::contains("mean"), dplyr::contains("std"))


# 3.  Uses descriptive activity names to name the activities in the data set
tidier$Code <- activities[tidier$Code, 2]

# 4.  Appropriately labels the data set with descriptive variable names.
names(tidier)[2] <- "ActivityDescription"
names(tidier)<-gsub("^t", "Time-", names(tidier))
names(tidier)<-gsub("^f", "Frequency", names(tidier))
names(tidier)<-gsub("Freq", "Frequency", names(tidier))
names(tidier)<-gsub("Acc", "Accelerometer", names(tidier))
names(tidier)<-gsub("Gyro", "Gyroscope", names(tidier))
names(tidier)<-gsub("Mag", "Magnitude", names(tidier))
names(tidier)<-gsub("BodyBody", "Body", names(tidier))
names(tidier)<-gsub("angle", "Angle", names(tidier))
names(tidier)<-gsub("gravity", "Gravity", names(tidier))
names(tidier)<-gsub("tBody", "TimeBody", names(tidier))


# 5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidiest <- tidier %>% group_by(ActivityDescription, Subject) %>% summarise_all(lst(mean))

#Write to file 
fwrite(tidiest, "TidyDataSet.txt", row.name=FALSE)
