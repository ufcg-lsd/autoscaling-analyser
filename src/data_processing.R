processing_data <- function(df){
  data <- df %>% 
    mutate(InstanceCapacity = dplyr::case_when(InstanceType == "t2.medium" ~ 2,
                                                InstanceType == "t2.micro" ~ 1,
                                                InstanceType == "c5.large" ~ 2,
                                                InstanceType == "c5.xlarge" ~ 4,
                                                InstanceType == "m5d.large" ~ 2,
                                                InstanceType == "m5d.xlarge" ~ 4,
                                                InstanceType == "r5.2xlarge" ~ 8,
                                                InstanceType == "t3.micro" ~ 2)) %>%
    
    #mutate(datetime = as.POSIXct(timestamp, origin="1970-01-01")) %>%
    mutate(Used = InstanceCapacity * Average / 100) %>%
    group_by(timestamp) %>%
    summarise(Cores = sum(Used))
}
