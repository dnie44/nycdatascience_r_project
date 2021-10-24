library(tidyverse)
library(spdplyr)
source('zip_ref.R')

# import population and general facility data
pop = read_csv('./data/population.csv')
NYS_raw = read_csv('./data/ALL_HHA_NYS.csv')

# summarize # of Agencies per county (includes CMS certfd and non-certfd)
HHA_CNTY = NYS_raw %>% group_by(`Facility County`) %>% 
  summarise(HHA_n = n()) %>% rename(C_NAME = `Facility County`)

# Chance Saint to St. for St. Lawrence County
HHA_CNTY$C_NAME = gsub('Saint','St.',HHA_CNTY$C_NAME)

# join with population data
Agency_dens = left_join(pop,HHA_CNTY,by='C_NAME')

# read in CMS Agency data-set (incl only CMS certfd)
CMS_raw = read_csv('./data/HH_Provider.csv')
# filter only NY STATE and drop unused columns
CMS_raw = CMS_raw %>% 
  filter(State=='NY') %>% 
  select(-contains(c('Footnote','Numerator','Denominator',
                     'Observed','Lower','Upper','skin'))) %>%
  rename(n_cases = `No. of episodes to calc how much Medicare spends per episode of care at agency, compared to spending at all agencies (national)`)


# use zip code to determine County, then summarize # of Agencies & # of CASES
HHA_CNTY = CMS_raw %>% mutate(C_NAME = lookup_county(ZIP)) %>% 
  group_by(C_NAME) %>%
  summarise(CMS_cases = sum(n_cases), CMS_n = n())

# join with population data
Agency_dens = left_join(Agency_dens,HHA_CNTY,by='C_NAME')

# calculate by county, the density of: 
#   Agencies per 100k total population
#   Agencies per 100k senior population
#   Agencies per 100k severely disabled
Agency_dens = Agency_dens %>% 
  mutate(HHA_p100k = round(HHA_n*100000/POPESTIMATE,2),
         HHA_pSEN = round(HHA_n*100000/(AGE65PLUS_FEM+AGE65PLUS_MALE),2),
         HHA_pDIS = round(HHA_n*100000/(DIS_FEM+DIS_MALE),2))

# Use leaflet to map the density in each NYS county
library(leaflet)
library(rgdal)
# Set value for the minZoom and maxZoom settings.
leaflet(options = leafletOptions(minZoom = 0, maxZoom = 18))

nycounties <- rgdal::readOGR("./nycounty_geojson.json")

# join plot data to spatial data: plot HHA_p100k by county
ny = merge(nycounties, 
      Agency_dens %>% 
        transmute(C_CODE,A_pop=HHA_p100k,
                  A_sen=HHA_pSEN,
                  A_dis=HHA_pDIS,
                  pop_SEN=AGE65PLUS_FEM+AGE65PLUS_MALE),
      by.x = "COUNTY", by.y = "C_CODE")

# calculate population density of SENIORS (seniors / census area)
ny = ny %>% transmute(den_SEN = round(ny$pop_SEN / ny$CENSUSAREA,2))

# Set Palette
pal_1 <- colorNumeric("viridis", NULL, reverse = T)
pal_2 <- colorNumeric("magma", NULL, reverse = T)

# initiate leaflet with ny spatial data
m <- leaflet(ny) %>% addProviderTiles(providers$CartoDB.DarkMatterNoLabels)

# create map show function
mapshow <- function(c,p) {
  # params: 
  # c takes in target spatial.DF plot column
  # p specifies palette
  label_text = paste0(ny$NAME, ": ",c)
  m %>% addPolygons(color = 'white', smoothFactor = 0.5, weight = '1.5',
                    fillOpacity = 1, fillColor = ~p(c), 
                    highlightOptions = highlightOptions(color = "orange", weight = 2,
                                                        bringToFront = TRUE),
                    label = label_text,
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "1px 3px"),
                      textsize = "14px",
                      direction = "auto"))
}

mapshow(ny$den_SEN,pal_2)
mapshow(ny$A_pop,pal_1)
mapshow(ny$A_sen,pal_1)
mapshow(ny$A_dis,pal_1)
