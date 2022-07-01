processing_data_marcella <- function(filename){
  raw_data <- read.csv(filename)
  data <- raw_data %>% 
    group_by(timestamp) %>%
    summarise(SystemUtilization = mean(Average))
  
  return(data)
}
