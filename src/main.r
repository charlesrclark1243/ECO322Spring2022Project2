# ==========================================================================================================================

# Setup Stage

# ==========================================================================================================================

# remove all existing environment variables...
rm(list = ls())

# --------------------------------------------------------------------------------------------------------------------------

# install all necessary packages...
install.packages(c("data.table", "haven", "sjlabelled", "sjmisc", "sjPlot", "plyr", "ggplot2", "caret", "scales", ""))

# --------------------------------------------------------------------------------------------------------------------------

# install packages necessary for SMOTE...
install.packages(c("zoo", "xts", "quantmod", "abind", "ROCR"))
install.packages("~/Downloads/DMwR_0.4.1.tar", repos = NULL, type = "source")

# --------------------------------------------------------------------------------------------------------------------------

# import all necessary packages...
library(data.table)
library(ggplot2)
library(haven)
library(sjlabelled)
library(sjmisc)
library(sjPlot)
library(plyr)
library(caret)
library(DMwR)

# ==========================================================================================================================

# Data Wrangling (Jesse)

# ==========================================================================================================================

# read data from .csv file and store in data.frame...
data <- read.csv("../data/project-filtered-data.csv")

# --------------------------------------------------------------------------------------------------------------------------

# set data as data.table...
setDT(data)

# --------------------------------------------------------------------------------------------------------------------------

# view data...
View(data)

# --------------------------------------------------------------------------------------------------------------------------

# subset data on following attributes:
#   - case_month
#   - res_state
#   - state_fips_code
#   - age_group
#   - sex
#   - race
#   - ethnicity
#   - current_status
#   - symptom_status
#   - death_yn
#   - underlying_conditions_yn
data <- data[ , .(case_month, res_state, state_fips_code, age_group, sex, race, ethnicity,
             current_status, symptom_status, death_yn, underlying_conditions_yn)]

# --------------------------------------------------------------------------------------------------------------------------

# view data again...
View(data)

# --------------------------------------------------------------------------------------------------------------------------

# remove na/nan/NULL values from data...
data <- na.omit(data)

# --------------------------------------------------------------------------------------------------------------------------

# create a function to filter out "Missing," "Unknown," "nul" values...
remove_bad_records <- function(dt) {
  cols <- names(dt)
  
  for (col in cols) {
    dt <- dt[get(col) != "Missing" & get(col) != "Unknown" & get(col) != "nul", ]
    
    print(count(dt[, get(col) == "Missing" | get(col) == "Unknown" | get(col) == "nul"]))
  }
  
  return(dt)
}

# --------------------------------------------------------------------------------------------------------------------------

# apply created function to remove "Missing," "Unknown," "nul" values...
temp <- remove_bad_records(data)

# --------------------------------------------------------------------------------------------------------------------------

# make sure there are no na/nan/NULL/"Missing"/"Unknown"/"nul" values in temp...
for (col in names(temp)) {
  print(sum(temp[, is.na(get(col)) | get(col) == "Missing" | get(col) == "Unknown" | get(col) == "nul"]))
}

# --------------------------------------------------------------------------------------------------------------------------

# convert "yn" features to integer binary variables...
temp[, "died" := ifelse(test = c(temp$death_yn == "Yes"), 1, 0)]
temp[, "underlying_conditions" := ifelse(test = c(temp$underlying_conditions_yn == "Yes"), 1, 0)]

# --------------------------------------------------------------------------------------------------------------------------

# compare "Yes" occurrences in data to 1 occurrences in temp...
if (sum(temp$died == 1) == sum(temp$death_yn == "Yes")) {
  print("died is accurate!")
}

if (sum(temp$underlying_conditions == 1) == sum(temp$underlying_conditions_yn == "Yes")) {
  print("underlying conditions is accurate!")
}

# --------------------------------------------------------------------------------------------------------------------------

