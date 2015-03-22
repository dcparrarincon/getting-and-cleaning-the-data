# check required packages
if (!require("reshape2")) {
  install.packages("reshape2")
}

if (!require("data.table")) {
  install.packages("data.table")
}

require("reshape2")
require("data.table")

# Load features names and activity labels
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Extract required measurements (mean and standard deviation).
extractMeasurements <- grepl("mean|std", features)

# Load and process test data (X_test and y_test).
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(xTest) = features

# Extract required measurements for test data (mean and standard deviation).
xTest = xTest[,extractMeasurements]

# Load labels
yTest[,2] = activityLabels[yTest[,1]]
names(yTest) = c("Activity_ID", "Activity_Label")
names(subjectTest) = "subject"

# Bind data
testData <- cbind(as.data.table(subjectTest), yTest, xTest)

# Load and process training data (X_train and y_train)
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(xTrain) = features

# Extract required measurements for traing data (mean and standard deviation).
xTrain = xTrain[,extractMeasurements]

# Load activity data
yTrain[,2] = activityLabels[yTrain[,1]]
names(yTrain) = c("Activity_ID", "Activity_Label")
names(subjectTrain) = "subject"

# Bind data
trainData <- cbind(as.data.table(subjectTrain), yTrain, xTrain)

# Merge test and train dataset
data = rbind(testData, trainData)

idLabels   = c("subject", "Activity_ID", "Activity_Label")
dataLabels = setdiff(colnames(data), idLabels)
meltData      = melt(data, id = idLabels, measure.vars = dataLabels)

# get dataset mean
tidyData   = dcast(meltData, subject + Activity_Label ~ variable, mean)

# write tidy dataset
write.table(tidyData, file = "./tidy_data.txt")
