library(tidyverse)

####(2)####
# Clean ZIP-to-COUNTY reference file
# Create a custom function to return county code or name

zips <- read_csv('./data/NYS_zip_county.csv')
zips = zips %>% 
  select(-contains(c('FIPS','File'))) %>% 
  rename(C_NAME = `County Name`, 
         C_CODE = `County Code`, 
         ZIP_CODE = `ZIP Code`)

lookup_county <- function(zip_code, wt=1) {
  # looks up county from zip code
  # using the zip reference database
  # parameter wt specifies return type: 
  #    1 for county NAME, 2 for county CODE
  result <- c()
  for (z in zip_code) {
    result = c(result, zips %>% 
                 filter(ZIP_CODE == z) %>% 
                 slice(1) %>%
                 select(wt) %>% 
                 unlist())
  }
  result
}