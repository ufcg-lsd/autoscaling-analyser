source(here::here("tests/setup_test.R"))

config_file <-"tests/target_tracking_test/config.yaml" 
output_file <- "tests/target_tracking_test/simulation_output.csv"
expected_file <- "tests/target_tracking_test/expected_output.csv"

run_policy_test(config_file, output_file, expected_file)
