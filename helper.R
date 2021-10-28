library(tidyverse)

#HELPER FUNCTIONS

# function to convert STATE CODE to State NAME, i.e. NY == New York
st_codes = read_csv('./data/State_codes.csv')
st_name = function(cs) {
  #takes in state codes (cs) and returns state names
  result <- c()
  for (c in cs) {
    result = c(result, st_codes %>% 
                 filter(Code == c) %>% 
                 select(State) %>% 
                 unlist())
  }
  result
}
st_name('DC') #--> "District of Columbia"


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
