library(tidyverse)

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


# Disability prevalence is used to estimate population with "Needs Assistance"
# Latest data from: Census 2010

#                     Males Females
# Less than 6 years   0     0
# 6 to 14 years       0.9   0.7
# 15 to 24 years      1.6   1.2
# 25 to 34 years      2.2   1.7
# 35 to 44 years      2.1   2.2
# 45 to 54 years      3.1   4.1
# 55 to 64 years      5.1   6.9
# 65 to 69 years      5.6   7.9
# 70 to 74 years      9.3   12.0
# 75 to 79 years      12.7  17.5
# 80 years and older  24.0  34.0

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
         -contains(c('19','20','29','30','39','40','49','50','59','60','84','85')))

colnames(pop)

#check: total of age bins = total population
n = sample(1:62,1)
(sum(pop[n,12:33]) == pop[n,7]) == T

#calc total senior (>65) population
pop = pop %>% mutate(SENIOR_TOT = AGE65PLUS_MALE+AGE65PLUS_FEM)

age_bin <- c(0,6,15,25,35,45,55,65,70,75,80,200)  # (n,n]
m_rates <- c(0,0.9,1.6,2.2,2.1,3.1,5.1,5.6,9.3,12.7,24) / 100
f_rates <- c(0,0.7,1.2,1.7,2.2,4.1,6.9,7.9,12,17.5,34) / 100



