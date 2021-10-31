library(tidyverse)
library(ggridges)
source('helper.R')
#------Anti-Aliased Graphs on Windows-----------
library('Cairo')
CairoWin()
#ggsave(g, filename = 'temp.png', dpi = 300, type = 'cairo',
#width = 8, height = 4, units = 'in')
#-----------------------------------------------

data = read_csv('./data/hh_data.csv')
colnames(data)

#Explore Star_rating Differences
star_data = data %>% 
  group_by(Star_rating) %>% 
  summarise(count = n(),
            avg_cost = round(mean(Cost, na.rm = T),3),
            avg_Adm = round(mean(Admissions, na.rm = T),3),
            avg_DTC = round(mean(DTC_rate, na.rm = T),3),
            avg_PPR = round(mean(PPR_rate, na.rm = T),3),
            avg_DrugEdu = round(mean(Drug_edu, na.rm = T),3),
            avg_MoveBetter = round(mean(Move_better, na.rm = T),3),
            avg_BedBetter = round(mean(Bed_better, na.rm = T),3),
            avg_BathBetter = round(mean(Bath_better, na.rm = T),3),
            avg_BreatheBetter = round(mean(Breathe_better, na.rm = T),3),
            avg_DrugBetter = round(mean(Drug_better, na.rm = T),3),
            avg_TimelyCare = round(mean(Timely_care, na.rm = T),3),
            avg_TimelyMeds = round(mean(Timely_meds, na.rm = T),3),
            avg_prof = mean(Professionalism, na.rm = T),
            avg_comm = mean(Communication, na.rm = T),
            avg_recomm = mean(Recommendation, na.rm = T)) %>% 
  mutate(pct = count/sum(count)) %>% 
  relocate(pct, .after = count)

# Rename NA as "Unrated" and set graphing order
star_data$Star_rating = star_data$Star_rating %>% replace_na('Unrated')
#Reorder row so Unrated comes first
star_data = star_data[c(10,1:9),]
star_data$Star_rating = factor(star_data$Star_rating, levels=unique(star_data$Star_rating))

colnames(star_data)
star_data %>% write.csv('./data/star_data.csv')

# Distribution of Star rating agencies
star_data %>% mutate(c = ifelse(Star_rating=='Unrated','yes','no')) %>% 
  ggplot(aes(x = pct, y = Star_rating)) +
  geom_col(aes(fill = c), color = 'black', show.legend = FALSE) +
  scale_fill_manual(values = c('yes' = '#3D3877', 'no' = '#CCAC00')) +
  ylab('Star Rating') + xlab('Distribution (%)')

# Star rating performance charts  - COST
star_data %>% mutate(c = ifelse(Star_rating=='Unrated','yes','no')) %>% 
  ggplot(aes(x = avg_cost, y = Star_rating)) +
  geom_col(aes(fill = c), color = 'black', show.legend = FALSE) +
  scale_fill_manual(values = c('yes' = '#3D3877', 'no' = '#CCAC00')) +
  ylab('Star Rating') + xlab('Average Cost (ratio vs. National rates)')

# Star rating performance charts  - DTC rate
star_data %>% mutate(c = ifelse(Star_rating=='Unrated','yes','no')) %>% 
  ggplot(aes(x = avg_DTC, y = Star_rating)) +
  geom_col(aes(fill = c), color = 'black', show.legend = FALSE) +
  scale_fill_manual(values = c('yes' = '#3D3877', 'no' = '#CCAC00')) +
  ylab('Star Rating') + xlab('average Discharge to Community rate')

# Star rating performance charts  - Patient Experience
star_data %>% mutate(c = ifelse(Star_rating=='Unrated','yes','no')) %>% 
  ggplot(aes(x = avg_PtExp, y = Star_rating)) +
  geom_col(aes(fill = c), color = 'black', show.legend = FALSE) +
  scale_fill_manual(values = c('yes' = '#3D3877', 'no' = '#CCAC00')) +
  ylab('Star Rating') + xlab('average Patient Experience survey scores')



#Analysis of COST differences between Ownership Types
#-------------------------------------------------------------------------------
#Plot Density
summary(data$Cost)
data %>% ggplot(aes(x = Cost, y = Own_type, group = Own_type)) + 
  geom_density_ridges(quantile_lines = TRUE, 
                      quantiles = c(0.025, 0.5, 0.975),
                      alpha = 0.9, size=0.75, fill = '#3D3877') + 
  ylab('') + xlab('Agency Cost (ratio vs. National average)') + 
  theme(legend.position = "none") + xlim(0.5,1.7)

