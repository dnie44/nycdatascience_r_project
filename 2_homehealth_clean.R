library(tidyverse)

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

# raw CMS Home Health Agency data
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

View(CMS_raw)
# Export to csv
CMS_raw %>% write.csv('./data/hh_agencies.csv',row.names = F)