# check data types of "died" and "underlying_conditions"...
typeof(temp$died)
typeof(temp$underlying_conditions)

# --------------------------------------------------------------------------------------------------------------------------

# make sure "died" and "underlying_conditions" are of type integer...
temp$died <- as.integer(temp$died)
temp$underlying_conditions <- as.integer(temp$underlying_conditions)

# --------------------------------------------------------------------------------------------------------------------------

# check data types of "died" and "underlying_conditions" again...
typeof(temp$died)
typeof(temp$underlying_conditions)

# --------------------------------------------------------------------------------------------------------------------------

# remove "yn" features from data...
temp[, `:=`(death_yn = NULL, underlying_conditions_yn = NULL)]

# --------------------------------------------------------------------------------------------------------------------------

# check symptom_status and "current_status" unique values...
unique(temp$symptom_status)
unique(temp$current_status)

# --------------------------------------------------------------------------------------------------------------------------

# encode symptom status and remove current status features...
temp[, `:=`("symptomatic" = ifelse(test = c(temp$symptom_status == "Symptomatic"), 1, 0),
            current_status = NULL)]

# --------------------------------------------------------------------------------------------------------------------------

# count how many records show symptomatic == 1...
count(temp[, symptomatic == 1])

# --------------------------------------------------------------------------------------------------------------------------

# check data type of symptomatic...
typeof(temp$symptomatic)

# --------------------------------------------------------------------------------------------------------------------------

# make sure symptomatic is numeric encoded...
temp$symptomatic <- as.integer(temp$symptomatic)

# --------------------------------------------------------------------------------------------------------------------------

# check data type of symptomatic again...
typeof(temp$symptomatic)

# --------------------------------------------------------------------------------------------------------------------------

# remove symptom_status feature...
temp[, symptom_status := NULL]

# --------------------------------------------------------------------------------------------------------------------------

# check unique values in sex feature...
unique(temp$sex)

# --------------------------------------------------------------------------------------------------------------------------

# encode sex to binary numeric variable...
temp[, "is_male" := ifelse(test = c(sex == "Male"), 1, 0)]

# --------------------------------------------------------------------------------------------------------------------------

# check data type of is_male...
typeof(temp$is_male)

# --------------------------------------------------------------------------------------------------------------------------

# make sure is_male is numeric...
temp$is_male <- as.integer(temp$is_male)

# --------------------------------------------------------------------------------------------------------------------------

# check data type of is_male again...
typeof(temp$is_male)

# --------------------------------------------------------------------------------------------------------------------------

# remove sex feature...
temp[, sex := NULL]

# --------------------------------------------------------------------------------------------------------------------------

# check unique values for age_group...
unique(temp$age_group)

# --------------------------------------------------------------------------------------------------------------------------

# encode age groups using integer values, where younger age groups...
# are assigned lower integer values...
temp[, age_group := {
  age_bound_vec <- vector()
  
  for (row in c(1:length(temp$age_group))) {
    if (temp$age_group[row] == "0 - 17 years") {
      age_bound_vec[row] <- as.integer("0")
    }
    else if (temp$age_group[row] == "18 to 49 years") {
      age_bound_vec[row] <- as.integer("1")
    }
    else if (temp$age_group[row] == "50 to 64 years") {
      age_bound_vec[row] <- as.integer("2")
    }
    else {
      age_bound_vec[row] <- as.integer("3")
    }
  }
  
  return (age_bound_vec)
}]

# --------------------------------------------------------------------------------------------------------------------------

# check data type of age_group...
typeof(temp$age_group)

# --------------------------------------------------------------------------------------------------------------------------

# inspect unique values of age_group...
unique(temp$age_group)

# --------------------------------------------------------------------------------------------------------------------------

# check unique values for race...
unique(temp$race)

# --------------------------------------------------------------------------------------------------------------------------

# count occurrences of each race value...
sums <- vector()
  
