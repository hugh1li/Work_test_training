library(tidyverse)
library(lubridate)
source('code/functions/cleanLGRdata.R')

LGR <- cleanLGRdata(x = 'data/22082019-131702.dat')
summary(LGR)

write.csv(LGR, "LGR_refined.csv")

