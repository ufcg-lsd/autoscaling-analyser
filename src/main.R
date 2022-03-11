library(dplyr)
library(yaml)
library(stringr)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

# Data files
args = commandArgs(trailingOnly=TRUE)
input_data <- read.csv(args[1])
util_data <- processing_data("data/util_data.csv")

# Config file
configs <- yaml.load_file("config.yaml")

# Test parameters
initial_allocated_cores <- configs$initial_allocated_cores
policy_parameters <- data.frame(lower_bound = configs$lower_bound,
                                upper_bound = configs$upper_bound,
                                step_size = configs$step_size)

data_with_auto_scaling <- auto_scaling_algorithm(input_data,
                                                 initial_allocated_cores,
                                                 policy_parameters)

data_with_adi <- calculate_adi(data_with_auto_scaling,
                               policy_parameters$lower_bound,
                               policy_parameters$upper_bound)
# Saves data in output file
input_name <- str_remove(basename(args[1]), ".csv")
write.csv(data_with_adi, paste("output/", input_name, "_output.csv", sep=""), 
          row.names = FALSE)

# Prints ADI sum in the console
sum(data_with_adi["ADI"])
