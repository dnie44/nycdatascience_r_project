library(tidyverse)
source('zip_ref.R')

# import population and general facility data
pop = read_csv('./data/population.csv')
NYS_raw = read_csv('./data/ALL_HHA_NYS.csv')

# summarize # of Agencies per county (includes CMS certfd and non-certfd)
HHA_CNTY = NYS_raw %>% group_by(`Facility County`) %>% 
  summarise(HHA_n = n()) %>% rename(C_NAME = `Facility County`)

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

Agency_dens %>%

View(CMS_raw)
View(Agency_dens)