# Sizes for each type still differ
bartlett.test(data$Cost ~ data$Own_type)  # p-val < 0.0001
#and we do not pass Bartlett Test to satisfy homogeneity of variances

#ANOVA on mean Costs
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(data$Cost ~ data$Own_type))
# difference in means is significant ***, reject nullhyp


#Analysis of Star Rating differences between Ownership Types
#-------------------------------------------------------------------------------
#Box Plot
data %>% ggplot(aes(x = Star_rating, y = Own_type, group = Own_type)) + 
  geom_boxplot() +
  ylab('') + theme(legend.position = "none")

# Sizes for each type still differ
bartlett.test(data$Star_rating ~ data$Own_type)  # p-val < 0.0001
#and we do not pass Bartlett Test to satisfy homogeneity of variances
summary(aov(data$Star_rating ~ data$Own_type))

#Analysis of DTC rate of HH Agency differences between Ownership Types
#-------------------------------------------------------------------------------
#Plot Density
data %>% ggplot(aes(x = DTC_rate^3, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      alpha = 0.9, size=0.75, fill = '#3D3877') + 
  ylab('') + xlab('Discharge to Community rates (x^3 transformed)') + 
  theme(legend.position = "none")

bartlett.test(data$DTC_rate^3 ~ data$Own_type)  # p-val < 0.0001
#ANOVA on mean DTC rate
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(data$DTC_rate^3 ~ data$Own_type))
# difference in means is significant ***, reject nullhyp


#Analysis of Admissions of HH Agency differences between Ownership Types
#-------------------------------------------------------------------------------

#Plot Density
data %>% ggplot(aes(x = Admissions, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      alpha = 0.9, size=0.75, fill = '#3D3877') + 
  ylab('') + xlab('Acute care Admission rates') + 
  theme(legend.position = "none") + xlim(0,40)

bartlett.test(data$Admissions ~ data$Own_type)  # p-val < 0.0001

#ANOVA on mean Admissions rate
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(data$Admissions ~ data$Own_type))
# difference in means is significant ***, reject nullhyp


################################################################################
# Bivariate Analysis
# Corr matrix 

# Correlation Matrix
cor(data[,9:29], use = "complete.obs")

# Customize upper panel of scatter matrix
upper.panel<-function(x, y){
  points(x,y, pch=19, col = alpha('#3D3877', 0.2))
  r <- round(cor(x, y, use = "complete.obs"), digits=2)
  txt <- paste0('corr: ',r)
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  text(0.5, 0.9, txt, cex=2)
}

colnames(data)
pairs(data[,10:14], lower.panel = NULL, 
      upper.panel = upper.panel)  #Cost vs 10-14


#------------------------------------------------------------------------------
# LINEAR REGRESSION (y = Acute Care Admissions)
reg_data = data %>% select(-c('State','Cert_num','Name','Address','City',
                              'ZIP','Phone','ER_visits','DTC_rate','PPR_rate',
                              'High_rating','Recommendation'))
reg_data = reg_data %>% drop_na() # remove rows with ANY NaN
reg_data$Star_rating = as.factor(reg_data$Star_rating)

# Prepare stepwise feature selection
model.saturated = lm(Admissions ~ ., data = reg_data) #With All Features
model.empty = lm(Admissions ~ 1, data = reg_data)     #With Intercept ONLY
scope = list(lower = formula(model.empty), upper = formula(model.saturated))

library(MASS) #The Modern Applied Statistics library
library(car) #Companion to applied regression
forwardBIC = step(model.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data)), )

summary(forwardBIC)
plot(forwardBIC)
vif(forwardBIC)    # Remove Star_rating: VIF = 8.693666
confint(forwardBIC)

# Again without Star rating
reg_data = reg_data[-4]
model.saturated = lm(Admissions ~ ., data = reg_data) #With All Features
model.empty = lm(Admissions ~ 1, data = reg_data)     #With Intercept ONLY
scope = list(lower = formula(model.empty), upper = formula(model.saturated))

forwardBIC = step(model.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data)), )
summary(forwardBIC) # Only Cost and Ownership were selected
plot(forwardBIC)  #Outlier spotted (Row 3442)
vif(forwardBIC)
confint(forwardBIC)

# remove outlier row 3442
reg_data = reg_data[-3442,]
model.final = lm(Admissions ~ + Cost + Own_type, data = reg_data)
summary(model.final)
plot(model.final)
vif(model.final)
confint(model.final)


#Constructing confidence and prediction bands for the scope of our data
# SIMPLE Admissions vs Costs
model.simple = lm(Admissions ~ +Cost, data = reg_data)
summary(model.simple)
plot(model.simple)

