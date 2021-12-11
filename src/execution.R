library(readr)
library(dplyr)

source(here::here("src/data_processing.R"))
source(here::here("src/system_utilization.R"))
source(here::here("src/calculate_adi.R"))

df <- read_csv("src/data/util_data.csv")

data <- processing_data(df)

alocated_cores_initial <- 10
lower_bound <- 39
upper_bound <- 60

data_with_utilization <- calculate_allocated_cores_and_utilization(data, alocated_cores_initial, lower_bound, upper_bound)
data_with_adi <- calculate_adi(data_with_utilization, lower_bound, upper_bound)

sum(data_with_adi["ADI"])


#TODO - step size parametrizavel