# ECO 322 Spring 2022 - Project 2

## Table of Contents

1. [Introduction](#introduction)
2. [Goal](#goal)
3. [Data](#data)
4. [Assumptions](#assumptions)
5. [The Team](#the-team)

## Introduction

This project is an extension of our first project in that we are again focusing on US COVID-19 data. However, unlike our first project, this project narrows down from macro-level data (state-wide, county-wide) to micro-level data (individual patients).

## Goal

The goal of this project is to explore the relationships between COVID-19 mortality and other factors, such as age, weight, race, et cetera. Our final "deliverable" will be a machine learning classification model that will use the factors which we determine to have meaningful effects on COVID-19 mortality to predict whether a patient will live or die from the disease, given their patient data.

## Data 

As mentioned before, the data we will be using in this project is at the micro-level as opposed to the macro-level. More specifically, we have obtained a data set of individual COVID-19 patient data records from the Center for Disease Control (CDC) website. The data set was originally more than 2.6 gigabytes in size, however we have since trimmed the data to make it more manageable for our project; it is now approximately 70.8 megabytes. The filtered data set can be found [here](./data/project-filtered-data.csv).

Before we began our exploratory data analysis (EDA) and model creation with R, we decided to further inspect the filtered data set in a Jupyter Notebook using Python; this is found [here](./src/data-cleaning.ipynb). We removed all na/nan values first, and then moved onto removing the records with 'Missing' and 'nul' values, creating a new csv file with the trimmed results (found [here](./data/trimmed-data-with-unknowns.csv)). This reduced the initially 70.8 MB csv file to a 47.2 MB csv file. After this, we made a separate csv file from which records with 'Unknown' values were also trimmed; this data set can be found [here](./data/trimmed-data-without-unknowns.csv). This further reduced to data to a size of 43.9 MB. 

## Assumptions

Below is a list of the assumptions we made during our analysis.

1. There were no truly duplicated records in the CDC data set. In other words, no patient was counted more than once for a single COVID-19 case. We may have been a bit bold making this assumption, however there don't seem to be any unique IDs or identifying keys for every COVID-19 case. Thus, when we initially checked for duplicates in the data, an unrealistically large portion of the records were flagged as duplicates. We assumed this was because the data attributes we have access to are broad in nature, making exact equivalence of records possible and thus causing Python to flag such records as duplicates, however without unique ID keys in the data set (which were likely omitted to prevent patient identification in accordance with US HIPAA laws), we have no way of verifying which of these are actually duplicate entries for the same specific COVID-19 case and which are different cases which afflicted very similar patients.

## The Team

Our team has grown since our first project: we now have 6 members. The roles haven't changed much since the last project though:

  - **Jesse Freitag:** Overall Manager, Coder
  - **Charlie Clark:** Chief Coder, Quality Control
  - **Kailey Ali:** Note Taker, Quality Control
  - **Gavin Vergara:** Note Taker, Quality Control
  - **Qiushi Yin:** Coder, Quality Control
  - **Jhordyne Donaldson:** Quality Control, Note Taker

A copy of the team contract can be found [here](./project-2-group-contract.pdf).
