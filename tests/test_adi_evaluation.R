# Add tests library
library(testthat)

# Set working directory to avoid wrong PATHs
setwd("/home/kilian/Computer-Science/PIBIC/autoscaling-analyser")

start_time <- Sys.time()

# Run ADI script
source("src/adi_evaluation.R")

end_time <- Sys.time()
running_time <- end_time - start_time
print (running_time) 

test_that("ADI test", {
  expect_equal(round(data[["ADI"]][1], digits=3), 6.667)
  expect_equal(round(data[["ADI"]][2], digits=3), 16.083)
  expect_equal(round(data[["ADI"]][3], digits=3), 0.0)
})

test_that("Utilization test", {
  expect_equal(round(data[["Utilization"]][1], digits=3), 66.667)
  expect_equal(round(data[["Utilization"]][2], digits=3), 22.917)
  expect_equal(round(data[["Utilization"]][3], digits=3), 45.082)
})

test_that("Current capacity test", {
  expect_equal(data[["CurrentCapacity"]][1], 2)
  expect_equal(data[["CurrentCapacity"]][2], 4)
  expect_equal(data[["CurrentCapacity"]][3], 2)
})

test_that("Instance capacity test", {
  expect_equal(data[["InstanceCapacity"]][1], 2)
  expect_equal(data[["InstanceCapacity"]][2], 2)
  expect_equal(data[["InstanceCapacity"]][3], 2)
})


