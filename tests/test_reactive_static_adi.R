library(dplyr)
library(testthat)

source(here::here("src/data_processing.R"))
source(here::here("src/reactive_static_policy.R"))
source(here::here("src/calculate_adi.R"))

data <- processing_data("data/util_data.csv")

adi_sum <- function(data, initial_allocated_cores, lower_bound, upper_bound,
                    step_size) {
  data_with_utilization <- reactive_static_policy(data, initial_allocated_cores,
                                                  lower_bound, upper_bound,
                                                  step_size)
  data_with_adi <- calculate_adi(data_with_utilization, lower_bound, upper_bound)
  return (sum(data_with_adi["ADI"]))
}

# Test parameters
upper_bound <- 60
lower_bound <- 39
step_size <- 2

test_that("ADI sum", {
  expect_equal(round(
    adi_sum(data, 9, lower_bound, upper_bound, step_size), digits=2), 3.67)
  expect_equal(round(
    adi_sum(data, 10, lower_bound, upper_bound, step_size), digits=2), 15.23)
  expect_equal(round(
    adi_sum(data, 8, lower_bound, upper_bound, step_size), digits=2), 18.01)
})

# Conclusion: 9 initial allocated cores is the best option
# for this data!
