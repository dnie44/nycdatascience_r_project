library(tidyverse)
library(spdplyr)
source('helper.R')

# import population and Home Health Agency data
pop = read_csv('./data/population.csv')
hha = read_csv('./data/hh_agencies.csv')

# Summarize by State, the # of Agencies & # of Cases in study
hha_state = hha %>% group_by(State) %>%
  summarise(total_cases = sum(n_cases), 
            total_agncy = n(),
            avg_cost = round(mean(Cost, na.rm = TRUE),4)) 

# mutate State name column for join
hha_state = hha_state %>% mutate(STNAME = st_name(State))
View(hha_state)

# join with population data
pop = left_join(pop,hha_state,by='STNAME')


# ANALYSIS 1: Agency density
#-----------------------------------------------------------------------------
# calculate by state, the density of: 
#   HH Agencies per 100k total population
#   HH Agencies per 100k senior population
#   HH Agencies per 100k severely disabled
#   Agency Cases per 100k senior population
pop = pop %>% 
  mutate(per_POP = round(total_agncy*100000/POP,2),
         per_SEN = round(total_agncy*100000/SEN,2),
         per_DIS = round(total_agncy*100000/DIS,2),
         cases_SEN = round(total_cases*100000/SEN),)

pop = pop %>% #Rename District of Columbia to Washington D.C., length issue
  mutate(STNAME=replace(STNAME,STNAME=='District of Columbia','Washington D.C.'))
pop$STNAME = as.factor(pop$STNAME)

View(pop)

# Export to csv (may be used for plotting in shiny)
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
                transmute(STATE,SEN,per_SEN,per_DIS,cases_SEN,avg_cost),
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
  m %>% 
    addPolygons(color = 'white', smoothFactor = 0.5, weight = '1.5',
                fillOpacity = 1, fillColor = ~p(c), 
                highlightOptions = 
                  highlightOptions(color = "orange", weight = 2,
                                   bringToFront = TRUE),
                label = label_text,
                labelOptions = labelOptions(
                  style = list("font-weight" = "normal", padding = "1px 3px"),
                  textsize = "14px",
                  direction = "auto")) %>% 
    addLegend(position = "bottomleft", pal = p, values = ~c, 
              title = "Density", opacity = 1)
}

# D.C. is an outlier in terms of Senior Population Density
us_noDC = usmap %>% filter(STATE!='11') # remove D.C.
mapshow(us_noDC$den_SEN,pal_2)

mapshow(usmap$per_SEN,pal_1)
mapshow(usmap$per_DIS,pal_1)
mapshow(usmap$cases_SEN,pal_3)
mapshow(usmap$avg_cost,pal_g)

#------------------------------------------------------------------------------
# Plot sorted bar charts for better sense of ranking
#------------------------------------------------------------------------------

#Agency Density per 100,000 total residents
pop %>% #get top and bottom 5 states
  filter(dense_rank(per_POP) <= 5 | dense_rank(desc(per_POP)) <= 5) %>% 
  arrange(per_POP) %>% 
  mutate(STNAME=factor(STNAME, levels=STNAME)) %>% #updates factor levels
  ggplot(aes(x = per_POP, y = STNAME)) + 
  geom_segment(aes(xend=0 ,yend=STNAME), size = 1.5) +
  geom_point( size=5, color="#004885") +
  ylab("") + xlab("") +
  ggtitle("Top and Bottom 5 States", 
          subtitle = "Agency Density per 100,000 (Total Population)")

#Agency Density per 100,000 senior residents
pop %>% #get top and bottom 5 states
  filter(dense_rank(per_SEN) <= 5 | dense_rank(desc(per_SEN)) <= 5) %>% 
  arrange(per_SEN) %>% 
  mutate(STNAME=factor(STNAME, levels=STNAME)) %>% #updates factor levels
  ggplot(aes(x = per_SEN, y = STNAME)) + 
  geom_segment(aes(xend=0 ,yend=STNAME), size = 1.5) +
  geom_point( size=5, color="#004885") +
  ylab("") + xlab("") +
  ggtitle("Top and Bottom 5 States", 
          subtitle = "Agency Density per 100,000 (Senior Population)")

#Agency Density per 100,000 disabled residents
pop %>% #get top and bottom 5 states
  filter(dense_rank(per_DIS) <= 5 | dense_rank(desc(per_DIS)) <= 5) %>% 
  arrange(per_DIS) %>% 
  mutate(STNAME=factor(STNAME, levels=STNAME)) %>% #updates factor levels
  ggplot(aes(x = per_DIS, y = STNAME)) + 
  geom_segment(aes(xend=0 ,yend=STNAME), size = 1.5) +
  geom_point( size=5, color="#004885") +
  ylab("") + xlab("") +
  ggtitle("Top and Bottom 5 States", 
          subtitle = "Agency Density per 100,000 (Disabled Population)")
