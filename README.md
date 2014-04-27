##1. Read train and test data tables.
***Assumptions:***

1.	set current working directory to folder **'UCI HAR Dataset'**
 	* `setwd('...getdata-projectfiles-UCI HAR Dataset\UCI HAR Dataset')`
2. script make use of data.table. so the user needs to install data.table package and load the library.
	* `install.packages('data.table')`
 	* `library(data.table)`

---
### 1. Read feature names to apply as column names.
1. Take the second column ('V2') from the read feature data set.
	* `featureNames <- read.table("features.txt")`
	* `fnames <- featureNames["V2"]`

### 2. read  test table data.
1. make a copy of the test table so to make sure it is not corrupted during processing.
	* `testTbl <- data.table(read.table(file=("./test/X_test.txt")))`
	* `testData <- copy ( testTbl)`
2. Apply column names read from feature names.
	`setnames(testData, as.character(fnames$V2))`

### 3. read  train table data.
1. make a copy of the test table so to make sure it is not corrupted during processing.
	* `trainTbl <- data.table(read.table(file=("./train/X_train.txt")))`
	* `trainData <- copy ( trainTbl)`
2. Apply column names read from feature names.
	`setnames(trainData, as.character(fnames$V2))`


### 4. Read activity data for train and test and add as column to correspondng data set.
`testAct <- data.table(read.table(file=("./test/y_test.txt")))`
`testData[,Activity:=testAct$V1]`

`trainAct <- data.table(read.table(file=("./train/y_train.txt")))`
`trainData[,Activity:= trainAct$V1]`

### 5. merge two tables.
`mergeTemp <- rbind(testData,trainData)`


### 6. Add subject Data
Read subject data of test and train dataset and a subject column.
(Note order must be same as in step4 . i,e,. merge test with train). 

	subTest <- data.table(read.table(file=("./test/subject_test.txt")))
	subTrain <- data.table(read.table(file=("./train/subject_train.txt")))
	subject <- rbind(subTest,subTrain)    

add new subject column
	
	mergeTemp[,subject:=subject$V1]

### Do analysis and make a tidy data set
Make a copy of merged data for tidySet.
	
	tidySet <- copy(mergeTemp)
	df <- as.data.frame(mergeTemp)
select columns to extract.

	cols <- fnames[grep("*-mean*|*-std*",fnames$V2),]
	cols <- as.vector(cols)
	cols[80] <- "Activity"
	cols[81] <- "subject"

extract required columns.

	smalldf <- df[,cols]

### Compute col means By Activity and Subject 
	splitTbl <- split(df, list(df$Activity,df$subject))
	output <- sapply(splitTbl,colMeans)

### out put analysis data to a file.
Write analysis out put to file.

	write.table(output,file="assignment-output.txt",row.names=FALSE,col.names=TRUE, sep="\t")


###create a tidy set. 
Create a descriptive column for activity. 

	tidySet[,Activity_Desc:={ifelse(Activity== 1,"WALKING",ifelse(Activity== 2,"WALKING_UPSTAIRS",ifelse(Activity==3,"WALKING_DOWNSTAIRS",ifelse(Activity== 4,"SITTING",ifelse(Activity== 5,"STANDING",ifelse(Activity==6,"LAYING","NA"))))))}]

add the new column to column list.
Extract the data and write out put to "tidy dataset-output.txt".

	cols[81] <- "Activity_Desc"
	tidydf <- as.data.frame(tidySet)
	tidyOutput <- tidydf[,cols]
	write.table(tidyOutput,file="tidy dataset-output.txt",row.names=FALSE,col.names=TRUE, sep="\t")


