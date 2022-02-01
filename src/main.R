library(dplyr)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

args = commandArgs(trailingOnly=TRUE)
input_data <- read.csv(args[1])
util_data <- processing_data("data/util_data.csv")

# Test parameters
initial_allocated_cores <- 2
policy_parameters <- data.frame(lower_bound = 39,upper_bound = 60,step_size = 2)

# Play around with util data
#data_with_auto_scaling <- auto_scaling_algorithm(util_data, initial_allocated_cores,
#                                                 policy_parameters)

# Play around with input data
data_with_auto_scaling <- auto_scaling_algorithm(input_data, initial_allocated_cores,
                                                  policy_parameters)

data_with_adi <- calculate_adi(data_with_auto_scaling,
                               policy_parameters[["lower_bound"]],
                               policy_parameters[["upper_bound"]])
sum(data_with_adi["ADI"])


