library(tidyverse)
library(ggridges)
source('helper.R')

data = read_csv('./data/hh_data.csv')

colnames(data)

#Analysis of COST of HH Agency differences between Ownership Types
#-------------------------------------------------------------------------------
#Plot Density
data %>% ggplot(aes(x = Cost, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      quantiles = c(0.025, 0.975), alpha = 0.7, size=1) +
  ylab('') + theme(legend.position = "none")

# Sizes for each type still differ
bartlett.test(data$Cost ~ data$Own_type)  # p-val < 0.0001
#and we do not pass Bartlett Test to satisfy homogeneity of variances

#sample from the larger groups?
sampled_data = data %>% group_by(Own_type) %>% sample_n(364, replace = F)

#Plot Density
sampled_data %>% ggplot(aes(x = Cost, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      quantiles = c(0.025, 0.5, 0.975), alpha = 0.7, size=1) +
  ylab('') + theme(legend.position = "none")

bartlett.test(sampled_data$Cost ~ sampled_data$Own_type)  # p-val < 0.0001
# still do not pass Bartlett Test to satisfy homogeneity of variances

#ANOVA on mean cost
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(sampled_data$Cost ~ sampled_data$Own_type))
# difference in means is not significant, cannot reject nullhyp


#Analysis of DTC rate of HH Agency differences between Ownership Types
#-------------------------------------------------------------------------------
#sample from the larger groups again
sampled_data = data %>% group_by(Own_type) %>% sample_n(364, replace = F)

#Plot Density
sampled_data %>% ggplot(aes(x = DTC_rate, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      quantiles = c(0.025, 0.5, 0.975), alpha = 0.7, size=1) +
  ylab('') + theme(legend.position = "none")

bartlett.test(sampled_data$DTC_rate ~ sampled_data$Own_type)  # p-val < 0.0001

#ANOVA on mean DTC rate
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(sampled_data$DTC_rate ~ sampled_data$Own_type))
# difference in means is significant ***, reject nullhyp


#Analysis of Star rating of HH Agency differences between Ownership Types
#-------------------------------------------------------------------------------
#sample from the larger groups again
sampled_data = data %>% group_by(Own_type) %>% sample_n(364, replace = F)

#Plot Density
sampled_data %>% ggplot(aes(x = Star_rating, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      quantiles = c(0.025, 0.5, 0.975), alpha = 0.7, size=1) +
  ylab('') + theme(legend.position = "none")

bartlett.test(sampled_data$Star_rating ~ sampled_data$Own_type)  # p-val < 0.0001

#ANOVA on mean PPR rate
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(sampled_data$Star_rating ~ sampled_data$Own_type))
# difference in means is significant ***, reject nullhyp


#Analysis of professionalism percentage differences between Ownership Types
#-------------------------------------------------------------------------------
#sample from the larger groups again
sampled_data = data %>% group_by(Own_type) %>% sample_n(364, replace = F)

#Plot Density
sampled_data %>% ggplot(aes(x = Professionalism, y = Own_type, group = Own_type)) + 
  stat_density_ridges(quantile_lines = TRUE, 
                      quantiles = c(0.025, 0.5, 0.975), alpha = 0.7, size=1) +
  ylab('') + theme(legend.position = "none")

bartlett.test(sampled_data$Professionalism ~ sampled_data$Own_type)  # p-val < 0.0001

#ANOVA on mean PPR rate
#Nullhyp: Means are equal, set Alpha at 0.05
summary(aov(sampled_data$Professionalism ~ sampled_data$Own_type))
# difference in means is significant ***, reject nullhyp

##########################################
###### Maybe Automate this on SHINY ######
##########################################

#==============================================================================
# Bivariate Analysis (Cost vs Y)
scat = data %>% ggplot(aes(x=Cost), size=2)

# Cost vs DTC rate
scat + geom_point(aes(y=DTC_rate), color = 'navy', alpha=0.3) + 
  geom_density2d(aes(y=DTC_rate),color='orange')

# Cost vs Star rating
scat + geom_point(aes(y=Q_stars), color = 'navy', alpha=0.3) + 
  geom_density2d(aes(y=Q_stars),color='orange')

################################################################################
# Corr matrix or
# Scatter matrix, is faster...

# Correlation Matrix
cor(data[,10:29], use = "complete.obs")

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
pairs(data[,9:13], lower.panel = NULL, 
      upper.panel = upper.panel)  #Star rating vs 10-13

pairs(data[,c(9,14:17)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Star rating vs 14-17

pairs(data[,c(9,18:20)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Star rating vs 18-20

pairs(data[,c(9,21:23)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Star rating vs DTC and PPR rates and Cost

pairs(data[,c(9,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Star rating vs Patient Exp

pairs(data[,c(23,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Cost vs Patient Exp

pairs(data[,c(21,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #DTC rate vs Patient Exp

pairs(data[,c(22,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #PPR rate vs Patient Exp

pairs(data[,c(19,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #ER visits vs Patient Exp

pairs(data[,c(18,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Admissions vs Patient Exp

pairs(data[,c(13,25:29)], lower.panel = NULL, 
      upper.panel = upper.panel)  #Move better vs Patient Exp

#------------------------------------------------------------------------------
# LINEAR MODELS
# SIMPLE
model_cost_adm = lm(data$Admissions~data$Cost)
summary(model_cost_adm)
plot(model_cost_adm)
View(data[c(3941,8611),])
