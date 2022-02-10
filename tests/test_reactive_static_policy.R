source(here::here("tests/setup_test.R"))

policy_parameters <- data.frame(lower_bound = 39, upper_bound = 60,
                                step_size = 2)

start_time <- Sys.time()
policy_data <- auto_scaling_algorithm(data, initial_allocated_cores = 10,
                                      policy_parameters)
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


policy_data <- auto_scaling_algorithm(data, initial_allocated_cores = 2,
                                      policy_parameters)

test_that("SystemUtilization over 100%", {
  expect_equal(policy_data$SystemUtilization[1], 100)
  expect_equal(policy_data$SystemUtilization[2], 100)
})

test_that("Exceeded cores", {
  expect_equal(round(policy_data$ExceededCores[1], digits=2), 2.50)
  expect_equal(round(policy_data$ExceededCores[2], digits=2), 0.06)
})

policy_data <- auto_scaling_algorithm(data_decreasing,
                                      initial_allocated_cores = 12,
                                      policy_parameters)

test_that("SystemUtilization 0%", {
  expect_equal(policy_data$SystemUtilization[40], 0)
  expect_equal(policy_data$SystemUtilization[41], 0)
})


