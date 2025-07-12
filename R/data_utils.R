library(readr)
library(dplyr)
library(janitor)
library(lubridate)

#' Reads all files in a given directory
#'
#' This function takes in a directory, and returns a tibble from the concatenated data in that directory.
#'
#' @param directory The directory to grab files from
#' @returns A tibble composed of all data from the given directory
#' @examples
#' read_files("data")
read_files <- function(directory) {
  all_files <- list.files(directory, full.names = TRUE)
  df <- readr::read_csv(all_files)

  return(df)
}
