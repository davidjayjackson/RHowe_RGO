## Author: David Jackson (davidjayjackon@gmail.com)
## Date Created: Nov. 26,2019
## Last update: 2019/11/28(DJJ)
##
library(data.table)
library(ggplot2)
library(lubridate)
# library(tidyverse)
library(tidyr)
library(dplyr)
library(purrr)
library(RSQLite)
library(plotly)
rm(list=ls())
##
# Mainly for 1874 - 1981
##
rgo_1 <-dir("A",full.names=T) %>% map_df(fread,sep=":",header=F)
rgo_1$Year <-substr(rgo_1$V1,1,4)
rgo_1$Month <-substr(rgo_1$V1,5,6)
rgo_1$Day <-substr(rgo_1$V1,7,8)
rgo_1$Time <-substr(rgo_1$V1,9,12)
rgo_1$csgcgt <-substr(rgo_1$V1,13,20)
rgo_1$X1 <-substr(rgo_1$V1,21,22)
rgo_1$noaa <-substr(rgo_1$V1,23,24)
rgo_1$X2 <-substr(rgo_1$V1,25,25)
rgo_1$oua <-substr(rgo_1$V1,26,29)
rgo_1$owsa <-substr(rgo_1$V1,30,34)
rgo_1$cua <-substr(rgo_1$V1,36,39)
rgo_1$cwsa <-substr(rgo_1$V1,41,44)
rgo_1$dcsd <-substr(rgo_1$V1,46,50)
rgo_1$pahn <-substr(rgo_1$V1,52,56)
rgo_1$cld <-substr(rgo_1$V1,58,62)
rgo_1$lns <-substr(rgo_1$V1,64,68)
rgo_1$pahn <-substr(rgo_1$V1,72,75)
##
rgo_1 <- rgo_1[,.(Year,Month,Day,csgcgt,cwsa,lns,cld)]
##
rgo_1$Year <- as.integer(rgo_1$Year)
rgo_1$Month <- as.integer(rgo_1$Month)
rgo_1$Day <- as.integer(rgo_1$Day)
rgo_1$cwsa <- as.integer(rgo_1$cwsa)
rgo_1$csgcgt   <- as.integer(rgo_1$csgcgt)
rgo_1$lns <- as.numeric(rgo_1$lns)
rgo_1$cld <- as.numeric(rgo_1$cld)
str(rgo_1)
##
## 1982 to 2016
##
rgo_2 <-dir("B",full.names=T) %>% map_df(fread,sep=":",header=F)
rgo_2$Year <-substr(rgo_2$V1,1,4)
rgo_2$Month <-substr(rgo_2$V1,5,6)
rgo_2$Day <-substr(rgo_2$V1,7,8)
rgo_2$Time <-substr(rgo_2$V1,9,12)
rgo_2$csgcgt <-substr(rgo_2$V1,13,20)
rgo_2$csgcgt   <- as.integer(rgo_2$csgcgt)
rgo_2$X1 <-substr(rgo_2$V1,21,22)
rgo_2$noaa <-substr(rgo_2$V1,23,24)
rgo_2$X2 <-substr(rgo_2$V1,25,25)
rgo_2$oua <-substr(rgo_2$V1,26,29)
rgo_2$owsa <-substr(rgo_2$V1,30,34)
rgo_2$cua <-substr(rgo_2$V1,36,39)
rgo_2$cwsa <-substr(rgo_2$V1,41,44)
rgo_2$dcsd <-substr(rgo_2$V1,46,50)
rgo_2$pahn <-substr(rgo_2$V1,52,56)
rgo_2$cld <-substr(rgo_2$V1,58,62)
rgo_2$lns <-substr(rgo_2$V1,64,68)
rgo_2$pahn <-substr(rgo_2$V1,72,75)
##

rgo_2$Year <- as.integer(rgo_2$Year)
rgo_2$Month <- as.integer(rgo_2$Month)
rgo_2$Day <- as.integer(rgo_2$Day)
rgo_2$cwsa <- as.integer(rgo_2$cwsa)
rgo_2$lns <- as.numeric(rgo_2$lns)
rgo_2$cld <- as.numeric(rgo_2$cld)
str(rgo_2)
##
rgo_2 <- rgo_2[,.(Year,Month,Day,csgcgt,cwsa,lns,cld)]
##  Combine rgo_1 and rgo_2
RGO <- rbind(rgo_1,rgo_2)
RGO$Ymd <- as.Date(paste(RGO$Year, RGO$Month, RGO$Day, sep = "-"))
RGO <- RGO %>% select(Ymd,Year,Month,Day,csgcgt,cwsa,lns,cld)
str(RGO)
## Create Noth/South Split
##
RGO$NS <- ifelse(RGO$lns >=0,"N","S")
north <- RGO %>% select(Ymd,cwsa,lns,cld) %>% 
  filter(!is.na(cwsa)  & lns >=0)
colnames(north) <- c("Ymd","ncwsa","nlns","ncld")

south <- RGO %>% select(Ymd,cwsa,lns,cld) %>% 
  filter(!is.na(cwsa)  & lns <=0)
colnames(south) <- c("Ymd","scwsa","slns","scld")
##
##
## combine north and south
##
RGOC <- merge(north,south,key=Ymd)
RGOC$Ymd <- as.Date(RGOC$Ymd)
## If you want to inlcude all of North and matching South
RGOC1 <- merge(north,south,key=Ymd,all.x=T)
RGOC1$Ymd <- as.Date(RGOC1$Ymd)
##
## Plot of cwsa,lns, and cld variables
##
plot_ly(RGO) %>% add_bars(x=~Ymd,y=~cwsa) %>% 
  layout(title="Rodney's Bar Chart")#
plot_ly(RGO) %>% add_lines(x=~Ymd,y=~cwsa) %>% 
  layout(title="Corrected Whole Spot Area")
#
plot_ly(RGO) %>% add_lines(x=~Ymd,y=~lns) %>% 
  layout(title="Latitude, South(-) and North(+)")
#
plot_ly(RGO) %>% add_lines(x=~Ymd,y=~cld) %>% 
  layout(title="Carrington Longitude in degrees")
##

##
## Create and insert data in sqlite3 db.
##
RGOC1$Ymd <- as.character(RGOC1$Ymd)
db <- dbConnect(SQLite(),dbname="RGO.sqlite3")
dbWriteTable(db,"rgoc1",RGOC1,row.names=FALSE,overwrite=TRUE)
dbListTables(db)
dbDisconnect(db)
##
report_RGO <- RGO %>% arrange(Ymd) %>% 
  select(Ymd,csgcgt,cwsa,lns,cld) %>%
  group_by(Ymd,csgcgt) %>% summarise(Cnt = n())

ggplot(data=north,aes(x=Ymd,y=nlns,col="blue")) + geom_line() +
  geom_line(data=south,aes(x=Ymd,y=slns,col="red"))
            
A <- RGOC %>% filter(Ymd >="2008-01-01" & Ymd <="2014-01-01")            
plot_ly(A,x=~Ymd,y=~ncwsa,type="bar",name="North") %>%
  add_trace(y=~scwsa,name="South") %>%
  layout(yaxis=list(title="Count",barmode="group"))