sums[1] <- paste("white", sum(temp$race == "White"), sep = " ")
sums[2] <- paste("black", sum(temp$race == "Black"), sep = " ")
sums[3] <- paste("asian", sum(temp$race == "Asian"), sep = " ")
sums[4] <- paste("indig", sum(temp$race == "American Indian/Alaska Native"), sep = " ")
sums[5] <- paste("pacific", sum(temp$race == "Native Hawaiian/Other Pacific Islander"), sep = " ")
sums[6] <- paste("other", sum(temp$race == "Multiple/Other"), sep = " ")

sums

# --------------------------------------------------------------------------------------------------------------------------

# encode using increasing integer values, from highest sum to lowest...
temp$race[temp$race == "White"] <- as.integer("0")
temp$race[temp$race == "Black"] <- as.integer("1")
temp$race[temp$race == "Asian"] <- as.integer("2")
temp$race[temp$race == "Multiple/Other"] <- as.integer("3")
temp$race[temp$race == "Native Hawaiian/Other Pacific Islander"] <- as.integer("4")
temp$race[temp$race == "American Indian/Alaska Native"] <- as.integer("5")


# --------------------------------------------------------------------------------------------------------------------------

# check type of race feature...
typeof(temp$race)

# --------------------------------------------------------------------------------------------------------------------------

# check unique values for race...
unique(temp$race)

# --------------------------------------------------------------------------------------------------------------------------

# make sure race is integer typed...
temp$race <- as.integer(temp$race)

# --------------------------------------------------------------------------------------------------------------------------

# check type of race feature...
typeof(temp$race)

# --------------------------------------------------------------------------------------------------------------------------

# check unique values for ethnicity...
unique(temp$ethnicity)

# --------------------------------------------------------------------------------------------------------------------------

# create binary numeric variable is_hispanic_latino...
temp[, "is_hispanic_latino" := ifelse(test = c(ethnicity == "Hispanic/Latino"), 1, 0)]

# --------------------------------------------------------------------------------------------------------------------------

# check type of is_hispanic_latino...
typeof(temp$is_hispanic_latino)

# --------------------------------------------------------------------------------------------------------------------------

# make sure is_hispanic_latino is, in fact, numeric...
temp$is_hispanic_latino <- as.integer(temp$is_hispanic_latino)

# --------------------------------------------------------------------------------------------------------------------------

# check type of is_hispanic_latino again...
typeof(temp$is_hispanic_latino)

# --------------------------------------------------------------------------------------------------------------------------

# remove ethnicity feature...
temp[, ethnicity := NULL]

# --------------------------------------------------------------------------------------------------------------------------

# check number of unique value for res_state...
length(unique(temp$res_state))

# --------------------------------------------------------------------------------------------------------------------------

# drop res_state since fips code uniquely identifies each possible value...
temp[, res_state := NULL]

# --------------------------------------------------------------------------------------------------------------------------

# extract month from case_month...
temp[, "month" := {
  month_vec <- vector()
  
  for (row in c(1:length(temp$case_month))) {
    month_vec[row] <- as.integer(unlist(strsplit(temp$case_month[row], "-"))[2])
  }
  
  return (month_vec)
}]

# --------------------------------------------------------------------------------------------------------------------------

# check type of month...
typeof(temp$month)

# --------------------------------------------------------------------------------------------------------------------------

# check unique values in month...
unique(temp$month)

# --------------------------------------------------------------------------------------------------------------------------

# remove case_month from data...
temp[, case_month := NULL]

# --------------------------------------------------------------------------------------------------------------------------

# check for duplicates...
sum(duplicated(temp))

# --------------------------------------------------------------------------------------------------------------------------

# it appears that there are quite a few duplicates, however, considering that...
# the data we're using doesn't contain any unique keys or IDs for every distinct case...
# there's no way for us to determine which records truly are duplicated, i.e., multiple...
# countings of the same case, and which are simply two separate cases with very similar circumstances...
# therefore, we'll assume that the CDC is perfectly efficient and compitent in their record...
# keeping and that no one case was ever counted more than one time...

