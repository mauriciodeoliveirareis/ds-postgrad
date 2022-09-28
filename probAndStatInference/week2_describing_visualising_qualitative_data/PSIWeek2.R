#TU059/TU060/TU256/PhD School of Computer Science, TU Dublin
#Probability and Statistical Inference - Week Two

#This script is based on the R Scripts provided with Field, Miles and Field Discovering Statistics with R


#------------Preliminaries-------------------------------
#INSTALL AND LOAD packaages
#This first bit of code installs all the packages needed to run the various functions within this file

#First we create a function called install_packages, it takes as argument a vector 
#We will pass it a list of packages we need, the function will parse this list and for 
#each package listed it will first check to see if it is installed, if not it will install it,
#and then load the package for use

#In this script we are going to initiate tidyverse which includes ggplot2
library("rstudioapi")
setwd(dirname(getActiveDocumentContext()$path))
install_packages <- function(pkg) { 
  
  # Install package if it is not already
  if (!(pkg %in% installed.packages()[, "Package"])){ 
    
    install.packages(pkg, repos='http://cran.us.r-project.org')
  }
  
  library(pkg, character.only = TRUE)
  
} # end installPackages()

#Create the list of packages we need
pkg_list = c("tidyverse")
#Call our function passing it the list of packages
lapply(pkg_list, install_packages)
#NOTE: Once installed we could just load tidyverse using the library command - library(tidyverse)


#Part ONE
#-- Some Basics with ggplot
#facebookNarcissim - data file from a study that looked at ratings of Facebook profile pictures
#which were rated (on coolness, fashion, attractiveness and glamour)
#and predicting from this how high the person predicted rates on narcissism
facebookData <- read.delim("facebookNarcissism.dat",  header = TRUE)

#ggplot with point - total score on narcissism questionnaire v rating
graph <- ggplot(facebookData, aes(NPQC_R_Total, Rating))
graph + geom_point() + ggtitle("geompoint")

#ggplot with triangle as point
graph + geom_point(shape = 17) + ggtitle("geom_point(shape = 17)")
#adjusting point size
graph + geom_point(size = 6) + ggtitle ("geom_point(size = 3)")

#using a black and white theme, using Triangles
graph + theme_bw(base_size=13)  + geom_point(shape = 17) + ggtitle ("theme_bw(base_size=13")

#using a theme theme, using Triangles
graph + theme_dark() + geom_point(shape = 17) + ggtitle ("theme_dark")


#show each rating as a different colour
graph + geom_point(aes(colour = Rating_Type)) + ggtitle("geom_point(aes(colour = Rating_Type))")

#Jitter adds a small amount of random variation to the location of each point - spreads the data out
graph + geom_point(aes(colour = Rating_Type), position = "jitter") + ggtitle ("geom_point(aes(colour = Rating_Type), position = jitter)")

#Saving a plot as an image
ggsave("Week2 Example jitter.png", plot=last_plot())

#--------Bar Charts----------
#Using ChickFlick.dat
#Data from a study of 20 men and 20 women. 
#Half the sample watched Bridget Jones Diary, half watched Memento. 
#Measured their interest in the movie. 
#Also stored is each survey respondents gender.

chickFlick = read.delim("ChickFlick.dat",  header = TRUE)

#Create a basic bar chart of levels of interest - simply a frequency count
bar<-ggplot(chickFlick, aes(x=interest)) + geom_bar()
bar


#Create a bar chart from the data showing bars for interest for each film by gender
#basic bar chart of  mean interest per film
bar <- ggplot(chickFlick, aes(film, interest))
bar + stat_summary(fun.y=mean, geom="bar")
#Here we are using the stat_summary function to calculate and then plot the mean values for each film

#Adding gender to the mix
#Create a bar chart showing mean values for each gender, and using the scale_fill_manual function to change the colours
bar <- ggplot(chickFlick, aes(film, interest, fill = gender ))
bar + stat_summary(fun.y = mean, geom = "bar", position="dodge") + labs(x="Film") + labs(y="Mean interest") + scale_fill_manual("Gender", values=c("Female" = "#008000", "Male" = "#0000FF"))
#position="dodge" adjusts horizontal positioning while maintaining vertical positions - to handle overlaps

#Save the char to an image file
ggsave("Week 2 Chick Flick Clustered Error Bar Custom Colours.png")



#--------HISTOGRAMS----------
#Data collected from the Download Music Festival. 
#Study measured the hygiene of attendees on the three days of the festival.
#Not all participants were measured each day so there is some missing data. Gender of the concert-goer is recorded.

