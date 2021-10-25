library(tidyverse)
library(spdplyr)
source('zip_ref.R')

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

# import population and CMS Home Health Agency data
pop = read_csv('./data/population.csv')
CMS_raw = read_csv('./data/HH_Provider.csv')

# drop unused columns and rename to better column names
CMS_raw = CMS_raw %>% 
  select(-contains(c('Footnote','Numerator','Denominator','Date',
                     'Offers','Observed','Lower','Upper','skin'))) %>%
  rename(Cert_num = `CMS Certification Number (CCN)`,
         Name = `Provider Name`,
         Own_type = `Type of Ownership`,
         Q_stars = `Quality of patient care star rating`,
         Timely_care = `How often the home health team began their patients' care in a timely manner`,
         Drug_edu = `How often the home health team taught patients (or their family caregivers) about their drugs`,
         Flu_shot = `How often the home health team determined whether patients received a flu shot for the current flu season`,
         Move_better = `How often patients got better at walking or moving around`,
         Bed_better = `How often patients got better at getting in and out of bed`,
         Bath_better = `How often patients got better at bathing`,
         Breathe_better = `How often patients' breathing improved`,
         Drug_better = `How often patients got better at taking their drugs correctly by mouth`,
         Admissions = `How often home health patients had to be admitted to the hospital`,
         ER_visits = `How often patients receiving home health care needed urgent, unplanned care in the ER without being admitted`,
         Timely_meds = `How often physician-recommended actions to address medication issues were completely timely`,
         DTC_rate = `DTC Risk-Standardized Rate`,
         DTC_compare = `DTC Performance Categorization`,
         PPR_rate = `PPR Risk-Standardized Rate`,
         PPR_compare = `PPR Performance Categorization`,
         Cost = `How much Medicare spends on an episode of care at this agency, compared to Medicare spending across all agencies nationally`,
         n_cases = `No. of episodes to calc how much Medicare spends per episode of care at agency, compared to spending at all agencies (national)`
         )

# Drop: GU (Guam), MP (Northern Mariana I's), PR, VI (Virgin I's)
CMS_raw = subset(CMS_raw, !(State %in% c('GU','MP','PR','VI')))

# Summarize by State, the # of Agencies & # of Cases in study
CMS_State = CMS_raw %>% group_by(State) %>%
  summarise(CMS_cases = sum(n_cases), CMS_n = n(), Cost = mean(Cost, na.rm = TRUE)) 
# mutate State name column for join
CMS_State = CMS_State %>% mutate(STNAME = st_name(State))
View(CMS_raw)

# join with population data
pop = left_join(pop,CMS_State,by='STNAME')


# ANALYSIS 1: Agency density
#-----------------------------------------------------------------------------
# calculate by state, the density of: 
#   HH Agencies per 100k total population
#   HH Agencies per 100k senior population
#   HH Agencies per 100k severely disabled
#   Agency Cases per 100k senior population
pop = pop %>% 
  mutate(per_POP = round(CMS_n*100000/POP,2),
         per_SEN = round(CMS_n*100000/SEN,2),
         per_DIS = round(CMS_n*100000/DIS,2),
         cases_SEN = round(CMS_cases*100000/SEN),)
View(pop)
# Export to csv
pop %>% write.csv('./data/density_analysis.csv',row.names = F)

# Use leaflet to map the density in each NYS county
library(leaflet)
library(geojsonio)
# Set value for the minZoom and maxZoom settings.
leaflet(options = leafletOptions(minZoom = 1, maxZoom = 14))

map_spdf <- geojsonio::geojson_read(("./states_geo.json"),what = "sp")
map_spdf = map_spdf %>% filter(STATE!='72') # remove PR

# join Agency and population data to spatial data
usmap = merge(map_spdf, 
              pop %>% 
                transmute(STATE,SEN,per_SEN,per_DIS,cases_SEN,Cost),
      by.x = "STATE", by.y = "STATE")

# calculate population density of SENIORS (seniors/sq Mile)
usmap = usmap %>% mutate(den_SEN = round(usmap$SEN /usmap$CENSUSAREA,2))

# Set Palette
pal_1 <- colorNumeric("viridis", NULL, reverse = T)
pal_2 <- colorNumeric("magma", NULL, reverse = T)
pal_3 <- colorNumeric("plasma", NULL, reverse = T)
pal_g <- colorNumeric(palette = "Greens",domain = usmap$Cost)

# initiate leaflet with ny spatial data
m <- leaflet(usmap) %>% 
  setView(-98.35, 39.7, zoom = 4) %>%
  addProviderTiles(providers$CartoDB.DarkMatterNoLabels)
  
# create map show function
mapshow <- function(c,p) {
  # params: 
  # c takes in target spatial.DF plot column
  # p specifies palette
  label_text = paste0(usmap$NAME, ": ",c)
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

# D.C. is an outlier in terms of Senior Population Density
us_noDC = usmap %>% filter(STATE!='11') # remove D.C.
mapshow(us_noDC$den_SEN,pal_2)

mapshow(usmap$per_SEN,pal_1)
mapshow(usmap$per_DIS,pal_1)
mapshow(usmap$cases_SEN,pal_3)
mapshow(usmap$Cost,pal_g)

