library(tidyverse)

####(1)####
# Clean population data and calculate desired population figures, 
# i.e. seniors, disabled population, grouped by sex, and export to csv.


# read in NYS population by county from census est. 2019
pop_raw = read_csv('./data/NYS_pop_2019.csv')
View(pop_raw)
dim(pop_raw)
colnames(pop_raw)

#filter only latest 2019 pop figures
pop_raw = pop_raw %>% filter(YEAR==12)

#remove TOT PLUS UNDER columns, recalc if needed later (except 85Plus)
pop_raw = pop_raw %>% select(-ends_with('_TOT'),
                             -contains(c('16PLUS','18PLUS',
                                         'UNDER','MEDIAN')))

#remove unused population bins
pop_raw = pop_raw %>% select(-starts_with(c('AGE513','AGE1417','AGE1824',
                                 'AGE1544','AGE2544','AGE4564')))

#check: total of age bins = total population
n = sample(1:62,1)
(sum(pop_raw[n,12:47]) == pop_raw[n,7]) == T


# Disability prevalence is used to estimate population with "Severely Disabled"
# Latest data from: Census 2010

#                     Males Females
# Less than 6 years   3.2   1.9
# 6 to 14 years       7.0   3.6
# 15 to 24 years      6.1   4.5
# 25 to 34 years      6.9   6.2
# 35 to 44 years      7.7   8.4
# 45 to 54 years      12.1  15.4
# 55 to 64 years      18.7  22.1
# 65 to 69 years      23.5  25.7
# 70 to 74 years      24.7  33.8
# 75 to 79 years      32.4  41.5
# 80 years and older  48.9  59.9

# first re-bin population columns to match prevalence columns
pop = pop_raw %>% mutate(AGE0514_FEM = AGE59_FEM+AGE1014_FEM,
                         AGE0514_MALE = AGE59_MALE+AGE1014_MALE,
                         AGE1524_FEM = AGE1519_FEM+AGE2024_FEM,
                         AGE1524_MALE = AGE1519_MALE+AGE2024_MALE,
                         AGE2534_FEM = AGE2529_FEM+AGE3034_FEM,
                         AGE2534_MALE = AGE2529_MALE+AGE3034_MALE,
                         AGE3544_FEM = AGE3539_FEM+AGE4044_FEM,
                         AGE3544_MALE = AGE3539_MALE+AGE4044_MALE,
                         AGE4554_FEM = AGE4549_FEM+AGE5054_FEM,
                         AGE4554_MALE = AGE4549_MALE+AGE5054_MALE,
                         AGE5564_FEM = AGE5559_FEM+AGE6064_FEM,
                         AGE5564_MALE = AGE5559_MALE+AGE6064_MALE,
                         AGE80PLUS_FEM = AGE8084_FEM+AGE85PLUS_FEM,
                         AGE80PLUS_MALE = AGE8084_MALE+AGE85PLUS_MALE
                         ) %>% 
  select(-starts_with(c('AGE59','AGE10')),
         -contains(c('19','20','29','30','39','40',
                     '49','50','59','60','84','85')))

# check: total of age bins = total population
n = sample(1:62,1)
(sum(pop[n,12:33]) == pop[n,7]) == T

colnames(pop)

# get female and male population column names for calculation
fem_bin = sort(colnames(pop %>% select(ends_with('_FEM'),
                                       -contains(c('POP','65PLUS')))))
male_bin = sort(colnames(pop %>% select(ends_with('_MALE'),
                                        -contains(c('POP','65PLUS')))))

# set prevalence rates for each bin
fem_rates <- c(1.9,3.6,16.3,4.5,6.2,8.4,15.4,22.1,40.6,25.7,33.8) / 100
male_rates <- c(3.2,7,13.1,6.1,6.9,7.7,12.1,18.7,31.4,23.5,24.7) / 100

# calculate disabled population for FEM
temp_disabled = data.frame(row.names = 1:nrow(pop)) # initate emtpy DF
# iter along columns multiplying prevalence rate
for (i in seq_along(fem_bin)) {
  x = pop[,fem_bin[i]] * fem_rates[i]
  temp_disabled = bind_cols(temp_disabled, x)
}
# sum row values into single column and bind to MAIN DF
temp_disabled = temp_disabled %>% transmute(DIS_FEM = round(rowSums(.)))
pop = bind_cols(pop,temp_disabled)

# calculate disabled population for MALE
temp_disabled = data.frame(row.names = 1:nrow(pop)) # initate emtpy DF
# iter along columns multiplying prevalence rate
for (i in seq_along(male_bin)) {
  x = pop[,male_bin[i]] * male_rates[i]
  temp_disabled = bind_cols(temp_disabled, x)
}
# sum row values into single column
temp_disabled = temp_disabled %>% transmute(DIS_MALE = round(rowSums(.)))
pop = bind_cols(pop,temp_disabled)

sum(pop$DIS_FEM)      #1,275,869
sum(pop$DIS_MALE)     #1,017,360

# Clean county values with gsub (remove ' county' from 'Queens county')
pop$CTYNAME = gsub(' County','',pop$CTYNAME)
pop = pop %>% rename(C_CODE = COUNTY, C_NAME = CTYNAME)

# Keep only desired columns and export to .csv
pop %>% 
  select(contains(
    c('C_','POPEST','65PLUS','Dis'))) %>%
  write.csv('./data/population.csv',row.names = F)

View(pop)