festivalData <- read.delim("DownloadFestival.dat",  header = TRUE)

#Hygiene by gender, here we let ggplot output some info for the legend
festivalHistogram <- ggplot(festivalData, aes(x=day1, color=gender)) 
festivalHistogram + geom_histogram(fill="white",binwidth = 0.4) + labs(x = "Hygiene (Day 1 of Festival)", y = "Frequency")
#Create the histogram and set up the aesthetics
festivalHistogram <- ggplot(festivalData, aes(day1)) + theme(legend.position="none")
festivalHistogram + geom_histogram(binwidth = 0.4) + labs(x = "Hygiene (Day 1 of Festival)", y = "Frequency")



#---Stem and Leaf----
#Stem and leaf of Hygiene Day 1
stem(festivalData$day1)

#--------BOXPLOTS----------
#Boxplot of hygiene by gender
festivalBoxplot <- ggplot(festivalData, aes(gender, day1))
festivalBoxplot + geom_boxplot() + labs(x = "Gender", y = "Hygiene (Day 1 of Festival)")
#You should see an outlier for Female Day 1 (around 20 on the y axis)

#with outlier removed

festivalData2 = read.delim("DownloadFestival(No Outlier).dat",  header = TRUE)
festivalBoxplot2 <- ggplot(festivalData2, aes(gender, day1))
festivalBoxplot2 + geom_boxplot() + labs(x = "Gender", y = "Hygiene (Day 1 of Festival)")
#Spot the differences....


#Boxplot for day 2
festivalBoxplot <- ggplot(festivalData, aes(gender, day2))
festivalBoxplot + geom_boxplot() + labs(x = "Gender", y = "Hygiene (Day 2 of Festival)")

#Boxplot for day 3
festivalBoxplot <- ggplot(festivalData, aes(gender, day3))
festivalBoxplot + geom_boxplot() + labs(x = "Gender", y = "Hygiene (Day 3 of Festival)")



#---Density Plots----
#A density plot is a representation of the distribution of a numeric variable.
#It is a smoothed version of the histogram and is used in the same concept.


#Density plot of hygiene day 1 of the festival
festivalDensity <- ggplot(festivalData, aes(day1))
festivalDensity + geom_density() + labs(x = "Hygiene (Day 1 of Festival)", y = "Density Estimate")
#There is one outlier in the festival data with a score of 20.020
summary(festivalData$day1)
#If we use a dataset with it removed - notice the change in the max
summary(festivalData2$day1)
#and the change in the density plot
festivalDensity <- ggplot(festivalData2, aes(day1))
festivalDensity + geom_density() + labs(x = "Hygiene (Day 1 of Festival)-no outlier", y = "Density Estimate")


#--------OUTLIERS----------

#Function to work out percentage of data for a variable that is outside the z score accepted ranges
outlierSummary<-function(variable, digits = 2){
  
  zvariable<-(variable-mean(variable, na.rm = TRUE))/sd(variable, na.rm = TRUE)
  
  outlier95<-abs(zvariable) >= 1.96
  outlier99<-abs(zvariable) >= 2.58
  outlier999<-abs(zvariable) >= 3.29
  
  ncases<-length(na.omit(zvariable))
  
  percent95<-round(100*length(subset(outlier95, outlier95 == TRUE))/ncases, digits)
  percent99<-round(100*length(subset(outlier99, outlier99 == TRUE))/ncases, digits)
  percent999<-round(100*length(subset(outlier999, outlier999 == TRUE))/ncases, digits)
  
  cat("Absolute z-score greater than 1.96 = ", percent95, "%", "\n")
  cat("Absolute z-score greater than 2.58 = ",  percent99, "%", "\n")
  cat("Absolute z-score greater than 3.29 = ",  percent999, "%", "\n")
}
outlierSummary(festivalData$day1)
outlierSummary(festivalData$day2)
outlierSummary(festivalData$day3)

#Create a probability density plot for hygiene day 1
festivalDensity <- ggplot(festivalData2, aes(day1))
festivalDensity + geom_density() + labs(x = "Hygiene (Day 1 of Festival)", y = "Density Estimate")

#hygiene by gender - we get two plots one for male and one for female
festivalDensity + geom_density(aes(fill = gender), alpha = 0.5) + labs(x = "Hygiene (Day 1 of Festival)", y = "Density Estimate")



