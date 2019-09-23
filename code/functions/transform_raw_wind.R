# pressue unit bar = 10^5 pascal
# output of the fcn is using UTC datetime (standard recording)

# WIMDA: weather composite
# GPRMC: GPS composite; has the Airmar data quality indicator

# code example: how to extract wind
# wind1 <- read_lines(file = 'YN-data/airmar_data/Sep_28_2018_3201664_0183.LOG')
# Airmar_1 <- transform_wind(wind1) 

transform_raw_wind <- function(wind){
  
  library(stringr)
  wind_1 <- wind %>% as.data.frame(stringsAsFactors=FALSE) 
  colnames(wind_1) <- c('X') # give the column name: X
  
  # first check what NMEA strings we get
  # str_locate(wind_1[202, ], '\\$')
  NMEA_type <- wind_1 %>% filter(X!="")
  NMEA_summary <- lapply(NMEA_type, str_sub, 19, 23) %>% table()
  print(NMEA_summary)
  
  # find rows with GPRMC and WIMDA
  wind_GPRMC <- wind_1 %>% filter(str_detect(X, 'GPRMC')) 
  wind_WIMDA <- wind_1 %>% filter(str_detect(X, 'WIMDA')) 
  
  # separate the row based on the delimiter comma, then join them based on the Computer_DateTime(number in the beginning).
  
  wind_GPRMC_1 <- do.call('rbind', strsplit(wind_GPRMC$X, ',')) %>% as.data.frame(stringsAsFactors=FALSE) %>% as.tibble()
  wind_WIMDA_1 <- do.call('rbind', strsplit(wind_WIMDA$X, ',')) %>% as.data.frame(stringsAsFactors=FALSE) %>% as.tibble()
  
  # refine WIMDA
  wind_WIMDA_2 <- wind_WIMDA_1 %>% mutate(Computer_DateTime = lubridate::hms(str_sub(V1, 1, 8)), wd = as.numeric(V14), ws = as.numeric(V20), pressure = as.numeric(V4), air_temperature = as.numeric(V6))  %>% select(Computer_DateTime, wd, ws, pressure, air_temperature) %>% mutate(Computer_DateTime = as.character(Computer_DateTime))
  
  # refine GPRMC
  wind_GPRMC_2 <- wind_GPRMC_1 %>% mutate(Computer_DateTime = lubridate::hms(str_sub(V1, 1, 8)), UTC_Time = hms(paste(str_sub(V2, 1, 2), str_sub(V2, 3, 4), str_sub(V2, 5, 6), sep = ":")), Data_Quality = V3,  Veh_Speed = as.numeric(V8), UTC_Date = dmy(paste(str_sub(V10, 1, 2), str_sub(V10, 3, 4), str_sub(V10, 5, 6), sep = '/'))) %>% mutate(UTC_DateTime = ymd_hms(paste(UTC_Date, UTC_Time))) %>% mutate(Lat = as.numeric(str_sub(V4, 1, 2)) + as.numeric(str_sub(V4, 3, ))/60 , Lon = (as.numeric(str_sub(V6, 1, 3)) + as.numeric(str_sub(V6, 4, ))/60)* -1 )%>%  select(Computer_DateTime, UTC_DateTime, Lat, Lon, Data_Quality, Veh_Speed) %>% mutate(Computer_DateTime = as.character(Computer_DateTime))
  
  # join them based on Computer_DateTime
  Airmar <- wind_GPRMC_2 %>% inner_join(wind_WIMDA_2) %>% filter(Data_Quality == 'A') %>% dplyr::distinct(Computer_DateTime,  .keep_all = TRUE) %>% select(-Computer_DateTime) %>% distinct(UTC_DateTime, .keep_all = TRUE)

  return(Airmar)
}