# 1. Read feature names to apply as column names to train ,and test  data sets.
library(data.table)
featureNames <- read.table("features.txt")
fnames <- featureNames["V2"]

# 2. read  test table data.
testTbl <- data.table(read.table(file=("./test/X_test.txt")))
#make a copy of so that we dont corrupt read table while processing.
testData <- copy ( testTbl)
setnames(testData, as.character(fnames$V2))

# 3. Read train table data.
trainTbl <- data.table(read.table(file=("./train/X_train.txt")))
#make a copy of so that we dont corrupt read table while processing.
trainData <- copy ( trainTbl) 
setnames(trainData, as.character(fnames$V2))


# 4. read activity data for Train and test and add activity column

### 4. Read activity data for train and test 
testAct <- data.table(read.table(file=("./test/y_test.txt")))
testData[,Activity:=testAct$V1]

trainAct <- data.table(read.table(file=("./train/y_train.txt")))
trainData[,Activity:= trainAct$V1]
# merge two data sets train and test
mergeTemp <- rbind(testData,trainData)

# 6. Read activity labels 
#actLls <- data.table(read.table(file=("./activity_labels.txt")))
# 6. read subject data and add a subject column  

subTest <- data.table(read.table(file=("./test/subject_test.txt")))
subTrain <- data.table(read.table(file=("./train/subject_train.txt")))
subject <- rbind(subTest,subTrain)    # Note order must be same as in step4 . i,e,. merge test with train 

# add subject column
mergeTemp[,subject:=subject$V1]

# make a copy of merged data for tidySet
tidySet <- copy(mergeTemp)

df <- as.data.frame(mergeTemp)
#select columns to extract
cols <- fnames[grep("*-mean*|*-std*",fnames$V2),]
cols <- as.vector(cols)
cols[80] <- "Activity"
cols[81] <- "subject"

smalldf <- df[,cols]

#splitTbl <- split(smalldf, list(smalldf$subject, smalldf$Activity))
splitTbl <- split(df, list(df$Activity,df$subject))
output <- sapply(splitTbl,colMeans)

#wirte analysis out put to file
write.table(output,file="assignment-output.txt",row.names=FALSE,col.names=TRUE, sep="\t")


#create a tidy set. create a descriptive column for activity. 
tidySet[,Activity_Desc:={ifelse(Activity== 1,"WALKING",ifelse(Activity== 2,"WALKING_UPSTAIRS",ifelse(Activity==3,"WALKING_DOWNSTAIRS",ifelse(Activity== 4,"SITTING",ifelse(Activity== 5,"STANDING",ifelse(Activity==6,"LAYING","NA"))))))}]

#add the new column to column list
cols[81] <- "Activity_Desc"
tidydf <- as.data.frame(tidySet)
tidyOutput <- tidydf[,cols]
write.table(tidyOutput,file="tidy dataset-output.txt",row.names=FALSE,col.names=TRUE, sep="\t")
