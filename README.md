# ECO 322 Spring 2022 - Project 2

## Table of Contents

1. [Introduction](#introduction)
2. [Goal](#goal)
3. [Data](#data)
4. [Assumptions](#assumptions)
5. [Modeling](#modeling)
    - [Evaluation](#evaluation)
    - [Our Models](#our-models)
        - [Model One](#model-one)
        - [Model Two](#model-two)
        - [Model Three](#model-three)
        - [Model Four](#model-four)
6. [The Team](#the-team)

## Introduction

This project is an extension of our first project in that we are again focusing on US COVID-19 data. However, unlike our first project, this project narrows down from macro-level data (state-wide, county-wide) to micro-level data (individual patients).

## Goal

The goal of this project is to try and optimize the allocation of healthcare resources to COVID-19 patients. To do this, we will be creating classification models based on the logit function which will predict the likelihood of a COVID-19 patient succumbing to the disease without considering whether or not the patient was admitted to the hospital. The omission of patients' hospitalization status may seem outlandish, however the purpose of doing so is to try and determine the likelihood of a patient succumbing to COVID-19 without considering their hospitalization status so that hospitals can optimize COVID-19 patient admittance, focusing on those populations who are most vulnerable to death. The ultimate reason for an admittance process based on such a model is to prevent a strain or even collapse of he US healthcare industry while focusing available resources on people who need them the most, i.e., those who are most likely to perish without considering hospitalization status.

It should be noted that none of the members of this team believe that anyone's life matters more or less than anyone else's. The goal is **not** to selectively admit people who we deem more important, but rather to use statistical data as a means of allocating resources to those who are more likely to perish without them. A fit, asymptomatic, young year old COVID-19 patient admitted to the hospital will draw resources - time, energy, attention, funds, et cetera - away from caring for a comparatively less healthy, symptomatic, older COVID-19 patient who, according to most studies, has a much higher likelihood of succumbing to the illness, even after being admitted to the hopsital. Thus, the purpose of this project is to better align hospitalizations and resource allocations based on observed statistical trends in COVID-19 mortality. 

## Data 

As mentioned before, the data we will be using in this project is at the micro-level as opposed to the macro-level. More specifically, we have obtained a data set of individual COVID-19 patient data records from the Center for Disease Control (CDC) website. The data set was originally more than 2.6 gigabytes in size, however we have since trimmed the data to make it more manageable for our project; it is now approximately 70.8 megabytes. The filtered data set can be found [here](./data/project-filtered-data.csv).

Before we began our exploratory data analysis (EDA) and model creation with R, we decided to further inspect the filtered data set in a Jupyter Notebook using Python; this is found [here](./src/data-cleaning.ipynb). We removed all na/nan values first, and then moved onto removing the records with 'Missing' and 'nul' values, creating a new csv file with the trimmed results (found [here](./data/trimmed-data-with-unknowns.csv)). This reduced the initially 70.8 MB csv file to a 47.2 MB csv file. After this, we made a separate csv file from which records with 'Unknown' values were also trimmed; this data set can be found [here](./data/trimmed-data-without-unknowns.csv). This further reduced to data to a size of 43.9 MB. 

## Assumptions

Below is a list of the assumptions we made during our analysis.

1. There were no truly duplicated records in the CDC data set. In other words, no patient was counted more than once for a single COVID-19 case. We may have been a bit bold making this assumption, however there don't seem to be any unique IDs or identifying keys for every COVID-19 case. Thus, when we initially checked for duplicates in the data, an unrealistically large portion of the records were flagged as duplicates. We assumed this was because the data attributes we have access to are broad in nature, making exact equivalence of records possible and thus causing Python to flag such records as duplicates, however without unique ID keys in the data set (which were likely omitted to prevent patient identification in accordance with US HIPAA laws), we have no way of verifying which of these are actually duplicate entries for the same specific COVID-19 case and which are different cases which afflicted very similar patients.

## Modeling

Due to the nature of our project's goal, we have decided to create a classification model based on the logit function which predicts whether or not a given patient will survive being afflicted by COVID-19, based on said patient's background information as provided in the CDC data set. 

### Evaluation

Evaluating a classification model usually depends on the model's confusion matrix. A confusion matrix is simply a matrix which measures a classification model's performance based on it's predicted output; it counts the number of true positives (TP), false positives (FP), true negatives (TN), and false negatives (FN).

  - **True Positive (TP):** an observation that the model correctly classifies as being a positive (1-encoded) instance; here, a true positive is a COVID-19 instance for which the model correctly predicts the patient survived.
  - **False Positive (FP):** an observation that the model incorrectly classifies as being a positive (1-encoded) instance; here, a false positive is a COVID-19 instance for which the model predicts the patient survived when, in fact, they did not.
  - **True Negative (TN):** an observation that the model correctly classifies as being a negative (0-encoded) instance; here, a true negative is a COVID-19 instance for which the model correctly predicts the patient didn't survive.
  - **False Negative (FN):** an observation that the model incorrectly classifies as being a negative (0-encoded) instance; here, a false negative is a COVID-19 instance for which the model predicts the patient didn't survive when, in fact, they did. 

There are multiple different metrics that are calculated using the confusion matrix. However, the one we will be using is **recall:** the percentage of true positives compared to the total number of positives, i.e.,

<p align="center">
    <img src="https://render.githubusercontent.com/render/math?math=recall = \frac{TP}{P}">
</p>

where <img src="https://render.githubusercontent.com/render/math?math=TP"> is the number of true positives while <img src="https://render.githubusercontent.com/render/math?math=P"> is the total number of positives (true positives plus false negatives). We use recall as opposed to accuracy, precision, or even <img src="https://render.githubusercontent.com/render/math?math=F_1"> score because optimizing recall in turn optimizes the number of correct positive predictions, compared to all positive instances. Because this model is literally intended for use in life-or-death choices, it is better to overpredict positive occurrences if the number of actual positives predicted correctly is higher (in other words, it's better to overpredict the number of people vulnerable to death by COVID-19 as the cost of choosing not to hospitalize a patient who might need to be hopsitalized to survive is **much** higher than the cost of choosing to hospitalize a patient who might've survived without being hospitalized).

### Our Models

| Model Number | Explanatory Variables Used | Recall |
| ------------ | -------------------------- | ------ |
| 1            | ```age_group```, ```underlying_conditions```, ```is_male``` | 0.9538012 |
| 2            | ```age_group```, ```underlying_conditions```, ```is_male```, ```race``` | 0.9537924 |
| 3            | ```age_group```, ```underlying_conditions```, ```is_male```, ```symptomatic``` | 0.9538012 |
| 4            | ```age_group```, ```underlying_conditions```, ```is_male```, ```is_hispanic_latino``` | 0.9538012 |

#### Model One

**Deviance Residuals**
| Min | 1Q | Median | 3Q | Max |
| --- | -- | ------ | -- | --- |
| -0.6258 | -0.2169 | -0.0723 | -0.0568 | 3.8789 |

**Coefficients**
| Coefficient Term | Estimate | Standard Error | z-Value | p-Value | Minimum Significance Level |
| ---------------- | -------- | -------------- | ------- | ------- | -------------------------- |
| (Intercept)      | -11.93594 | 0.38275       | -31.185 | <2e-16 | <0.001 |
| ```age_group``` | 2.20673 | 0.02172 | 101.588 | <2e-16 | <0.001 |
| ```underlying_conditions``` | 3.30197 | 0.37880 | 8.717 | <2e-16 | <0.001 |
| ```is_male``` | 0.48268 | 0.01785 | 27.040 | <2e-16 | <0.001 |

**Other Information**
| Measure | Value | Degrees of Freedom |
| ------- | ----- | ------------------ |
| Null Deviance | 119,456 | 317,320 |
| Residual Deviance | 91,551 | 317,317 |
| AIC | 91,559 | N/A |
| Num. Fisher Scoring Iterations | 10 | N/A |

#### Model Two

**Deviance Residuals**
| Min | 1Q | Median | 3Q | Max |
| --- | -- | ------ | -- | --- |
| -1.4849 | -0.2553 | -0.0825 | -0.0513 | 3.9051 |

**Coefficients**
| Coefficient Term | Estimate | Standard Error | z-Value | p-Value | Minimum Significance Level |
| ---------------- | -------- | -------------- | ------- | ------- | -------------------------- |
| (Intercept)      | -12.17310 | 0.38310       | -31.775 | <2e-16 | <0.001 |
| ```age_group``` | 2.27440 | 0.02211 | 102.865 | <2e-16 | <0.001 |
| ```underlying_conditions``` | 3.26546 | 0.37886 | 8.619 | <2e-16 | <0.001 |
| ```is_male``` | 0.49294 | 0.01791 | 27.520 | <2e-16 | <0.001 |
| ```race``` | 0.45808 | 0.01611 | 28.433 | <2e-16 | <0.001 |

**Other Information**
| Measure | Value | Degrees of Freedom |
| ------- | ----- | ------------------ |
| Null Deviance | 119,456 | 317,320 |
| Residual Deviance | 90,860 | 317,316 |
| AIC | 90,870 | N/A |
| Num. Fisher Scoring Iterations | 10 | N/A |

#### Model Three

**Deviance Residuals**
| Min | 1Q | Median | 3Q | Max |
| --- | -- | ------ | -- | --- |
| -0.6312 | -0.2182 | -0.0725 | -0.0571 | 3.8750 |

**Coefficients**
| Coefficient Term | Estimate | Standard Error | z-Value | p-Value | Minimum Significance Level |
| ---------------- | -------- | -------------- | ------- | ------- | -------------------------- |
| (Intercept)      | -12.42953 | 0.38595       | -32.20 | <2e-16 | <0.001 |
| ```age_group``` | 2.21354 | 0.02174 | 101.80 | <2e-16 | <0.001 |
| ```underlying_conditions``` | 3.30319 | 0.37880 | 8.72 | <2e-16 | <0.001 |
| ```is_male``` | 0.47842 | 0.01786 | 26.79 | <2e-16 | <0.001 |
| ```symptomatic``` | 0.49529 | 0.04948 | 10.01 | <2e-16 | <0.001 |

**Other Information**
| Measure | Value | Degrees of Freedom |
| ------- | ----- | ------------------ |
| Null Deviance | 119,456 | 317,320 |
| Residual Deviance | 91,437 | 317,316 |
| AIC | 91,447 | N/A |
| Num. Fisher Scoring Iterations | 10 | N/A |

#### Model Four

**Deviance Residuals**
| Min | 1Q | Median | 3Q | Max |
| --- | -- | ------ | -- | --- |
| -0.8705 | -0.2421 | -0.0788 | -0.0535 | 3.8994 |

**Coefficients**
| Coefficient Term | Estimate | Standard Error | z-Value | p-Value | Minimum Significance Level |
| ---------------- | -------- | -------------- | ------- | ------- | -------------------------- |
| (Intercept)      | -12.11753 | 0.38303       | -31.636 | <2e-16 | <0.001 |
| ```age_group``` | 2.25770 | 0.02210 | 102.174 | <2e-16 | <0.001 |
| ```underlying_conditions``` | 3.31048 | 0.37882 | 8.739 | <2e-16 | <0.001 |
| ```is_male``` | 0.48271 | 0.01787 | 27.011 | <2e-16 | <0.001 |
| ```is_hispanic_latino``` | 0.77614 | 0.04333 | 17.914 | <2e-16 | <0.001 |

**Other Information**
| Measure | Value | Degrees of Freedom |
| ------- | ----- | ------------------ |
| Null Deviance | 119,456 | 317,320 |
| Residual Deviance | 91,272 | 317,316 |
| AIC | 91,282 | N/A |
| Num. Fisher Scoring Iterations | 10 | N/A |

## The Team

Our team has grown since our first project: we now have 6 members. The roles haven't changed much since the last project though:

  - **Jesse Freitag:** Overall Manager, Coder
  - **Charlie Clark:** Chief Coder, Quality Control
  - **Kailey Ali:** Note Taker, Quality Control
  - **Gavin Vergara:** Note Taker, Quality Control
  - **Qiushi Yin:** Coder, Quality Control
  - **Jhordyne Donaldson:** Quality Control, Note Taker

A copy of the team contract can be found [here](./project-2-group-contract.pdf).
