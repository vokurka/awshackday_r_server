
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
  output1 <- paste("Take taxi, it is cheaper and costs ",taxi_price," dollars",sep="")  
} else 
if (uber_price <= 0.8*taxi_price) 
{
  output1 <- paste("Take uber, it is cheaper and costs ",uber_price," dollars",sep="")
} else 
if (uber_pick_up_estimate < 10) take_taxi <- F 
{
  output1 <- paste("Take uber, the car will be here within 10 minutes. The price is ",uber_price," dollars",sep="")
}else output1 <- paste("Take taxi, the price is ", uber_price, sep="") 



# add weather info
rain_during_the_day #...secist logicky hodnoty

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


if (day_period=="morning")
{
  if (weather_am=="humid" & weather_pm=="humid")
    output<-"Use dryer, it will be a humid weather all day"
  else if (weather_am=="humid" & weather_pm=="sun")
    output<-"Postpone the washing for the afternoon, you can dry your clothes outside as there will be sunny weather"
  else if (weather_am=="sun" & weather_pm=="humid")
    output<-("You can wash now and dry your clothes outside, but do not forget to collect it, it will rain in the afternoon")
  else if (weather_am=="sun" & weather_pm=="sun")
    output <-("You can wash now and dry your clothes outside. Today will be a sunny day")
}
if (day_period=="afternoon")
{
  if (weather_pm=="sun")
    output<-"You can use the washing machine and dry your clothes outside. It will be a sunny afternoon"
  if (weather_pm=="humid")
    output<-"Use dryer, it will be a humid weather in the afternoon"
}
if (day_period=="night")
{
  if (weather_am=="humid" & weather_pm=="humid")
    output<-"Use dryer, it will be a humid all day tomorrow"
  else if (weather_am=="humid" & weather_pm=="sun")
    output<-"If you postpone the washing for tomorrow afternoon, you can dry your clothes outside."
  else if (weather_am=="sun" & weather_pm=="humid")
    output<-("You can dry your clothes outside tomorrow morning, but do not forget to collect it, it will be a humid weather in the afternoon")
  else if (weather_am=="sun" & weather_pm=="sun")
    output <-("You can dry your clothes outside tomorrow. It will be a sunny day")
}