newdata = data.frame(Cost = 
                       seq(min(reg_data$Cost)-0.1, 
                           max(reg_data$Cost)+0.1, 
                           length = 100))

pred_band = predict(model.simple, interval = "prediction")
plot_data <- cbind(reg_data, pred_band)

plot_data %>% ggplot(aes(x=Cost,y=Admissions)) + 
  geom_point(size=1, colour = '#3D3877') + 
  geom_line(aes(y=lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y=upr), color = "red", linetype = "dashed")+
  ylab('Acute Care Admissions') + 
  geom_abline(intercept = model.simple$coefficients[1],
              slope = model.simple$coefficients[2], linetype = 2, size = 1)

plot_data %>% ggplot(aes(x=Cost,y=Admissions)) + 
  geom_point(size=1,colour = '#3D3877') + # Govt line
  geom_abline(intercept = model.final$coefficients[1], 
              slope = model.final$coefficients[2],
              size = 0.7, color = 'DarkRed') + # Private Line
  geom_abline(intercept = model.final$coefficients[1]+model.final$coefficients[4],
              slope = model.final$coefficients[2],
              size = 0.7, color = 'Black')

#------------------------------------------------------------------------------
# Linear Model 2 (y= DTC_rate)
reg_data2 = data %>% select(-c('State','Cert_num','Name','Address','City',
                              'ZIP','Phone','ER_visits','Admissions','PPR_rate',
                              'High_rating','Recommendation'))
reg_data2 = reg_data2 %>% drop_na() # remove rows with ANY NaN
reg_data2$Star_rating = as.factor(reg_data2$Star_rating)

# Prepare stepwise feature selection
model2.saturated = lm(DTC_rate ~ ., data = reg_data2) #With All Features
model2.empty = lm(DTC_rate ~ 1, data = reg_data2)     #With Intercept ONLY
scope = list(lower = formula(model2.empty), upper = formula(model2.saturated))

forwardBIC = step(model2.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data2)), )

summary(forwardBIC) # Only Cost and Ownership were selected
plot(forwardBIC)
vif(forwardBIC)     # Remove Star_rating: VIF = 5.8

# Again without Star rating
reg_data2 = reg_data2[-4]
model2.saturated = lm(DTC_rate ~ ., data = reg_data2) #With All Features
model2.empty = lm(DTC_rate ~ 1, data = reg_data2)     #With Intercept ONLY
scope = list(lower = formula(model2.empty), upper = formula(model2.saturated))

forwardBIC = step(model2.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data2)), )
summary(forwardBIC) # Breathe_better + Own_type + Medication + Cost + Bed_better + 
                    # Drug_better + Drug_edu + Flu_shot + Communication + Professionalism
plot(forwardBIC)
vif(forwardBIC)


# R^2 Values are HORRIBLE...  0.07 - 0.23
#==============================================================================

# Look at a single State????  Maybe due to drastic differences in state
# regulations and competitive environment, there are no patterns.
temp = data %>% group_by(State) %>% summarise(count = n()) %>% arrange(-count)
head(temp) #Texas has the MOST agencies, and try Florida (OLD PEOPLE)

TX_data = data %>% filter(State=='TX')
cor(TX_data[,9:29], use = "complete.obs")

FL_data = data %>% filter(State=='FL')
cor(FL_data[,9:29], use = "complete.obs")
# correlations look a bit better? maybe?

# Try Linear Regression on TEXAS (y = Admissions)
#------------------------------------------------------------------------------
reg_data = TX_data %>% select(-c('State','Cert_num','Name','Address','City',
                              'ZIP','Phone','ER_visits','DTC_rate','PPR_rate',
                              'High_rating','Recommendation'))
reg_data = reg_data %>% drop_na() # remove rows with ANY NaN
reg_data$Star_rating = as.factor(reg_data$Star_rating)
dim(reg_data) #907

# Prepare stepwise feature selection
model.saturated = lm(Admissions ~ ., data = reg_data) #With All Features
model.empty = lm(Admissions ~ 1, data = reg_data)     #With Intercept ONLY
scope = list(lower = formula(model.empty), upper = formula(model.saturated))

library(MASS) #The Modern Applied Statistics library
library(car) #Companion to applied regression
forwardBIC = step(model.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data)), )

summary(forwardBIC)
plot(forwardBIC)
#vif(forwardBIC)    # Not needed Simple Linear Regression
confint(forwardBIC)

#Constructing confidence and prediction bands for the scope of our data
newdata = data.frame(Cost = 
                       seq(min(reg_data$Cost)-0.1, 
                           max(reg_data$Cost)+0.1, 
                           length = 100))

