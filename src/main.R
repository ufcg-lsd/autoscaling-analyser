library(dplyr)
library(yaml)
library(readr)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))
source(here::here("src/split_data.R"))
source(here::here("src/metrics/over_and_under_provisioning.R"))
source(here::here("src/metrics/accuracy.R"))
source(here::here("src/metrics/timeshare.R"))
source(here::here("src/metrics/jitter.R"))

# Config file
configs <- yaml.load_file("config.yaml")

# Data files
args = commandArgs(trailingOnly=TRUE)
#input_data <- read.csv(args[1])


# Test parameters
initial_allocated_cores <- configs$initial_allocated_cores
policy_parameters <- data.frame(lower_bound = configs$lower_bound,
                                upper_bound = configs$upper_bound,
                                step_size = configs$step_size)


if(configs$data_source == 'azure'){
  aggregate_data_azure()
  util_data <- processing_data_azure("data/azure/vm_cpu_readings_files/vmtable.csv", "data/azure/vm_cpu_readings_files/aggregate.csv")
  split_data_by_application_azure(util_data)

  files <- list.files(path="data/azure/app", pattern="*.csv", full.names=TRUE, recursive=FALSE)

  for(file in files){
    ifelse(!dir.exists(file.path("data/azure", "output")), dir.create(file.path("data/azure", "output")), FALSE)
    util_data_app <- read_csv(file)
    app <- util_data_app$deployment_id
    print(app)
    data_with_auto_scaling <- auto_scaling_algorithm(util_data_app, initial_allocated_cores,
                                                     policy_parameters)
    data_with_adi <- calculate_adi(data_with_auto_scaling,
                                   policy_parameters[["lower_bound"]],
                                   policy_parameters[["upper_bound"]])
    data_with_provisioning <- calculate_over_and_under_provisioning(data_with_auto_scaling)
 

    timeshare <- calculate_timeshare(data_with_provisioning)
    jitter <- calculate_jitter(data_with_provisioning)
    acc <- calculate_acc(data_with_provisioning)

    row_to_add <- data.frame(app, sum(data_with_adi["ADI"]), acc[[1]], acc[[2]], timeshare[[1]], timeshare[[2]], jitter)
    colnames(row_to_add) <- c("deployment_id", "ADI", "accuracy_over_provisioning", "accuracy_under_provisioning", "timeshare_over_provisioning","timeshare_under_provisioning", "jitter")
    write.table(unique(row_to_add), file = "data/azure/output/metrics.csv", sep=',',
                append = TRUE, quote = FALSE,
                col.names = !file.exists("data/azure/output/metrics.csv"), row.names = FALSE)
  }
}else{
  util_data <- processing_data("data/util_data.csv")
  
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
  
  
}


