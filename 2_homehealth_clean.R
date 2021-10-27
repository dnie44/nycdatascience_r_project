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

# read in raw CMS Home Health Agency general data
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

dim(CMS_raw) #11,131 agencies
# Export Agency Data for Density Calculation: "hh_agencies.csv"
CMS_raw %>% write.csv('./data/hh_agencies.csv',row.names = F)
# This should be the full list of Agencies certified with the CMS, before filtering out 
# those with NaN or Not Avail survey data

#--------------------------------------------------------------------------------------------------

# read in raw CMS Home Health Survey of Patient Experience Data
CMS_survey = read_csv('./data/HHCAHPS_Provider.csv')

# Keep (select) only used columns and rename to better names
CMS_survey = CMS_survey %>% select(-contains(c('Footnote','Star Rating','Surveys','Response'))) %>% 
  rename(prof_pct = `Percent of patients who reported that their home health team gave care in a professional way`,
         comm_pct = `Percent of patients who reported that their home health team communicated well with them`,
         med_pct = `Percent of patients who reported that their home health team discussed medicines, pain, and home safety with them`,
         rating_pct = `Percent of patients who gave their home health agency a rating of 9 or 10 on a scale from 0 (lowest) to 10 (highest)`,
         rcmend_pct = `Percent of patients who reported YES, they would definitely recommend the home health agency to friends and family`,
         Cert_num = `CMS Certification Number (CCN)`)

# Filter out rows that have 'Not Avail' as every column value
CMS_survey = CMS_survey %>% filter(rowSums(CMS_survey[,2:6]=='Not Available')!=5)

# Merge survey data into CMS_raw
CMS_survey$Cert_num = as.numeric(CMS_survey$Cert_num)
CMS_raw = left_join(CMS_raw,CMS_survey,by='Cert_num')

# Filter out rows from final merged data that have more than 14 NaN
CMS_raw = CMS_raw %>% filter(rowSums(is.na(CMS_raw))<15)

dim(CMS_raw) #8704 agencies
# Export to csv "hh_data.csv"
# This is data to be used for Agency Outcomes and Patient Experience analysis
CMS_raw %>% write.csv('./data/hh_data.csv',row.names = F)

