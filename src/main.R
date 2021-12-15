library(dplyr)

source(here::here("src/data_processing.R"))
source(here::here("src/reactive_static_policy.R"))
source(here::here("src/calculate_adi.R"))

data <- processing_data("data/util_data.csv")

# Test parameters
initial_allocated_cores <- 9
lower_bound <- 39
upper_bound <- 60

data_with_utilization <- reactive_static_policy(data, initial_allocated_cores,
                                                lower_bound, upper_bound)
data_with_adi <- calculate_adi(data_with_utilization, lower_bound, upper_bound)

sum(data_with_adi["ADI"])


#TODO - Implement reactive dynamic policy (adaptive step size)