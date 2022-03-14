library(dplyr)
library(yaml)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

# Data files
# args = commandArgs(trailingOnly=TRUE)
# input_data <- read.csv(args[1])
util_data <- processing_data(here::here("itallo/master_data_api_070222_ds-env291-stable.csv"))

# Config file
configs <- yaml.load_file("config.yaml")

# Test parameters
initial_allocated_cores <- as.integer(util_data[1, "Allocated"])
util_data <- util_data[2:nrow(util_data),]
policy_parameters <- configs$policies[[configs$policies$to_use]]
source(here::here(policy_parameters$src))
policy_parameters$fun <- get(policy_parameters$fun)

# Play around with util data
data_with_auto_scaling <- auto_scaling_algorithm(util_data, initial_allocated_cores,
                                                policy_parameters)
readr::write_csv(data_with_auto_scaling, "itallo/output_master_data_api_070222_ds-env291-stable.csv")

# Play around with input data
# data_with_auto_scaling <- auto_scaling_algorithm(input_data, initial_allocated_cores,
#                                                   policy_parameters)

data_with_adi <- calculate_adi(data_with_auto_scaling,
                               policy_parameters[["lower_bound"]],
                               policy_parameters[["upper_bound"]])
sum(data_with_adi["ADI"])


