---
title: "Yelp Challenge: Analysing the Predictive Capability of Text in Reviews"
subtitle: "Coursera Data Science Specialization Capstone Project"
author: "Giuliano Sposito (gsposito@gmail.com)"
date: "November, 2015"
---

## Introduction

This is the code repository for my final Capstone Project for the Johns Hopkins Data Science Specialization course offer by Coursera. In this repo we have all the code and the intermediary datasets used in the project. Through this guide its possible to reproduce all steps made in my report submited to the course.

## Problem Definition

I will study the ability of the texts, in the reviews from Yelp App, be used to predict things. For example, is it possible, through them, to predict the evaluation stars, if the establishment has free WiFi, or have parking, or if the text is useful, funny or cool, or even that business category that the review is assessing (Restaurants, Shop, etc.)?

Is it possible learn from that, what else makes a 5 star review? What would be the best approach for text prediction and how the limitations and accuracy of this approach? This kind of problem may be interesting used for the Yelp engineers itself, they can use this approach to expanding its database mining and classifying others review texts in the internet. Also may be possible lookup auto-complete business attributes (ou double-check inconsistenses) through the review text.

## Project Structure

The general approach I'll use is text mining the review texts (using TM R Library) and study efficiency of ML algorithms to predict some attributes of the business reviewed.

The project are coded in diferent scripts for each step of the analysis. Each steps loads data from previous step, process the data and save the results in files  for the next step. 

We took this approach to make a very modular study, so you can change specific parts, and also to save memory and proccesss time.

This are the basic workflow adopted in this analysis:

1. **Import data** from json original data into R structures (data frames)
1. **Merge and Select** perform the merge and subsetting the relevant data to this study
1. **Algorithm Selection** we'll study the performance of diverses ML algorithm in Text Mining problems
1. **Process Analysis** perform the analitical study in the data subset storing the results
1. **Report Generation** an `r markdown` script will read and consolidate the analysis results to generate the final report
1. **Presentation Report** an `R Presentation` (or `Slidify` script) will generate a summary presentation of the results

### File Description

Relevant files present in this project:

* **`import.R`** R Script in charge to read the `.json` original files, import the information and save the dataset in `.rdata` files. In the repository, this script are importing only `Business` and `Reviews` data, only these dataset will be used in the project study.
* **`pre_process_business.R`** R Script to prepare the `Business` for analysis (pre-process), will define some attributes and its values (as factors ou booleans) to be used in the text predicting analysis and also reclassify the busiss to a only one category.
* **`merge_review.R`*** R Script to pre-process the `Review` dataset renaming and defining features do be used, also merges the reviews with the `Business` dataset and makes a subset of 200 thousand registers to be used for analysis.
* **`predictive_analisys_lib.R`** In this R script are all functions in charge to performance the predictive analysis, could be transformed in a R Package in the future
* **`emotional_predictive_study.R`** this R script will perform an emotional analysis of text reviews using diferente sample size for training and diferent algorithms. All results are stored in the results folder. This study has the objective to see the different algorithms behaviors and performance.
* **`attributes_predictive_study.R`** this R script perform predictive analysis of severall business attributes selected to be studied in this work.
* **`report.Rmd`** R Markdown file that generates the report for submission

### Directory Structure

The subfolders in this project are used to store the raw dataset, intermediary data sets (processed data) and the results of analisys, according:

1. **`./json_data`**: folder where the original json files (`*.json`), download and uncompressed, are stored.
1. **`./raw_rdata`**: after import the json files into R structures (Data Frames), the data are saved in files in this folder as `*.rdata` files
1. **`./data`**: this folder will store the pre-processed data that will be used in the study. It's a merged and subset data from original `raw_data`.
1. **`./result`**: the data summary, model fitted and confusions matrix created during analysis of the data will be stored here. The final report (an `r markdown`) and presentation will use this data to generate the data analysis summary and conclusions.

## Source Code Know Issues

### RTextTool Library Error

There is a code erro in the RTextTool library, eventually while executing this code,  you get a messsage:

`Error in if (attr(weighting, "Acronym") == "tf-idf") weight <- 1e-09 : argument is of length zero`

Please follow this instructions: [StackOverflow: RTextTools - Create Matrix Got An Error](http://stackoverflow.com/questions/32513513/rtexttools-create-matrix-got-an-error)

### Manual download of the data

Besides we can provide a programatic way to download the necessary data to this study, we prefer left this task be done by you manually. The dataset provided here is part of the Yelp Dataset Challenge and the specific dataset used in this capstone corresponds to Round 6 of their challenge (the documentation mentions Round 5, but the datasets for Rounds 5 and 6 are identical). The dataset is approximately 575MB so you will need access to a good Internet connection to download it.

* [Download the dataset](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/yelp_dataset_challenge_academic_dataset.zip)

You need download the zip file and uncompress it in the folder `./json_data`. You can know more about the Yelp Challenge in [this link](http://www.yelp.com/dataset_challenge).