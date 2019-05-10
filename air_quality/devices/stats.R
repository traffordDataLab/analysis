library(ggplot2) ; library(tidyverse) ; library(lubridate) ; library(hms)

source("https://trafforddatalab.github.io/assets/theme/ggplot2/theme_lab.R")

theme_set(theme_lab())

#device 1: LAB
#device 2: HP

flowDataLab <- read_csv("data/device_lab/user_measures_652975_2.csv")%>%
  select(-c(`AQI NO2`, `AQI PM 10`, `AQI PM 25`, `AQI VOC`))%>%
  filter(between(date,ymd_hms("2019-02-11 10:00:00"),ymd_hms("2019-02-15 18:00:00")))%>%
  gather(key, value,-date)%>%
  mutate(device="device1")

flowDataHP <- read_csv("data/device_hp/user_measures_612660_1.csv")%>%
  select(-c(`AQI NO2`, `AQI PM 10`, `AQI PM 25`, `AQI VOC`))%>%
  filter(between(date,ymd_hms("2019-02-11 10:00:00"),ymd_hms("2019-02-15 18:00:00")))%>%
  gather(key, value,-date)%>%
  mutate(device="device2")

flowData <- rbind(flowDataLab, flowDataHP)

flowDataLapse <- flowData %>%
  filter(between(date,ymd_hms("2019-02-15 11:00:00"),ymd_hms("2019-02-15 16:00:00")))

flowDataPlots<- flowDataLapse %>% mutate(date=format(flowDataLapse$date,format='%Y-%m-%d %H:%M')) %>%
  spread(device,value)

corr <- flowDataPlots %>% group_by(key) %>% summarise(r = cor(device2, device1, use='complete.obs'))

ggplot(flowDataPlots, aes(x = `device2`, y = `device1`)) +
  geom_point(aes(group = 1), size = 1, colour = "#fc6721") +
  facet_wrap(~key, scales = "free")

ggsave(file = "scatter.png", width = 6, height = 5)

#sumstats

sumStats <- flowDataLapse %>% group_by(device, key) %>%
  na.omit() %>%
  summarise(mean = mean(`value`), median = median(value), min = min(value), max = max(value), sd = sd(value), variance = var(value))%>%
  group_by(key)

intSenVar <- sumStats %>% group_by(key) %>% summarise(isv = ((max(mean)-min(mean))/mean(mean))*100)

#boxplot and time series

ggplot(flowDataLapse, aes(x = device, y=value, fill=device)) +
  geom_boxplot() +
  facet_wrap(~key, scales = "free")+ theme(legend.position = "none")

ggsave(file = "boxplot.png", width = 6, height = 5)

ggplot(flowDataLapse, aes(x = `date`, y = `value`, colour = device)) +
  geom_line(size = 1) +
  facet_wrap(~key, scales = "free")

ggsave(file = "timeSeries.png", width = 6, height = 5)

#hourly rate 

hourlyRate<- flowDataPlots %>%
  group_by(lubridate::hour(as.POSIXct(date,format = "%Y-%m-%d %H:%M")), key) %>%
  summarise(device1=mean(`device1`, na.rm = TRUE), device2=mean(`device2`, na.rm = TRUE)) %>%
  gather(device, mean, device1:device2) %>%
  ungroup()

colnames(hourlyRate)[1] <- "hour"



#station conversion 
#Data downloaded from https://www.airqualityengland.co.uk/site/latest?site_id=TRAF

station <- read_csv("https://www.airqualityengland.co.uk/assets/downloads/2019-02-15-190501121116.csv",skip=5)%>%filter(between(`End Time`,as.hms("11:00:00"),as.hms("15:00:00")))%>%mutate(hour=11:15)%>%select(hour, PM10, NO2)%>%rename(`PM 10`=PM10, NO2ugm3=NO2)

#Temperature and Pressure from Met Office Observational Site Rostherne No 2  http://wow.metoffice.gov.uk/observations/details/20190215eqwdofjtdre6ubuhyyb96sc89w
stationTemp <-  data_frame(hour = 11:15, mean = c(9.5, 10.5, 11.9, 12.5, 13.0))%>% mutate(device="sta",key="temp")

stationPress <-  data_frame(hour = 11:15, mean = c(1024, 1023, 1023, 1022, 1021))%>% mutate(device="sta",key="press")

#convertion to ppb for NO2

stationConv <- station %>% mutate(NO2ppb=NO2ugm3/(46.01/(22.41*((stationTemp$mean+273)/273)*(1013/stationPress$mean))))%>%select(hour,`PM 10`,NO2=NO2ppb)%>%mutate(device="station")%>%gather(key,mean,`PM 10`:NO2)

hourlyRateST <- hourlyRate %>% filter (key %in% c("NO2","PM 10")) %>%
  rbind(stationConv)

#Plot station mean
ggplot(hourlyRateST, aes(x = `hour`, y = `mean`, colour = device)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  facet_wrap(~key, scales = "free")

ggsave(file = "stationMean.png", width = 6, height = 5)


#Rsquared Lab

corrSTLab <- hourlyRateST %>% spread(device,mean)%>%
  group_by(key) %>%
  summarise(R = cor(device1, station, use='complete.obs'),RS = cor(device1, station, use='complete.obs')^2, RMSE=sqrt(mean((device1 - station)^2, na.rm = TRUE)), MAE=mean(abs(device1 - station), na.rm = TRUE))

#Rsquared HP
corrSTHP <- hourlyRateST %>% spread(device,mean)%>%
  group_by(key) %>%
  summarise(R = cor(device2, station, use='complete.obs'),RS = cor(device2, station, use='complete.obs')^2, RMSE=sqrt(mean((device2 - station)^2, na.rm = TRUE)), MAE=mean(abs(device2 - station), na.rm = TRUE))



