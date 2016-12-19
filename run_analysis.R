rm(list=ls(all=TRUE))

#*** Packages ***
library(dplyr)

#*** Working Directory ***
mydir <- "C:/Users/name/Dropbox/Coursera/Data Science Specialization/GettingNcleaningdata/Assignments"
setwd(mydir)

    ##### Getting and Cleaning Data Project #####

## Downloads the file and put the file in the data folder

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

### unzips the file

unzip(zipfile="./data/Dataset.zip",exdir="./data")

### unzipped files are in the folder UCI HAR Dataset
path_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive=TRUE) #Gets the list of the files
files

## Here are the files that will be used to load data:

#test/subject_test.txt
#test/X_test.txt
#test/y_test.txt
#train/subject_train.txt
#train/X_train.txt
#train/y_train.txt

# The appropriate descriptive variable names for data in dataframe are Subject, Activity and Features

## Read data from the files into the variables

#Subject
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Activity
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

#Features
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)


### Merges the training and the test datasets to create a single data set

 ## Joins the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

##Below codes sets the names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

### Merge columns to get the data frame for all data

dataAll <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataAll)

### Extracting only the measurements on the mean and standard deviation for each measurement
 #Subset Name of Features by measurements on the mean and standard deviation by taking Names of Features with “mean()” or “std()”

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

##Subset the data frame by selected names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
 
str(Data) #Checks the structures of the data frame

### uses descriptive activity names to name the activities in the data set

### read descriptive activity names from “activity_labels.txt”
library(read.table)

activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

head(Data$activity,30)

### Appropriately labels the data set with descriptive variable names

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)

### Creating a second,independent tidy data set and ouputing it

Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
