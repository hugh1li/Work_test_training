library(tidyverse)
library(lubridate)
source('code/functions/transform_LGR_raw_data.R')

LGR <- cleanLGRdata(x = 'data/22082019-131702.dat')
summary(LGR)

write.csv(LGR, "temp/LGR_refined.csv")

