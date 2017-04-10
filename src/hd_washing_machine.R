
install.packages("lubridate")
install.packages("RMySQL")
library(lubridate)
library(RMySQL)

mydb=dbConnect(MySQL(),
               host='awshackdaysingapore.cjz6dzilj07n.ap-southeast-1.rds.amazonaws.com',
               db='awshackdaysingapore',
               user='root',
               pass='ThisIsPasswordForDB',
               port=3306
)

tab_weather <- dbReadTable(mydb, name='weather')


# assuming washing time 1.5 hours
# find out when washing finished
time_washing_finished <- as.numeric(substr(as.character(Sys.time() + hours(1)+minutes(30)),12,13))

if ( (time_washing_finished <=5 & time_washing_finished >=0) | 
       (time_washing_finished <=23 & time_washing_finished >= 18))
  day_period <- "night" 
if (time_washing_finished <=11 & time_washing_finished >=6)
  day_period <- "morning" 
if (time_washing_finished <=17 & time_washing_finished >=12)
  day_period <- "afternoon"

weather_raw_am <- tab_weather[which(substr(tab_weather[,1],1,3)=='6 a'),10] 
# 10, protoze predpokladam central area

if (grepl("cloud", tolower(weather_raw_am)) + 
      grepl("thund", tolower(weather_raw_am)) + 
      grepl("rain", tolower(weather_raw_am))  +
      grepl("showe", tolower(weather_raw_am)) > 0 )
  weather_am <- "humid" else weather_am <- "sun"


weather_raw_pm <- tab_weather[which(substr(tab_weather[,1],1,3)=='mid'),10] 
# 10, protoze predpokladam central area

if (grepl("cloud", tolower(weather_raw_pm)) + 
      grepl("thund", tolower(weather_raw_pm)) + 
      grepl("rain", tolower(weather_raw_pm))  +
      grepl("showe", tolower(weather_raw_pm)) > 0 )
  weather_pm <- "humid" else weather_pm <- "sun"

# last update in morning -> 6 a, 6 p interests me, talking about today
# last update in the afternoon -> 6 a, 6 p interest me, talking about tomorrow


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
print(output)