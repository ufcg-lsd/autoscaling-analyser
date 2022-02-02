# Load libraries
library(dplyr)
library(testthat)

# Load source code
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/data_processing.R"))

# Load data files
data <- processing_data("tests/util_data.csv")
data_decreasing <- read.csv("tests/decreasing_data.csv")

adi_sum <- function(data, initial_allocated_cores, policy_parameters) {
  data_with_auto_scaling <- auto_scaling_algorithm(data, initial_allocated_cores,
                                                   policy_parameters)
  data_with_adi <- calculate_adi(data_with_auto_scaling,
                                 policy_parameters[["lower_bound"]],
                                 policy_parameters[["upper_bound"]])
  return (sum(data_with_adi["ADI"]))
}
