source(here::here("tests/setup_test.R"))

config_file <- "tests/simple_scaling_test/config.yaml"
output_file <- "tests/simple_scaling_test/simulation_output.csv"
expected_file <- "tests/simple_scaling_test/expected_output.csv"

run_policy_test(config_file, output_file, expected_file)
