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
              CoresMax = max(Used) * n(),
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