library(dplyr)
library(testthat)

source(here::here("src/data_processing.R"))
source(here::here("src/auto_scaling_algorithm.R"))
source(here::here("src/calculate_adi.R"))
source(here::here("tests/setup_test.R"))

# Load data files
data <- processing_data("data/util_data.csv")
decreasing_data <- read.csv("data/decreasing_data.csv")

policy_parameters <- data.frame(lower_bound = 39, upper_bound = 60,
                                step_size = 2)

test_that("ADI normal utilization", {
  expect_equal(round(
    adi_sum(data, 9, policy_parameters), digits=2), 3.67)
  expect_equal(round(
    adi_sum(data, 10, policy_parameters), digits=2), 15.23)
  expect_equal(round(
    adi_sum(data, 8, policy_parameters), digits=2), 18.01)
})

test_that("ADI overutilization", {
  expect_equal(round(
    adi_sum(data, 2, policy_parameters), digits=2), 231.87)
  expect_equal(round(
    adi_sum(data, 4, policy_parameters), digits=2), 78.22)
})

test_that("ADI underutilization", {
  expect_equal(round(
    adi_sum(decreasing_data, 14, policy_parameters), digits=2), 267.40)
  expect_equal(round(
    adi_sum(decreasing_data, 15, policy_parameters), digits=2), 234.04)
})



