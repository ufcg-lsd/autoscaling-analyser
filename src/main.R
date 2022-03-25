library(dplyr)
library(yaml)
library(yardstick)
library(R.utils)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

# Command line args
args <- commandArgs(trailingOnly = TRUE, asValues = TRUE)
config_file <- ifelse(is.null(args$config), "config.yaml", args$config)

# Config file
configs <- yaml.load_file(config_file)

# Data files
input_data <- processing_data(here::here(configs$input_file))

# Config parameters

if (is.null(configs$initial_allocated_cores)) {

  initial_allocated_cores <- as.integer(input_data[1, "RealAllocatedCores"])
  input_data <- input_data[2:nrow(input_data),]
  
} else {
  
  initial_allocated_cores <- configs$initial_allocated_cores
  
}


policy_parameters <- configs$policies[[configs$policies$to_use]]
source(here::here(policy_parameters$src))
policy_parameters$fun <- get(policy_parameters$fun)

# Play around with util data
data_with_auto_scaling <- auto_scaling_algorithm(input_data, initial_allocated_cores,
                                                policy_parameters)

data_with_adi <- calculate_adi(data_with_auto_scaling,
                               policy_parameters[["lower_bound"]],
                               policy_parameters[["upper_bound"]])

metrics <- tibble(
  SimulatedADI = sum(data_with_adi["ADI"]),
  RealADI = sum(data_with_adi["RealADI"]),
  ADI_PDIFF = (SimulatedADI/RealADI - 1)*100,
  MAE = mae_vec(
    data_with_adi$RealAllocatedCores,
    data_with_adi$AllocatedCores
  ),
  SMAPE = smape_vec(
    data_with_adi$RealAllocatedCores,
    data_with_adi$AllocatedCores
  ),
  PDIFF = (
    sum(data_with_adi$AllocatedCores) - sum(data_with_adi$RealAllocatedCores)
  ) / sum(data_with_adi$RealAllocatedCores) * 100
)

readr::write_csv(data_with_adi, here::here(configs$output_file))
readr::write_csv(metrics, here::here(configs$metrics_output_file))
