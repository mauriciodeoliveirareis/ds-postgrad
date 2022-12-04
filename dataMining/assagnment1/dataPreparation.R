setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) #Set work directory to be the same as this file's directory (only works on RStudio)

library(stringr) #to manipulate strings, remove whitespaces, etc

#converts adult.data into csv
adult <- read.table(file = 'adult.data', header = FALSE, sep = ",", 
                    col.names = c("age", "workclass", "fnlwgt", "education","education-num","marital-status",
                                  "occupation","relationship","race","sex","capital-gain","capital-loss",
                                  "hours-per-week","native-country", "salary") )
#get rid of whispaces 
adult$workclass <- str_trim(adult$workclass, side = "both")
adult$education <- str_trim(adult$education, side = "both")
adult$marital.status <- str_trim(adult$marital.status, side = "both")
adult$occupation <- str_trim(adult$occupation, side = "both")
adult$relationship <- str_trim(adult$relationship, side = "both")
adult$race <- str_trim(adult$race, side = "both")
adult$sex <- str_trim(adult$sex, side = "both")
adult$native.country <- str_trim(adult$native.country, side = "both")
adult$salary <- str_trim(adult$salary, side = "both")

for(i in 1:ncol(adult)) {       # for-loop over columns
  data1[ , i]
}

#create new csv file to be used on Orange 
write.csv(adult, "adult.data.csv")


#converts adult.test into csv
adultTest <- read.table(file = 'adult.test', header = FALSE, sep = ",", skip = 1,
                    col.names = c("age", "workclass", "fnlwgt", "education","education-num","marital-status",
                                  "occupation","relationship","race","sex","capital-gain","capital-loss",
                                  "hours-per-week","native-country", "salary") )
#get rid of whispaces 
adultTest$workclass <- str_trim(adultTest$workclass, side = "both")
adultTest$education <- str_trim(adultTest$education, side = "both")
adultTest$marital.status <- str_trim(adultTest$marital.status, side = "both")
adultTest$occupation <- str_trim(adultTest$occupation, side = "both")
adultTest$relationship <- str_trim(adultTest$relationship, side = "both")
adultTest$race <- str_trim(adultTest$race, side = "both")
adultTest$sex <- str_trim(adultTest$sex, side = "both")
adultTest$native.country <- str_trim(adultTest$native.country, side = "both")
adultTest$salary <- str_trim(adultTest$salary, side = "both")

nrow(adultTest)

write.csv(adultTest, "adult.test.csv")


