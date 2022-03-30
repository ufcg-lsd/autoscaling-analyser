library(sjmisc)

processing_data <- function(filename){
  raw_data <- read.csv(filename)
  data <- raw_data %>% 
    mutate(InstanceCapacity = dplyr::case_when(
      InstanceType == "t2.medium" ~ 2,
      InstanceType == "t2.micro" ~ 1,
      InstanceType == "c5.large" ~ 2,
      InstanceType == "c5.xlarge" ~ 4,
      InstanceType == "m5d.large" ~ 2,
      InstanceType == "m5d.xlarge" ~ 4,
      InstanceType == "r5.2xlarge" ~ 8,
      InstanceType == "t3.micro" ~ 2)) %>%
    mutate(Used = InstanceCapacity * Average / 100) %>%
    group_by(timestamp) %>%
    summarise(Cores = sum(Used))
  
  return(data)
}

# Aggregates files related to VM usage
aggregate_data_azure <- function(){
  files_workload <- list.files(path="data/azure/vm_cpu_readings_files", pattern="*.csv", full.names=TRUE, recursive=FALSE)
  for (file in files_workload){
    if(str_contains(file, "vm_cpu_readings-file")){
      csv_to_add <- read.csv(file)
      colnames(csv_to_add) <- c("timestamp", "vm_id", "min_cpu", "max_cpu", "avg_cpu")
      write.table(csv_to_add, file = ("data/azure/vm_cpu_readings_files/aggregate.csv"), sep = ",",
                  append = TRUE, quote = FALSE,
                  col.names = !file.exists(("data/azure/vm_cpu_readings_files/aggregate.csv")), row.names = FALSE)
     }
  }
}

# Processing for Azure data
processing_data_azure <- function(filename_vm_table, filename_vm_cpu){
  # Add column names
  vm_info <- read.csv(filename_vm_table)
  colnames(vm_info) <- c("vm_id", "subscription_id", "deployment_id", "timestamp_vm_created", "timestamp_vm_deleted", 
                         "max_cpu_vm", "avg_cpu_vm", "p95_max_cpu", "vm_category", "vm_virtual_core_count_bucket",
                         "vm_memory_bucket")
  vm_cpu <- read.csv(filename_vm_cpu)
  #colnames(vm_cpu) <- c("timestamp", "vm_id", "min_cpu", "max_cpu", "avg_cpu")
  
  # Concatenate the information from the two tables with a left join
  left_join<-left_join(vm_cpu,vm_info,by="vm_id")

  # Calculates how much of the instance being used
  data <- left_join %>% 
    mutate(Used = as.numeric(vm_virtual_core_count_bucket) * as.numeric(avg_cpu) / 100) %>%
    na.omit() %>%
    group_by(timestamp, deployment_id) %>%
    summarise(Cores = sum(Used))
  
  return(data)
}