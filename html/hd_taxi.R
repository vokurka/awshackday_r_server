
library(lubridate)
library(RMySQL)

mydb=dbConnect(MySQL(),
               host='awshackdaysingapore.cjz6dzilj07n.ap-southeast-1.rds.amazonaws.com',
               db='awshackdaysingapore',
               user='root',
               pass='ThisIsPasswordForDB',
               port=3306
)


tab_taxi_fares  <- dbReadTable(mydb, name='taxi_fares')
tab_uber_rides  <- dbReadTable(mydb, name='uber_rides')
tab_weather     <- dbReadTable(mydb, name='weather')

taxi_price <- tab_taxi_fares[1,1]
uber_price <- tab_uber_rides[1,1]
uber_pick_up_estimate <- tab_uber_rides[1,9]


# price differs by 20% or uber waiting time longer than 10 min.
if (taxi_price <= 0.8*uber_price) 
{
  output1 <- paste("Take taxi. It will cost ",taxi_price," dollars.",sep="")  
} else 
if (uber_price <= 0.8*taxi_price) 
{
  output1 <- paste("Take uber, it will cost ",uber_price," dollars. The car will be here in ",uber_pick_up_estimate," minutes.",sep="")
} else 
if (uber_pick_up_estimate < 10) 
{
  output1 <- paste("Take uber, the car will be here in ",uber_pick_up_estimate," minutes. The price is ",uber_price," dollars.",sep="")
} else output1 <- paste("Take taxi, the price is ", uber_price, sep="") 




# add weather info
time_of_travel <-  as.numeric(substr(as.character(Sys.time()),12,13))


if ( (time_of_travel <=5 & time_of_travel >=0) | 
       (time_of_travel <=23 & time_of_travel >= 18))
  day_period <- "night" 
if (time_of_travel <=11 & time_of_travel >=6)
  day_period <- "morning" 
if (time_of_travel <=17 & time_of_travel >=12)
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


if (day_period=="morning" & rain_am+rain_pm > 0)
{
  output2 <- paste(output1, "And do not forget to take an umbrella. It might rain during the day.")
} else
if (day_period=="afternoon" & rain_pm)
{
  output2 <- paste(output1, "And do not forget to take an umbrella. It might rain during afternoon.")  
} else
if (day_period=="night" & rain_night)
{
  output2 <- paste(output1, "And do not forget to take an umbrella. It might rain during the night.")
} else output2 <- output1

print(output2)

