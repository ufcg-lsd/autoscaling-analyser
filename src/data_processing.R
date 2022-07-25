library(readr)

process_util_data <- function(filename){
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
              RealAllocatedCores = sum(InstanceCapacity),
              RealSystemUtilization = min((Cores/RealAllocatedCores) * 100, 100))

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
    summarise(Cores = max(Used) * n(),
              RealAllocatedCores = sum(InstanceCapacity),
              SystemRealUtilization = min((Cores/RealAllocatedCores) * 100, 100))
  
  return(data)
}

process_experiment_data <- function(processed_data, version, day){
  # Read
  raw_data <- read.csv(filename)
  cpu_info <- read_csv(here::here("data/cpu_info.csv"),
                       col_types = cols_only(
                         InstanceType = col_character(),
                         vCPUs = col_integer()
                       )) %>% rename(InstanceCapacity = vCPUs)

  # Process
  processed_data <- raw_data %>%
    left_join(cpu_info, by = "InstanceType") %>%
    mutate(Used = InstanceCapacity * Average / 100) %>%
    group_by(timestamp, Version) %>%
    summarise(Cores = sum(Used),
              RealAllocatedCores = sum(InstanceCapacity),
              RealSystemUtilization = min((Cores/RealAllocatedCores) * 100, 100))

  # Filter
  data_filtered_by_version <- filter(processed_data, Version == version)
  data_split_by_days <- data_filtered_by_version %>%
    mutate(date = as.POSIXct(timestamp, origin="1970-01-01")) %>% 
    mutate(timestamp_day = timestamp %/% 86400) %>%
    group_by(timestamp_day) %>% group_split()
  data <- data_split_by_days[[day]]
  
  return(data)
}
