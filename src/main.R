library(dplyr)
library(yaml)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

# Data files
args = commandArgs(trailingOnly=TRUE)
input_data <- read.csv(args[1])
util_data <- processing_data(here::here("itallo/master_data_api_070222.csv"))

# Config file
configs <- yaml.load_file("config.yaml")

# Test parameters
initial_allocated_cores <- as.integer(util_data[1, "Allocated"])
util_data <- util_data[2:nrow(util_data),]
policy_parameters <- data.frame(lower_bound = configs$lower_bound,
                                upper_bound = configs$upper_bound,
                                up_step_size = configs$up_step_size,
                                down_step_size = configs$down_step_size,
                                min_cap = configs$min_cap,
                                max_cap = configs$max_cap)

# Play around with util data
data_with_auto_scaling <- auto_scaling_algorithm(util_data, initial_allocated_cores,
                                                policy_parameters)
readr::write_csv(data_with_auto_scaling, "itallo/output_master_data_api_070222.csv")

# Play around with input data
# data_with_auto_scaling <- auto_scaling_algorithm(input_data, initial_allocated_cores,
#                                                   policy_parameters)

data_with_adi <- calculate_adi(data_with_auto_scaling,
                               policy_parameters[["lower_bound"]],
                               policy_parameters[["upper_bound"]])
sum(data_with_adi["ADI"])


