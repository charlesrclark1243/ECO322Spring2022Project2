# ECO 322 Spring 2022 - Project 2

## Table of Contents

1. [Introduction](#introduction)
2. [Goal](#goal)
3. [Data](#data)
4. [Assumptions](#assumptions)
5. [Modeling](#modeling)
6. [The Team](#the-team)

## Introduction

This project is an extension of our first project in that we are again focusing on US COVID-19 data. However, unlike our first project, this project narrows down from macro-level data (state-wide, county-wide) to micro-level data (individual patients).

## Goal

The goal of this project is to try and optimize the allocation of healthcare resources to COVID-19 patients. To do this, we will be creating classification models based on the logit function which will predict the likelihood of a COVID-19 patient succumbing to the disease without considering whether or not the patient was admitted to the hospital. The omission of patients' hospitalization status may seem outlandish, however the purpose of doing so is to try and determine the likelihood of a patient succumbing to COVID-19 without considering their hospitalization status so that hospitals can optimize COVID-19 patient admittance, focusing on those populations who are most vulnerable to death. The ultimate reason for an admittance process based on such a model is to prevent a strain or even collapse of he US healthcare industry while focusing available resources on people who need them the most, i.e., those who are most likely to perish without considering hospitalization status.

It should be noted that none of the members of this team believe that anyone's life matters more or less than anyone else's. The goal is **not** to selective admit people who we deem more important, but rather to use statistical data as a means of allocating resources to those who are more likely to perish without them. A fit, asymptomatic, young year old COVID-19 patient admitted to the hospital will draw resources - time, energy, attention, funds, et cetera - away from caring for a comparatively less healthy, symptomatic, older COVID-19 patient who, according to most studies, has a much higher likelihood of succumbing to the illness, even after being admitted to the hopsital. Thus, the purpose of this project is to better align hospitalizations and resource allocations based on observed statistical trends in COVID-19 mortality. 

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

$$recall = \frac{TP}{P},$$

where $TP$ is the number of true positives while $P$ is the total number of positives (true positives plus false negatives). We use recall as opposed to accuracy, precision, or even $F_1$ score because optimizing recall in turn optimizes the number of correct positive predictions, compared to all positive instances. Because this model is literally intended for use in life-or-death choices, it is better to overpredict positive occurrences if the number of actual positives predicted correctly is higher (in other words, it's better to overpredict the number of people vulnerable to death by COVID-19 as the cost of choosing not to hospitalize a patient who might need to be hopsitalized to survive is **much** higher than the cost of choosing to hospitalize a patient who might've survived without being hospitalized).

## The Team

Our team has grown since our first project: we now have 6 members. The roles haven't changed much since the last project though:

  - **Jesse Freitag:** Overall Manager, Coder
  - **Charlie Clark:** Chief Coder, Quality Control
  - **Kailey Ali:** Note Taker, Quality Control
  - **Gavin Vergara:** Note Taker, Quality Control
  - **Qiushi Yin:** Coder, Quality Control
  - **Jhordyne Donaldson:** Quality Control, Note Taker

A copy of the team contract can be found [here](./project-2-group-contract.pdf).
