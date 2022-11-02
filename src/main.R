library(dplyr)
library(yaml)
library(yardstick)
library(R.utils)
library(purrr)
library(reticulate)

source(here::here("src/data_processing.R"))
source(here::here("src/data_processing/aggregate_files.R"))
source(here::here("src/data_processing/data_processing.R"))
source(here::here("src/data_processing/split_data.R"))
source(here::here("src/data_processing/calculate_exceeded_cores.R"))
source(here::here("src/metrics/adi.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/metrics.R"))
source(here::here("src/plot.R"))
source(here::here("src/plots/metrics.R"))
source(here::here("src/calculate_adi.R"))


# Command line args
args <- commandArgs(trailingOnly = TRUE, asValues = TRUE)
config_file <- ifelse(is.null(args$config), "config.yaml", args$config)

# Config file
configs <- yaml.load_file(config_file)

# Process data files
if (is.null(configs$process_data_func)) {
  # Data doesn't need to be processed
  input_data <- read.csv(here::here(configs$input_file))
} else if(configs$process_data_func == "process_azure_data"){
  aggregate_data_azure()
  dados_filtrados <- read_csv("data/azure/aggregate.csv") %>%
    filter()
  
  util_data <- calculates_usage_azure("data/azure/vmtable.csv", "data/azure/aggregate.csv")
  split_data_by_application_azure(util_data)
} else  {
  # Data needs to be processed
  configs$process_data_func <- get(configs$process_data_func)
  input_data <- configs$process_data_func(here::here(configs$input_file))
}

#input_data <- read_csv("data/azure/app/++ANu7Id8VfniUC4vd6oCKiKBnzD3oc7r+aHCdo43oMy3tPv+cAkyfgZHTqw+FCqsx2zvinzDCfWilsjShlw==.csv")

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
                         configs$application_start_time,
                         configs$scheduling)

readr::write_csv(data_with_auto_scaling, here::here(configs$output_file))

if (configs$plot) {
  plot_simulation(data_with_auto_scaling, policy_parameters, configs)
}

if (configs$metrics) {
  metrics <- calculate_metrics(data_with_auto_scaling, policy_parameters, configs$policies$use)
  readr::write_csv(metrics, here::here(configs$metrics_output_file))
}

if (configs$policies$use == 'target_tracking'){
  
  
}
write.table(metrics, file = here::here(configs$metrics_output_file), sep = ",",
            append = TRUE, quote = FALSE,
            col.names = FALSE, row.names = FALSE)

metrics <- read_csv("output/metrics.csv")

plot_adi(metrics)

data_with_adi <- calculate_adi(data_with_auto_scaling,
              policy_parameters[["lower_bound"]],
              policy_parameters[["upper_bound"]])

ggplot(data_with_adi, aes(x=timestamp )) + 
  geom_line(aes(y = ADI), color = "darkred") + 
  geom_line(aes(y = SystemUtilization), color="steelblue")

library(tidyverse)
data_with_adi["Lower_bound"]<-policy_parameters[["lower_bound"]] 
data_with_adi["Upper_bound"]<-policy_parameters[["upper_bound"]] 

teste <- data_with_adi %>% 
  select("timestamp","ADI", "SystemUtilization", "Lower_bound", "Upper_bound") %>% 
  pivot_longer(-timestamp, names_to = "Variáveis", values_to = "Porcentagem")

ggplot(teste, aes(timestamp, Porcentagem, colour = Variáveis)) + geom_line()
