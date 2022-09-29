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
experimData <- read.delim("experim.dat",  header = TRUE, sep = " ")
#Hygiene by gender, here we let ggplot output some info for the legend
histogram <- ggplot(experimData, aes(x=fost1)) 
histogram + geom_histogram(fill="black",binwidth = 0.4) + labs(x = "Fear of statistics time 1", y = "Frequency")

histogram <- ggplot(experimData, aes(x=fost2)) 
histogram + geom_histogram(fill="black",binwidth = 0.4) + labs(x = "Fear of statistics time 1", y = "Frequency")


#barplot by gender 
bar <- ggplot(experimData, aes(sex, fost1))
bar + stat_summary(fun.y=mean, geom="bar")

bar <- ggplot(experimData, aes(sex, fost1))
bar + stat_summary(fun.y=mean, geom="bar")

