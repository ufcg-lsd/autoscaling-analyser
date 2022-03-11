library(readr)

processing_data <- function(filename){
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
              Allocated = sum(InstanceCapacity),
              SystemRealUtilization = min((Cores/Allocated) * 100, 100))
  
  return(data)
}
