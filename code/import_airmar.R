library(tidyverse)
library(lubridate)
library(openair)
source('code/functions/transform_raw_wind.R')

wind_day1 <- read_lines('data/Aug_22_2019_3201664_0183.LOG')
wind_day1_re <- transform_wind(wind_day1)

write.csv(wind_day1_re, 'temp/wind_refined.csv')