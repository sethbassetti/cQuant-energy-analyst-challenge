# Imports ----------------------------------------------------------------

source("R/data_utils.R")
source("R/plot_utils.R")

library(dplyr)
library(janitor)
library(stringr)
library(readr)
library(conflicted)
library(tidyr)
library(ggplot2)
library(lubridate)
library(ggbump)


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
highest_volatility_per_year <- compute_highest_volatility_per_year(
  hourly_volatility_df
)
readr::write_csv(highest_volatility_per_year, "output/MaxVolatilityByYear.csv")


# Task 7: Format Data for cQuant Consumption -----------------------------

format_and_write_cQuant_files(clean_df)


# Bonus Task: Mean Plots -------------------------------------------------

hub_plot <- plot_avg_monthly(average_price_df, "HB")
lz_plot <- plot_avg_monthly(average_price_df, "LZ")

ggsave("output/SettlementHubAveragePriceByMonth.png", hub_plot, width = 12)
ggsave("output/LoadZoneAveragePriceByMonth.png", lz_plot, width = 12)


# Bonus Task: Volatility Plots -------------------------------------------

hourly_volatility_plot <- plot_hourly_volatility(hourly_volatility_df)
ggsave(
  "output/HourlyVolatilityComparisonByYear.png",
  hourly_volatility_plot,
  width = 12
)

# Bonus Task: Hourly Shape Profile Computation ---------------------------

normalized_hourly_shape_df <- compute_hourly_shape_profiles(clean_df)
write_hourly_shape_profiles(normalized_hourly_shape_df)
