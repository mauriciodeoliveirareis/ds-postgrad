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
pkg_list = c("tidyverse", "ggpubr")
#Call our function passing it the list of packages
lapply(pkg_list, install_packages)
experimData <- read.delim("experim.dat",  header = TRUE, sep = " ")
#Build two separate histograms one for fear of statistics scores at time 1 and a second for fear of statistics time 2
fos1 <- ggplot(experimData, aes(x=fost1)) + geom_histogram(fill="black",binwidth = 0.4) + labs(x = "Fear of statistics time 1", y = "Frequency") + 

fos2 <- ggplot(experimData, aes(x=fost2)) + geom_histogram(fill="black",binwidth = 0.4) + labs(x = "Fear of statistics time 2", y = "Frequency")
ggarrange(fos1, fos2, 
          ncol = 2)

#Create bar charts for fear of statistics at time 1 and time 2 by gender 
fos1ByGender <- ggplot(experimData, aes(sex, fost1)) + stat_summary(fun.y=mean, geom="bar")

fos2ByGender <- ggplot(experimData, aes(sex, fost2)) + stat_summary(fun.y=mean, geom="bar")
ggarrange(fos1ByGender, fos2ByGender, 
          ncol = 2)

#Create stem and leaf plots for confidence scores at time 1 and time 2
stem(experimData$fost1)
stem(experimData$fost2)

#Create boxplots for depression at time 1 and time 2 by gender
depressBoxplot1 <- ggplot(experimData, aes(sex, depress1)) + geom_boxplot() + labs(x = "Sex", y = "Depression Day 1")
depressBoxplot2 <- ggplot(experimData, aes(sex, depress2)) + geom_boxplot() + labs(x = "Sex", y = "Depression Day 2")
ggarrange(depressBoxplot1, depressBoxplot2, 
          ncol = 2)

#Create density plots for fear of statistics scores at time 1 and time 2 by gender
fost1Density <- ggplot(experimData, aes(x= fost1, colour=sex))
fost1Density + geom_density() + labs(x = "FOST1", y = "Density Estimate")

fost2Density <- ggplot(experimData, aes(x= fost2, colour=sex))
fost2Density + geom_density() + labs(x = "FOST2", y = "Density Estimate")
