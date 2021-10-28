library(tidyverse)
source('helper.R')

# read in raw CMS Home Health Agency general data
CMS_raw = read_csv('./data/HH_Provider.csv')

# drop unused columns and rename to better column names
CMS_raw = CMS_raw %>% 
  select(-contains(c('Footnote','Numerator','Denominator','Categorization',
                     'Date','Offers','Observed','Lower','Upper','skin'))) %>%
  rename(Cert_num = `CMS Certification Number (CCN)`,
         Name = `Provider Name`,
         Own_type = `Type of Ownership`,
         Star_rating = `Quality of patient care star rating`,
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
         PPR_rate = `PPR Risk-Standardized Rate`,
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
  rename(Professionalism = `Percent of patients who reported that their home health team gave care in a professional way`,
         Communication = `Percent of patients who reported that their home health team communicated well with them`,
         Medication = `Percent of patients who reported that their home health team discussed medicines, pain, and home safety with them`,
         High_rating = `Percent of patients who gave their home health agency a rating of 9 or 10 on a scale from 0 (lowest) to 10 (highest)`,
         Recommendation = `Percent of patients who reported YES, they would definitely recommend the home health agency to friends and family`,
         Cert_num = `CMS Certification Number (CCN)`)

# Filter out rows that have 'Not Avail' as every column value
CMS_survey = CMS_survey %>% filter(rowSums(CMS_survey[,2:6]=='Not Available')!=5)

# Merge survey data into CMS_raw
CMS_survey$Cert_num = as.numeric(CMS_survey$Cert_num)
CMS_raw = left_join(CMS_raw,CMS_survey,by='Cert_num')

# Filter out rows from final merged data that have more than 14 NaN
CMS_raw = CMS_raw %>% filter(rowSums(is.na(CMS_raw))<15)

dim(CMS_raw) #8709 agencies

# see summary for number of agencies per state
summary(CMS_raw %>% group_by(State) %>% summarise(n()))
# Sample sizes for each state differ drastically

# see summary for number of agencies per ownership Type
unique(CMS_raw %>% group_by(Own_type) %>% summarise(n()))
#1 GOVERNMENT - COMBINATION GOVT & VOLUNTARY       17
#2 GOVERNMENT - LOCAL                             127
#3 GOVERNMENT - STATE/COUNTY                      220
#4 PROPRIETARY                                   6828
#5 VOLUNTARY NON-PROFIT - OTHER                   514
#6 VOLUNTARY NON-PROFIT - PRIVATE                 715
#7 VOLUNTARY NON PROFIT - RELIGIOUS AFFILIATION   283

#Lets re-bin into 3 Types, GOVERNMENT, PROPRIETARY, NONPROFIT
CMS_raw$Own_type = CMS_raw$Own_type %>% substr(1,1)
CMS_raw = CMS_raw %>% mutate(Own_type = replace(Own_type, Own_type=='G','Government'),
                             Own_type = replace(Own_type, Own_type=='P','Private'),
                             Own_type = replace(Own_type, Own_type=='V','Non-profit'))
unique(CMS_raw %>% group_by(Own_type) %>% summarise(n()))
#1 Government   364
#2 Non-profit  1512
#3 Private     6828

# Reorder columns for convenience during EDA
# Interested in Cost, Star rating, and DTC/PPR rate as target dependent vars
colnames(CMS_raw)
CMS_raw = CMS_raw %>% relocate(n_cases, .before = Star_rating)
CMS_raw = CMS_raw %>% relocate(Cost, .before = Star_rating)
CMS_raw = CMS_raw %>% relocate(PPR_rate, .after = Star_rating)
CMS_raw = CMS_raw %>% relocate(DTC_rate, .after = Star_rating)
# Export to csv "hh_data.csv"
# This is data to be used for Agency Outcomes and Patient Experience analysis
CMS_raw %>% write.csv('./data/hh_data.csv',row.names = F)

