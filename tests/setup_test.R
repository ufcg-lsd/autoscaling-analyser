library(testthat)

run_policy_test <- function(config_file, output_file, expected_file) {
  
  system(paste("Rscript", here::here("src/main.R"), "--config", here::here(config_file)))
  real <- read.csv(here::here(output_file))
  expected <- read.csv(here::here(expected_file))
  
  test_that("Same timestamp", {
    expect_equal(real$timestamp, expected$timestamp)
  })
  
  test_that("Same System Utilization", {
    expect_equal(real$SystemUtilization, expected$SystemUtilization, tolerance = 1e-2)
  })
  
  test_that("Same Allocated Cores", {
    expect_equal(real$AllocatedCores, expected$AllocatedCores)
  })
  
  test_that("Same Decisions", {
    expect_equal(real$Decision, expected$Decision)
  })
  
  test_that("Same Cooldown Up", {
    expect_equal(real$CooldownUp, expected$CooldownUp)
  })
  
  test_that("Same Cooldown Down", {
    expect_equal(real$CooldownDown, expected$CooldownDown)
  })
}
