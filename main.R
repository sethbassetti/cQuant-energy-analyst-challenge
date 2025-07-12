# Imports ----------------------------------------------------------------

source("R/data_utils.R")

library(dplyr)
library(janitor)
library(stringr)
library(readr)


# Task 1: Read Data ------------------------------------------------------

power_df <- read_files("data")
