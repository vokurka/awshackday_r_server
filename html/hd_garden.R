
library(lubridate)
library(RMySQL)

mydb=dbConnect(MySQL(),
               host='awshackdaysingapore.cjz6dzilj07n.ap-southeast-1.rds.amazonaws.com',
               db='awshackdaysingapore',
               user='root',
               pass='ThisIsPasswordForDB',
               port=3306
)

tab_weather     <- dbReadTable(mydb, name='weather')


now <- as.numeric(substr(as.character(Sys.time()),12,13))


if ( (now <=5 & now >=0) | 
       (now <=23 & now >= 18))
  day_period <- "night" 
if (now <=11 & now >=6)
  day_period <- "morning" 
if (now <=17 & now >=12)
  day_period <- "afternoon"

weather_raw_am <- tab_weather[which(substr(tab_weather[,1],1,3)=='6 a'),10] 
# 10, protoze predpokladam central area

if (  grepl("thund", tolower(weather_raw_am)) + 
        grepl("rain", tolower(weather_raw_am))  +
        grepl("showe", tolower(weather_raw_am)) > 0 )
  rain_am <-T else rain_am <- F 

weather_raw_pm <- tab_weather[which(substr(tab_weather[,1],1,3)=='Mid'),10] 
# 10, protoze predpokladam central area

if (  grepl("thund", tolower(weather_raw_pm)) + 
        grepl("rain", tolower(weather_raw_pm))  +
        grepl("showe", tolower(weather_raw_pm)) > 0 )
  rain_pm <-T else rain_pm <- F

weather_raw_night <- tab_weather[which(substr(tab_weather[,1],1,3)=='6 p'),10] 
# 10, protoze predpokladam central area

if (  grepl("thund", tolower(weather_raw_night)) + 
        grepl("rain", tolower(weather_raw_night))  +
        grepl("showe", tolower(weather_raw_night)) > 0 )
  rain_pm <-T else rain_night <- F


# last update in morning -> morning, afternoon interesting
# last update in the afternoon -> night interesting


if (day_period=="morning" & rain_am+rain_pm+rain_night> 0)
{
  output <- "You do not need to water your garden, it will rain today."
} else
  if (day_period=="afternoon" & rain_pm+rain_night >0)
  {
    output <- "You do not need to water your garden, it will rain today."  
  } else
    if (day_period=="night" & rain_night)
    {
      output <- "You do not need to water your garden, it will rain tonight."
    } else output <- "No rain is coming soon, you need to water your garden."


print(output)
