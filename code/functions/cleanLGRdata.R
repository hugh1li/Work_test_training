# 09/16 change lag time to be 50 instead of 2 minutes coz we have the external pump.
# note the final DateTime is in UTC-4, 4 hrs behind the UTC. Matt did the setting in Hemisphere.

cleanLGRdata <- function(x, tz_default = 'Etc/GMT+4') {
  data <- read_tsv(file = x, col_names = FALSE, skip = 2, col_types = cols_only(X1 = col_character(), X2 = col_character(), X3 = col_character(), X4 = col_double(), X5 = col_double(), X7 = col_double(), X13 = col_double(), X17 = col_double()))
  if(ncol(data) == 5)
    stop("Error: Your dataframe is too short and do not have good rows inside. Drop the dat in excel and have a look.")
  data_ref <- data %>% select(Hem_GPS_Date = X1, Hem_GPS_Time = X2, GPS_code = X3, Lat = X4, Lon = X5, CH4 = X7, C2H2 = X13, H2O = X17)
  data_re <- data_ref %>% mutate(DateTime =paste(Hem_GPS_Date, Hem_GPS_Time)) %>% select(DateTime , Lat, Lon, CH4, C2H2, H2O) %>% filter(!is.na(CH4)) %>% filter(CH4 > 1.5) %>% mutate(DateTime = lubridate::mdy_hms(DateTime, tz = tz_default)) %>% mutate(DateTime_adjusted = DateTime - seconds(50)) # We first creat a new column DateTime_adjusted to link to corresponding CH4/C2H2/H2O concentrations.
  data_re2 <- data_re %>% select(DateTime, Lat, Lon) %>% inner_join(data_re[c('DateTime_adjusted', 'CH4', 'C2H2', "H2O")], by = c('DateTime' = 'DateTime_adjusted')) # We join two datetime colunmns (original Datetime with lat and lon, and Datetime_adjusted with pollutant concentrations.)
 return(data_re2)
}
