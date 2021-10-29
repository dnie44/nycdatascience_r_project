library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(dashboardthemes)
library(tidyverse)
library(spdplyr)
library(data.table)
library(leaflet)
library(geojsonio)
source('SQLhelper.R')

# DEPLOY/UPDATE USING "rsconnect::deployApp('~/bootcamp/r_project/homehealth')"

leaflet(options = leafletOptions(minZoom = 1, maxZoom = 14))

map_spdf <- geojsonio::geojson_read(("./states_geo.json"),what = "sp")
map_spdf = map_spdf %>% filter(STATE!='72') # remove PR
pop = readr::read_csv('./density_analysis.csv')

# join Agency and population data to spatial data
usmap = merge(map_spdf, 
              pop %>% 
                transmute(STATE,SEN,per_SEN,per_DIS,cases_SEN,avg_cost),
              by.x = "STATE", by.y = "STATE")

# calculate population density of SENIORS (seniors/sq Mile)
usmap = usmap %>% mutate(den_SEN = round(usmap$SEN /usmap$CENSUSAREA,2))
# D.C. is extreme outlier
usmap$den_SEN[9] = max(usmap$den_SEN[-9]) + 2

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

#------------------------------------------------------------------------------