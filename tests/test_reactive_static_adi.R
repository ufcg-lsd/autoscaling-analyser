source(here::here("tests/setup_test.R"))
source(here::here("src/calculate_adi.R"))

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
    adi_sum(data, 2, policy_parameters), digits=2), 105.26)
  expect_equal(round(
    adi_sum(data, 4, policy_parameters), digits=2), 65.65)
})

test_that("ADI underutilization", {
  expect_equal(round(
    adi_sum(data_decreasing, 14, policy_parameters), digits=2), 267.40)
  expect_equal(round(
    adi_sum(data_decreasing, 15, policy_parameters), digits=2), 234.04)
})

# TODO Round


