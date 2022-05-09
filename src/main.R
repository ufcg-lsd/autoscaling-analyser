library(dplyr)
library(yaml)
library(yardstick)
library(R.utils)
library(purrr)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))

# Command line args
args <- commandArgs(trailingOnly = TRUE, asValues = TRUE)
config_file <- ifelse(is.null(args$config), "config.yaml", args$config)

# Config file
configs <- yaml.load_file(config_file)

# Process data files
if (is.null(configs$process_data_func)) {
  # Data doesn't need to be treated
  input_data <- read.csv(here::here(configs$input_file))
} else  {
  # Data need special treatment
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

time_parameters <- configs$time

data_with_auto_scaling <-
  auto_scaling_algorithm(input_data,
                         initial_allocated_cores,
                         policy_parameters,
                         time_parameters)

readr::write_csv(data_with_auto_scaling, here::here(configs$output_file))

if (configs$metrics) {
  data_with_adi <- calculate_adi(data_with_auto_scaling,
                                 policy_parameters[["lower_bound"]],
                                 policy_parameters[["upper_bound"]])
  
  # TODO Criar um arquivo metrics em src/
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
  
  readr::write_csv(metrics, here::here(configs$metrics_output_file))
}
