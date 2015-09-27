# Initial Download, and unzipping of data files.
initialdownloadunzip <- function(){
  # Directory only for my local PC environment
  # mywd <- "F:/Coursera/Data Science Specialization/03 Getting and Cleaning Data/project"
  # setwd(mywd)

  dataDownloadURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(dataDownloadURL,"project.zip")

  unzip("project.zip")
}

# Load Required Libraries
loadLibraries <- function(){
  if (!require("data.table")) {
    install.packages("data.table")
  }
  if (!require("reshape2")) {
    install.packages("data.table")
  }
#  if (!require("dplyr")) {
#    install.packages("data.table")
#  }
#  if (!require("tidyr")) {
#    install.packages("reshape2")
#  }
  library(data.table)
  library(reshape2)
#  library(dplyr)
#  library(tidyr)
  
  require("data.table")
  require("reshape2")
#  require("dplyr")
#  require("tidyr")
}

initialdownloadunzip()
loadLibraries()

# Load and Prepare all Data
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(xTest) = features
names(xTrain) = features

# Isolate the Mean and Standard Deviation
meanSTD <- grepl("mean|std", features)

# Get only the numbers for mean and standard deviation.
xTest = xTest[,meanSTD]

# Activity labels
yTest[,2] = activityLabels[yTest[,1]]
names(yTest) = c("Activity_ID", "Activity_Label")
names(subjectTest) = "subject"

# Put them all together
testData <- cbind(as.data.table(subjectTest), yTest, xTest)

# Extract only the measurements on the mean and standard deviation for each measurement.
xTrain = xTrain[,meanSTD]

# Activity data
yTrain[,2] = activityLabels[yTrain[,1]]
names(yTrain) = c("Activity_ID", "Activity_Label")
names(subjectTrain) = "subject"

# Include yTrain and xTrain data
trainData <- cbind(as.data.table(subjectTrain), yTrain, xTrain)
data = rbind(testData, trainData)

idLabels   = c("subject", "Activity_ID", "Activity_Label")
dataLabels = setdiff(colnames(data), idLabels)
melted      = melt(data, id = idLabels, measure.vars = dataLabels)

# Apply mean function to dataset using dcast function
tidyData   = dcast(melted, subject + Activity_Label ~ variable, mean)

write.table(tidyData, file = "./tidy_data.txt")
