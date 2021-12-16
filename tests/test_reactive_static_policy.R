library(dplyr)
library(testthat)

source(here::here("src/data_processing.R"))
source(here::here("src/reactive_static_policy.R"))

data <- processing_data("data/util_data.csv")

# Global test parameters
initial_allocated_cores <- 10
lower_bound <- 39
upper_bound <- 60
step_size <- 2

start_time <- Sys.time()

policy_data <- reactive_static_policy(data, initial_allocated_cores,
                                      lower_bound, upper_bound,
                                      step_size)

end_time <- Sys.time()
running_time <- end_time - start_time
print (running_time) 

test_that("SystemUtilization test", {
  expect_equal(round(policy_data$SystemUtilization[1], digits=2), 45.03)
  expect_equal(round(policy_data$SystemUtilization[2], digits=2), 40.58)
  expect_equal(round(policy_data$SystemUtilization[3], digits=2), 40.35)
  expect_equal(round(policy_data$SystemUtilization[12], digits=2), 37.75)
  expect_equal(round(policy_data$SystemUtilization[13], digits=2), 55.44)
  expect_equal(round(policy_data$SystemUtilization[38], digits=2), 60.92)
  expect_equal(round(policy_data$SystemUtilization[39], digits=2), 42.20)
  expect_equal(round(policy_data$SystemUtilization[48], digits=2), 38.93)
  expect_equal(round(policy_data$SystemUtilization[49], digits=2), 55.06)
})

test_that("AllocatedCores test", {
  expect_equal(policy_data$AllocatedCores[1], digits=2, 10)
  expect_equal(policy_data$AllocatedCores[2], digits=2, 10)
  expect_equal(policy_data$AllocatedCores[3], digits=2, 10)
  expect_equal(policy_data$AllocatedCores[12], digits=2, 10)
  expect_equal(policy_data$AllocatedCores[13], digits=2, 8)
  expect_equal(policy_data$AllocatedCores[38], digits=2, 8)
  expect_equal(policy_data$AllocatedCores[39], digits=2, 10)
  expect_equal(policy_data$AllocatedCores[48], digits=2, 10)
  expect_equal(policy_data$AllocatedCores[49], digits=2, 8)
})


