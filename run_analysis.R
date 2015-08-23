## run_analysis.R is a script that acomplishes the following 5 items
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# installs the required packges if not already done
if (!require("data.table")) {
    install.packages("data.table")
}

if (!require("reshape2")) {
    install.packages("reshape2")
}

require("data.table")
require("reshape2")

# reads data column names into variable colNames
colNames <- read.table("./UCI HAR Dataset/features.txt")[,2]

# reads the activity labels into variable activityLabels
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# gets only the  mean and standard deviation for each observation
MeanStd <- grepl("mean|std", colNames)

# reads X_test, Y_test, subject_test into variables xTest,yTest and subjectTest
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(xTest) = features

# get values for  mean and standard deviation for each observation
xTest = xTest[,MeanStd]

# read activity labels
yTest[,2] = activityLabels[yTest[,1]]
names(yTest) = c("Activity_ID", "Activity_Label")
names(subjectTest) = "subject"

# column bind data into variable testData
testData <- cbind(as.data.table(subjectTest), yTest, xTest)

# read X_train , y_train and subject_train data into xTrain,yTrain, and subjectTrain
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")

subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(xTrain) = features

# get values for  mean and standard deviation for each observation
xTrain = xTrain[,MeanStd]

# read activity data
yTrain[,2] = activityLabels[yTrain[,1]]
names(yTrain) = c("Activity_ID", "Activity_Label")
names(subjectTrain) = "subject"

# coulumn bind data into variable trainData
trainData <- cbind(as.data.table(subjectTrain), yTrain, xTrain)

# rowbind testData and trainData into variable data
data = rbind(testData, trainData)

# Slice dice and melt data
idLabels   = c("subject", "Activity_ID", "Activity_Label")
dataLabels = setdiff(colnames(data), idLabels)
meltData      = melt(data, id = idLabels, measure.vars = dataLabels)

# use mean function on the dataset with dcast function
tidyData   = dcast(meltData, subject + Activity_Label ~ variable, mean)

# write the cleaned and tidy data 
write.table(tidyData, file = "./tidy_data.txt")