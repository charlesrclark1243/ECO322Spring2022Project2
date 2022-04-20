rm(list = ls())
#Load packages
library(data.table)
library(haven)       # Need for variable and value labels
library(sjlabelled)  # Likewise
library(sjmisc)      # Likewise
library(sjPlot)      # For tables with value labels
library(plyr)


setwd("C:/Users/HP/OneDrive/Desktop/COVID")
#Load in the data

data <- read.csv('Project_Filtered.csv', header = TRUE)
unique(data[c("race")])
names(data)
setDT(data)
View(data)
#-------------------------------------------------------------------------------
#This section we handle our missing data and "clean" the data to create dummy variables based on some conditions
#If we believe that symptom status is a relevant variable, then we need to drop the missing values
data<-data[!(data$symptom_status=="Missing" | data$symptom_status=="Unknown" | data$icu_yn == 'NA'),]
data<-data[!(data$case_month=="Missing" | data$case_month=="Unknown" | data$case_month == 'NA'),]
data<-data[!(data$age_group=="Missing" | data$age_group=="Unknown" | data$age_group == 'NA'),]
data<-data[!(data$ethnicity=="Missing" | data$ethnicity=="Unknown" | data$ethnicity == 'NA'),]
data<-data[!(data$race=="Missing" | data$race=="Unknown" | data$race == 'NA'),]

count(data[,symptom_status == 'Missing'])
count(data[,symptom_status == 'Unknown'])
count(data[,underlying_conditions_yn == "Yes"])

#Relevant variables I think to include -- Hospitalization, Symptom Status, Age group, Underlying Conditions. (Maybe include Race?)

#We are trying to predict Death
data$death[data$death_yn == 'Yes'] <- as.numeric(1)
data$death[data$death_yn == 'No']  <- as.numeric(0)
data$death <- as.numeric(data$death)
data[ , death_yn := NULL]

data$hospital[data$hosp_yn == 'Yes'] <- as.numeric(1)
data$hospital[data$hosp_yn == 'No']  <- as.numeric(0)
data$hospital <- as.numeric(data$hospital)
data[ , hosp_yn := NULL]

data$icu[data$icu_yn == 'Yes'] <- as.numeric(1)
data$icu[data$icu_yn == 'No']  <- as.numeric(0)
data$icu<- as.numeric(data$icu)
data[ , icu_yn := NULL]

#We got warning message--- need to drop the 49 observations with NA in ICU column
data<- data[!(data$icu == "NA")]
count(data$icu == 'NA')

data$symptoms[data$symptom_status == 'Symptomatic'] <- as.numeric(1)
data$symptoms[data$symptom_status == 'Asymptomatic'] <- as.numeric(0)
data$symptoms <- as.numeric(data$symptoms)
data[ , symptom_status := NULL]

data$underlying[data$underlying_conditions_yn == 'Yes'] <- as.numeric(1)
data$underlying[data$underlying_conditions_yn == 'No'] <- as.numeric(0)
data$underlying <- as.numeric(data$underlying)
data[ , underlying_conditions_yn := NULL]

data$isWhite[data$race =='White']<- as.numeric(1)
data$isWhite[(data$race == 'Black' | data$race == 'Native Hawaiian/Other Pacific Islander' | data$race == 'Asian'| data$race == 'American Indian/Alaska Native'
              |data$race == 'Multiple/Other')] <-as.numeric(0)
data$isWhite <- as.numeric(data$isWhite)
data[, race := NULL]

data$isMale[data$sex == 'Male'] <- as.numeric(1)
data$isMale[data$sex == 'Female'] <- as.numeric(0)
data[ , sex := NULL]

age_labels <- factor(c("0 - 17 years","18 to 49 years","50 to 64 years","65+ years"))


for (i in 1:4)
{
  data$age[data$age_group == age_labels[i]] <- as.numeric(i)
}
data$age <- as.numeric(data$age)



View(data)

#-------------------------------------------------------------------------------
count(data[,death ==1])
count(data[, hospital ==1])
count(data[, icu == 1])
#idk about this function
LogitFunc <- function(b1 , b2 , b3, b4 , b5){
  return( exp(b1 + b2*data$age + b3*data$hospital +  b4*data$icu +  b5*data$underlying)
          / (1.0+ exp(b1 + b2*data$age + b3*data$hospital +  b4*data$icu +  b5*data$underlying)))
} 

fit = glm(death ~ (age + hospital + icu + underlying + isMale + isWhite), data=data, family="binomial")
fit$coefficients 
#Fitted Values are the predicted probabilities
fit$fitted.values[1:17]
View(fit$linear.predictors[1:100])
summary(fit)

length(fit$fitted.values)

predicted <-data.frame(
  prob.of.death = fit$fitted.values, death = data$death)


#made outcome variables (rounded up if prob >.5 else 0)
predicted$outcome[predicted$prob.of.death >0.5] <- as.numeric(1)
predicted$outcome[predicted$prob.of.death <0.5] <- as.numeric(0)
predicted$outcome <- as.numeric(predicted$outcome)

#idk... need to make some confusion matrix to see accuracy/precision/recall or wahtever
View(predicted)
num <-  count(predicted[, predicted$outcome ==1]  & predicted[,predicted$death ==1])



predicted.data <- predicted.data[
  order(predicted.data$prob.of.death, decreasing = FALSE),]

View(predicted.data)

predicted.data$rank <- 1:nrow(predicted.data)