pred_band = predict(forwardBIC, interval = "prediction")
plot_data <- cbind(reg_data, pred_band)

plot_data %>% ggplot(aes(x=Cost,y=Admissions)) + 
  geom_point(size=1, colour = '#3D3877') + 
  geom_line(aes(y=lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y=upr), color = "red", linetype = "dashed")+
  ylab('Acute Care Admissions') + 
  geom_abline(intercept = forwardBIC$coefficients[1],
              slope = forwardBIC$coefficients[2], linetype = 2, size = 1)


# Linear Model 2 (y= DTC_rate)
reg_data2 = TX_data %>% select(-c('State','Cert_num','Name','Address','City',
                               'ZIP','Phone','ER_visits','Admissions','PPR_rate',
                               'High_rating','Recommendation'))
reg_data2 = reg_data2 %>% drop_na() # remove rows with ANY NaN
reg_data2$Star_rating = as.factor(reg_data2$Star_rating)

# Prepare stepwise feature selection
model2.saturated = lm(DTC_rate ~ ., data = reg_data2) #With All Features
model2.empty = lm(DTC_rate ~ 1, data = reg_data2)     #With Intercept ONLY
scope = list(lower = formula(model2.empty), upper = formula(model2.saturated))

forwardBIC = step(model2.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data2)), )

summary(forwardBIC)
summary(forwardBIC)$r.square # 0.29, better
plot(forwardBIC)
vif(forwardBIC)     # None above 5


# Try Linear Regression on FLORIDA (y = Admissions)
#------------------------------------------------------------------------------
reg_data = FL_data %>% select(-c('State','Cert_num','Name','Address','City',
                                 'ZIP','Phone','ER_visits','DTC_rate','PPR_rate',
                                 'High_rating','Recommendation'))
reg_data = reg_data %>% drop_na() # remove rows with ANY NaN
reg_data$Star_rating = as.factor(reg_data$Star_rating)
dim(reg_data) #900

# Prepare stepwise feature selection
model.saturated = lm(Admissions ~ ., data = reg_data) #With All Features
model.empty = lm(Admissions ~ 1, data = reg_data)     #With Intercept ONLY
scope = list(lower = formula(model.empty), upper = formula(model.saturated))

forwardBIC = step(model.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data)), )

summary(forwardBIC)
summary(forwardBIC)$r.square
plot(forwardBIC) # no outliers spotted


#Constructing confidence and prediction bands for the scope of our data
newdata = data.frame(Cost = 
                       seq(min(reg_data$Cost)-0.1, 
                           max(reg_data$Cost)+0.1, 
                           length = 100))
model.simple = lm(Admissions ~ + Cost, data = reg_data)

pred_band = predict(model.simple, interval = "prediction")
plot_data <- cbind(reg_data, pred_band)

plot_data %>% ggplot(aes(x=Cost,y=Admissions)) + 
  geom_point(size=1, colour = '#3D3877') + 
  geom_line(aes(y=lwr), color = "red", linetype = "dashed")+
  geom_line(aes(y=upr), color = "red", linetype = "dashed")+
  ylab('Acute Care Admissions') + 
  geom_abline(intercept = model.simple$coefficients[1],
              slope = model.simple$coefficients[2], linetype = 2, size = 1) +
  annotate("text", x = 0.6, y = 30,
           label = paste0('Beta1: ', round(model.simple$coefficients[2]/10,2))) +
  annotate("text", x = 0.6, y = 31,
           label = paste0('R-sqr: ', round(summary(forwardBIC)$r.squared,2)))


# Linear Model 2 (y= DTC_rate)
reg_data2 = FL_data %>% select(-c('State','Cert_num','Name','Address','City',
                                  'ZIP','Phone','ER_visits','Admissions','PPR_rate',
                                  'High_rating','Recommendation'))
reg_data2 = reg_data2 %>% drop_na() # remove rows with ANY NaN
reg_data2$Star_rating = as.factor(reg_data2$Star_rating)

# Prepare stepwise feature selection
model2.saturated = lm(DTC_rate ~ ., data = reg_data2) #With All Features
model2.empty = lm(DTC_rate ~ 1, data = reg_data2)     #With Intercept ONLY
scope = list(lower = formula(model2.empty), upper = formula(model2.saturated))

forwardBIC = step(model2.empty, scope, direction = "forward", 
                  k = log(nrow(reg_data2)), )

summary(forwardBIC)
summary(forwardBIC)$r.square # 0.1335
plot(forwardBIC)
vif(forwardBIC)     # None above 5
