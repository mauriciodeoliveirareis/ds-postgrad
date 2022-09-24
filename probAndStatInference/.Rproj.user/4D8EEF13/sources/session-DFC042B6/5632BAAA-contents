#TU059/TU060/TU256/PhD School of Computer Science, TU Dublin
#Probability and Statistical Inference - Lab One

#------------Preliminaries-------------------------------
#INSTALL AND LOAD packagages
#This first bit of code installs all the packages needed to run the various functions within this file

#First we create a function called install_packages, it takes as argument a vector 
#We will pass it a list of packages we need, the function will parse this list and for 
#each package listed it will first check to see if it is installed, if not it will install it,
#and then load the package for use

install_packages <- function(pkg) { 
  
  # Install package if it is not already
  if (!(pkg %in% installed.packages()[, "Package"])){ 
    
    install.packages(pkg, repos='http://cran.us.r-project.org')
  }
  
  library(pkg, character.only = TRUE)
  
} # end installPackages()

#Create the list of packages we need
pkg_list = c("tidyverse", "modelr", "carData", "car")
#Call our function passing it the list of packages
lapply(pkg_list, install_packages)


#SETUP DATAFRAME
#First we are going to load the dataset salaries from the package carData
#We load it into a dataframe we call acad_salary (you can change it to whatever you like)
acad_salary<-carData::Salaries


# #This dataset contains data from a 2008-09 nine-month academic salary for Assistant Professors,
# #Associate Professors and Professors in a college in the U.S.
# 
# rank: a factor with levels AssocProf AsstProf Prof
# 
# discipline: a factor with levels A ("theoretical" departments) or B ("applied" departments).
# 
# yrs.since.phd: years since PhD.
# 
# yrs.service: years of service.
# 
# sex: a factor with levels Female Male
# 
# salary: nine-month salary, in dollars.

#-----------------------------------------------------------------------------------------------


#LOOK AT THE DATA
#Get a list of all variables in the dataset using colnames
names(acad_salary)

#You can look at the data in a variable by entering its name at the command prompt
acad_salary$salary

#You can use the str function to get an overview of the variable
str(acad_salary$discipline)

#Use summary to get a relevant statistical summary for a variable e.g. by discipline
#- this will give use a frequencies as nationality is categorical
summary(acad_salary$discipline)

#For salary - this will give use median, mean, IQR, max and min for the salary as it is a scale
summary (acad_salary$salary)

#Or get a summary of all the variables in the dataset
summary(acad_salary)


#To see rank by discipline how many of each dicipline hold each rank we need to create a 
#Contingency table (cross tabulation)

#We start by creating the table 
tab<-table(acad_salary$discipline, acad_salary$rank)

tab #show the table with frequencies

prop.table(tab) # shows probabilities for each discipline for each rank

-------------------------------------------------------------------------------
#### MEASURES OF CENTRAL TENDENCY
#Median

median(acad_salary$salary)

#Mean
mean(acad_salary$salary)

#You can assign the outcome to a variable
meansal <- mean(acad_salary$salary)

#and then display it on screen
meansal


#Or use the print function to make it look the way you want
print(meansal, digits=1)

#Mode
#R doesn't have a built in function to compute the mode but there is a simple function which you can write and include in your code  that will do it for you")

getmode <- function(v)
{
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v,uniqv)))]
}


#Use the function to get the mode of salary
getmode(acad_salary$salary)

------------------------------------------------------------------------------------------------

#### MEASURES OF DISPERSION
#Range
range(acad_salary$salary)


#Quantiles
quantile(acad_salary$salary)
#to get 1st quantile
x=quantile(acad_salary$salary); x[1] 

#Interquartile Range
IQR(acad_salary$salary)

#Variance
var(acad_salary$salary)


#Standard deviation
sd(acad_salary$salary)
#Rounded
round(sd(acad_salary$salary,2)) #rounded to 2 decimal places




