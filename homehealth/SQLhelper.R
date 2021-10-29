library(tidyverse)
library(RSQLite)

#------------------------------------------------------------------------------
# function to convert State NAME to State CODE, i.e. NY == New York
st_codes = read_csv('./State_codes.csv')
st_name = function(s) {
  #takes in state codes (cs) and returns state names
  st_codes %>% filter(State == s) %>% 
                 select(Code) %>% 
                 unlist()
}

#------------------------------------------------------------------------------

# Function for querying data in Shiny
dbConn <- function(session, dbname) {
  # setup connection
  conn = dbConnect(drv=SQLite(),dbname=dbname)
  
  # disconnect database when session ends
  session$onSessionEnded(function() {
    dbDisconnect(conn)
  })
  
  # return connection
  conn
}

dbGetData <- function(conn, tblname, st) {
  ## filter by month and day
  query <- paste0('SELECT Name, Address, City, Phone, Own_type, Star_rating FROM ',
                 tblname,
                 ' WHERE State = ','"',st,'"')
  ## database query returns a data.frame
  as.data.table(dbGetQuery(conn = conn,
                           statement = query))
}