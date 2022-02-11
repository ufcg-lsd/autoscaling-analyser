library(dplyr)
library(yaml)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

# Config file
configs <- yaml.load_file("config.yaml")

# Data files
args = commandArgs(trailingOnly=TRUE)
#input_data <- read.csv(args[1])

if(configs$data_source == 'azure'){
  util_data <- processing_data_azure("data/azure/vmtable.csv", "data/azure/sample_azure.csv")
}else{
  util_data <- processing_data("data/util_data.csv")
}

# Test parameters
initial_allocated_cores <- configs$initial_allocated_cores
policy_parameters <- data.frame(lower_bound = configs$lower_bound,
                                upper_bound = configs$upper_bound,
                                step_size = configs$step_size)

# Play around with util data
data_with_auto_scaling <- auto_scaling_algorithm(util_data, initial_allocated_cores,
                                                 policy_parameters)

# Play around with input data
#data_with_auto_scaling <- auto_scaling_algorithm(input_data, initial_allocated_cores,
#                                                  policy_parameters)

data_with_adi <- calculate_adi(data_with_auto_scaling,
                               policy_parameters[["lower_bound"]],
                               policy_parameters[["upper_bound"]])
sum(data_with_adi["ADI"])


