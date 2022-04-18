# ECO 322 Spring 2022 - Project 2

## Table of Contents

1. [Introduction](#introduction)
2. [Goal](#goal)
3. [Data](#data)
4. [The Team](#the-team)

## Introduction

This project is an extension of our first project in that we are again focusing on US COVID-19 data. However, unlike our first project, this project narrows down from macro-level data (state-wide, county-wide) to micro-level data (individual patients).

## Goal

The goal of this project is to explore the relationships between COVID-19 mortality and other factors, such as age, weight, race, et cetera. Our final "deliverable" will be a machine learning classification model that will use the factors which we determine to have meaningful effects on COVID-19 mortality to predict whether a patient will live or die from the disease, given their patient data.

## Data 

As mentioned before, the data we will be using in this project is at the micro-level as opposed to the macro-level. More specifically, we have obtained a data set of individual COVID-19 patient data records from the Center for Disease Control (CDC) website. The data set was originally more than 2.6 gigabytes in size, however we have since trimmed the data to make it more manageable for our project; it is now approximately 70.8 megabytes. The filtered data set can be found [here](./project-filtered-data.csv).

Before we began our exploratory data analysis (EDA) and model creation with R, we decided to further inspect the filtered data set in a Jupyter Notebook using Python. We found a large number of missing/nul/na/nan values in the filtered data, and after removing all such records, the data set we'll be using was reduced further from approximately 70.8 MB to approximately 15.3 MB. This trimmed version of the filtered data can be found [here](./project-trimmed-filtered-data.csv), while our Jupyter Notebook/Python source code is found [here](./src/data-exploration.ipynb).

## The Team

Our team has grown since our first project: we now have 6 members. The roles haven't changed much since the last project though:

  - **Jesse Freitag:** Overall Manager, Coder
  - **Charlie Clark:** Chief Coder, Quality Control
  - **Kailey Ali:** Note Taker, Quality Control
  - **Gavin Vergara:** Note Taker, Quality Control
  - **Qiushi Yin:** Coder, Quality Control
  - **Jhordyne Donaldson:** Quality Control, Note Taker

A copy of the team contract can be found [here](./project-2-group-contract.pdf).
