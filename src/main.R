library(dplyr)
library(yaml)
library(yardstick)
library(R.utils)
library(purrr)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/metrics.R"))

# Command line args
args <- commandArgs(trailingOnly = TRUE, asValues = TRUE)
config_file <- ifelse(is.null(args$config), "config.yaml", args$config)

# Config file
configs <- yaml.load_file(config_file)

# Process data files
if (is.null(configs$process_data_func)) {
  # Data doesn't need to be processed
  input_data <- read.csv(here::here(configs$input_file))
} else  {
  # Data needs to be processed
  configs$process_data_func <- get(configs$process_data_func)
  input_data <- configs$process_data_func(here::here(configs$input_file))
}

# Config parameters
if (is.null(configs$initial_allocated_cores)) {

  initial_allocated_cores <- as.integer(input_data[1, "RealAllocatedCores"])
  input_data <- input_data[2:nrow(input_data),]
  
} else {
  
  initial_allocated_cores <- configs$initial_allocated_cores
  
}

policy_parameters <- configs$policies[[configs$policies$use]]
source(here::here(policy_parameters$src))
policy_parameters$func <- get(policy_parameters$func)

data_with_auto_scaling <-
  auto_scaling_algorithm(input_data,
                         initial_allocated_cores,
                         policy_parameters,
                         configs$application_start_time)

readr::write_csv(data_with_auto_scaling, here::here(configs$output_file))

if (configs$metrics) {
  metrics <- calculate_metrics(data_with_auto_scaling, policy_parameters)
  readr::write_csv(metrics, here::here(configs$metrics_output_file))
}
