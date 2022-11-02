library(readr)
library(dplyr)

process_util_data <- function(filename){
  raw_data <- read.csv(filename)
  
  cpu_info <- read_csv(here::here("data/cpu_info.csv"), 
                       col_types = cols_only(
                         InstanceType = col_character(),
                         vCPUs = col_integer()
                       ))
  
  cpu_info <- cpu_info %>% rename(InstanceCapacity = vCPUs)
  data <- raw_data %>% 
    left_join(cpu_info, by = "InstanceType") %>%
    mutate(Used = InstanceCapacity * Average / 100) %>%
    group_by(timestamp) %>%
    summarise(Cores = sum(Used),
              N = n(),
              CoresMax = max(Used) * n(),
              RealAllocatedCores = sum(InstanceCapacity),
              RealSystemUtilization = min((Cores/RealAllocatedCores) * 100, 100))

  return(data)
}

calculates_usage_azure <- function(filename_vm_table, filename_vm_cpu){
  
  # Add column names
  vm_info <- read.csv(filename_vm_table)
  colnames(vm_info) <- c("vm_id", "subscription_id", "deployment_id", "timestamp_vm_created", "timestamp_vm_deleted", 
                         "max_cpu_vm", "avg_cpu_vm", "p95_max_cpu", "vm_category", "vm_virtual_core_count_bucket",
                         "vm_memory_bucket")
  vm_cpu <- read.csv(filename_vm_cpu)
  
  # Concatenate the information from the two tables with a left join
  left_join<-left_join(vm_cpu,vm_info,by="vm_id")
  
  # Calculates how much of the instance being used
  data <- left_join %>%
    mutate(Used = as.numeric(vm_virtual_core_count_bucket) * as.numeric(avg_cpu) / 100) %>%
    na.omit() %>%
    group_by(timestamp, deployment_id) %>%
    summarise(Cores = sum(Used),
              N = n(),
              CoresMax = max(Used) * n(),
              RealAllocatedCores = sum(as.numeric(vm_virtual_core_count_bucket)),
              RealSystemUtilization = min((Cores/RealAllocatedCores) * 100, 100))
  
  gc()
  return(data)
}
process_util_data_max <- function(filename){
  raw_data <- read.csv(filename)
  
  cpu_info <- read_csv(here::here("data/cpu_info.csv"), 
                       col_types = cols_only(
                         InstanceType = col_character(),
                         vCPUs = col_integer()
                       )) %>% rename(InstanceCapacity = vCPUs)
  
  data <- raw_data %>% 
    left_join(cpu_info, by = "InstanceType") %>%
    mutate(Used = InstanceCapacity * Average / 100) %>%
    group_by(timestamp) %>%
    summarise(Cores = sum(Used),
              N = n(),
              CoresMax = max(Used) * n(),
              RealAllocatedCores = sum(InstanceCapacity),
              RealSystemUtilization = min((Cores/RealAllocatedCores) * 100, 100))
  gc()
  return(data)
}



