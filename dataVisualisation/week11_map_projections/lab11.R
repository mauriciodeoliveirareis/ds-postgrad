library(reshape2)
library(maps)
library(sqldf)
library(ggplot2)

crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
head(crimes)
crimesm <- melt(crimes, id = 1)

states_map <- map_data("state")


ggplot(crimes, aes(map_id = state)) +  geom_map(aes(fill = Murder), map = states_map) +
  expand_limits(x = states_map$long, y = states_map$lat)


ggplot(crimes, aes(map_id = state)) +  geom_map(aes(fill = Murder), map = states_map) +
  expand_limits(x = states_map$long, y = states_map$lat)+
  scale_fill_gradientn(colors=c('lightblue','darkblue'))


ggplot(crimesm, aes(map_id = state)) +    geom_map(aes(fill = value), map = states_map) +
  expand_limits(x = states_map$long, y = states_map$lat) +  
  facet_wrap( ~ variable)

ggplot(crimesm, aes(map_id = state)) +    geom_map(aes(fill = value), map = states_map) +
  expand_limits(x = states_map$long, y = states_map$lat) +  
  scale_fill_gradientn(colors=c('lightblue','darkblue'))+
  facet_wrap( ~ variable)

############################## Exercise ###################

#########
##set this R file dir as current dir
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path ))
olympicdata<-  read.csv( 'OlympicGames.csv'  ,  sep= ','  , header=T  )
df<-olympicdata
head(df)

resultsmedalsgold<-sqldf("select country, count(Medal) as gold from olympicdata where Medal=='gold' group by country ORDER BY -gold")
head(resultsmedalsgold)
world_map <- map_data("world")

gg<-ggplot(world_map, aes(map_id = region)) +
  geom_map(data=world_map, map = world_map)

gg +
  geom_map(data=resultsmedalsgold,aes(fill = gold,map_id = Country), map = world_map) +
  expand_limits(x = world_map$long, y = world_map$lat)

###we can use other projections using coord_map but we will need to install mapproj

g<-gg +
  geom_map(data=resultsmedalsgold,aes(fill = gold,map_id = Country), map = world_map) +
  expand_limits(x = c(-180,180), y = c(-80,80)) +
  coord_map("mercator")
g

g1 <- g + coord_map("gall",lat=45)
g1

g2 <- g + coord_map("gilbert")
g2



#########Questions


####1)	What country has won most Silver medals since 2000?
### Convert United States to USA to be in conformity of world map naming convention
olympicdata[olympicdata$Country == "United States", ]$Country = "USA"

countryMostSilverMedals<-sqldf("SELECT country, count(Medal) AS silver 
                                FROM olympicdata 
                                WHERE Medal=='silver' AND Year >= 2000 
                                GROUP BY country 
                                ORDER BY -silver") # first item on this dataset will be the one with most silver medals

# create extra column to find country with most silver medals
countryMostSilverMedals["HasMostSilverMedals"] = "No"
countryMostSilverMedals[1,"HasMostSilverMedals"] = "Yes"
countryMostSilverMedals[, "HasMostSilverMedals"] = as.factor(countryMostSilverMedals[, "HasMostSilverMedals"])
head(countryMostSilverMedals)
world_map <- map_data("world")

gg<-ggplot(world_map, aes(map_id = region)) +
  geom_map(data=world_map, map = world_map)

gg +
  geom_map(data=countryMostSilverMedals,
           aes(fill = silver,
               map_id = Country, 
               color = HasMostSilverMedals), 
           map = world_map) +
  expand_limits(x = world_map$long, 
                y = world_map$lat) + 
  scale_color_manual(values = c('Yes' = 'red', 'No' = NA)) +
  ggtitle("Total olympic silver medals per country")  

ggsave("1_Total olympic silver medals per country.pdf")

####2)	How is the gender balance amongst the United States gold medalist?
usaGoldMedalByGender<-sqldf("SELECT Gender, 
                                    count(Medal) as medals
                               FROM olympicdata 
                               WHERE Medal=='gold' 
                               AND (Gender == 'Men' OR Gender == 'Women') 
                               group by gender ORDER BY -medals")

usaGoldMedalByGender
ggplot(usaGoldMedalByGender, aes(x=Gender, y=medals, fill=Gender)) +
  geom_bar(stat="identity")+theme_minimal() + 
  scale_fill_manual(values = c('Men' = 'blue', 'Women' = 'red')) +
  ggtitle("Total olympic gold medals per gender in USA")  

ggsave("2_Total olympic gold medals per gender in USA.pdf")

####3)	What are the best sports for Sweden, USA, Austria and Switzerland?
#here I'll use total gold medals as criteria and 2 top sports
getCountry2TopSport <- function(countryName) {
  query = sprintf("SELECT Sport, 
                        Country,
                        count(Medal) as medals
                 FROM olympicdata 
                 WHERE Medal=='gold'
                 AND   Country = '%s'
                 GROUP BY Sport, Country ORDER BY -medals
                 LIMIT 2", countryName)
  return (sqldf(query))
  
}

swedenTopSports<-getCountry2TopSport('Sweden')

usaTopSports<-getCountry2TopSport('USA')

AustriaTopSports<-getCountry2TopSport('Austria')

SwitzerlandTopSports<-getCountry2TopSport('Switzerland')


#get a list of unique top sports to have an idea of what visualisation would work best
allTopSports = rbind(swedenTopSports, usaTopSports,AustriaTopSports, SwitzerlandTopSports)
uniqueListOfTopSports = sqldf("SELECT DISTINCT(Sport) 
                               FROM allTopSports")
uniqueListOfTopSports #5 top sports in total but all disjointed, I can't come up with a good map idea..


ggplot(swedenTopSports, aes(x=reorder(Sport, -medals), y=medals, fill=Sport)) +
  geom_bar(stat="identity")+theme_minimal() + 
  scale_fill_manual(values = c('Cross-Country Skiing' = 'blue', 'Speedskating' = 'red')) +
  ggtitle("Total of gold medals on Top Sports in Sweden")  

ggsave("3_1_Total of gold medals on Top Sports in Sweden.pdf")

ggplot(usaTopSports, aes(x=reorder(Sport, -medals), y=medals, fill=Sport)) +
  geom_bar(stat="identity")+theme_minimal() + 
  scale_fill_manual(values = c('Speedskating' = 'blue', 'Alpine Skiing' = 'red')) +
  ggtitle("Total of gold medals on Top Sports in USA")  

ggsave("3_2_Total of gold medals on Top Sports in USA.pdf")

ggplot(AustriaTopSports, aes(x=reorder(Sport, -medals), y=medals, fill=Sport)) +
  geom_bar(stat="identity")+theme_minimal() + 
  scale_fill_manual(values = c('Alpine Skiing' = 'blue', 'Figure Skating' = 'red')) +
  ggtitle("Total of gold medals on Top Sports in Austria")  

ggsave("3_3_Total of gold medals on Top Sports in Austria.pdf")

ggplot(SwitzerlandTopSports, aes(x=reorder(Sport, -medals), y=medals, fill=Sport)) +
  geom_bar(stat="identity")+theme_minimal() + 
  scale_fill_manual(values = c('Alpine Skiing' = 'blue', 'Bobsled' = 'red')) +
  ggtitle("Total of gold medals on Top Sports in Switzerland")  

ggsave("3_4_Total of gold medals on Top Sports in Switzerland.pdf")

