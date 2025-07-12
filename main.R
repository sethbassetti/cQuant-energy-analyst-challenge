# Imports ----------------------------------------------------------------

source("R/data_utils.R")

library(dplyr)
library(janitor)
library(stringr)
library(readr)
library(conflicted)


# Task 1: Read Data ------------------------------------------------------

power_df <- read_files("data")

# Clean Data -------------------------------------------------------------
clean_df <- clean_df(power_df)


# Task 2: Compute Average Price ------------------------------------------

average_price_df <- compute_average_price(clean_df)

# Task 3: Write CSV to Disk ----------------------------------------------

readr::write_csv(average_price_df, "output/AveragePriceByMonth.csv")


# Task 4: Hourly Volatility ----------------------------------------------

hourly_volatility_df <- compute_hourly_volatility(clean_df)


# Task 5: Write Volatility to Disk ---------------------------------------

readr::write_csv(hourly_volatility_df, "output/HourlyVolatilityByYear.csv")

# Task 6: Determine Highest Volatility -----------------------------------