# finally, let's deep copy temp to data and make sure they are stored separately in memory...
data <- copy(temp)
setDT(data)

check_deep <- function(og, copy) {
  if (tracemem(copy) != tracemem(og)) {
    print("copy is deep copy of og!")
  } else {
    print("copy is shallow copy of og!")
  }
}

check_deep(og = temp, copy = data)

# ==========================================================================================================================

# Exploratory Data Analysis (Charlie)

# ==========================================================================================================================

# first, let's deep copy data into another temporary variable for use in our EDA...
eda_temp <- copy(data)
setDT(eda_temp)

check_deep(og = data, copy = eda_temp)

# --------------------------------------------------------------------------------------------------------------------------

# now, let's convert the died feature in eda_temp to factors representing a specific COVID case's...
# outcome, i.e., "lived" or "died"...
eda_temp[, died := factor(ifelse(test = c(died == 1), "Died", "Lived"))]
unique(eda_temp$died)

# --------------------------------------------------------------------------------------------------------------------------

# let's create a bar graph showing the distribution of target variable died using a bar graph...
ggplot(data = eda_temp, aes(x = died, fill = died)) +
  geom_bar() +
  scale_fill_manual(values = c("red", "green")) +
  scale_y_continuous(name = "Count",
                     limits = c(0, 400000, 100000),
                     labels = scales::comma_format()) +
  labs(title = "Distribution of COVID-19 Case Survival Outcomes",
       x ="Survival Outcome", y = "Count",
       "fill" = "Survival Outcome") +
  theme_linedraw()

# --------------------------------------------------------------------------------------------------------------------------

# the died variable seems highly imbalanced, so we may need to apply SMOTE techniques...
# to balance the data later on when we start creating models...

# next, we will inspect the distribution of the symptomatic column...
# before we create any plots, we'll need to convert the symptomatic attribute values...
# to factor values with text labels...
eda_temp[, symptomatic := factor(ifelse(test = c(symptomatic == 1), "Symptomatic", "Asymptomatic"))]
unique(eda_temp$symptomatic)

# --------------------------------------------------------------------------------------------------------------------------



# ==========================================================================================================================

# Modeling (Jesse & Charlie)

# ==========================================================================================================================

# define logistic function...
logistic <- function(coeffs, vars) {
  coeffs <- as.vector(coeffs)
  vars <- as.vector(vars)
  
  inner_prod <- coeffs * vars
  
  numerator <- exp(inner_prod)
  denominator <- 1.0 + exp(inner_prod)
  
  return (numerator / denominator)
}

# --------------------------------------------------------------------------------------------------------------------------

# define recall function...
recall <- function(died_pred, died_true) {
  died_pred <- as.vector(died_pred)
  died_true <- as.vector(died_true)
  
  p <- died_true * died_true
  
  tp <- 0
  for (index in c(1:length(died_pred))) {
    if (died_pred[index] == 1 & died_true[index] == 1) {
      tp <- tp + 1
    }
  }
  
  r <- tp / p
  return (r)
}

# --------------------------------------------------------------------------------------------------------------------------

# split data into training and testing sets...
set.seed(42)
train_indices <- sample(seq_len(nrow(temp)), size = floor(0.8 * nrow(temp)))

train <- temp[train_indices, ]
test <- temp[-train_indices, ]

# --------------------------------------------------------------------------------------------------------------------------

# create the first logistic regression model, fit using train data, and get summary...
model_one <- train(died ~ (age_group + underlying_conditions + is_male), data = train,
                   method = "glm", family = "binomial")

summary(model_one)

# --------------------------------------------------------------------------------------------------------------------------

# make predictions using test data...
test$pred <- predict(model_one, newdata = test)
sensitivity(test$died, test$pred)

