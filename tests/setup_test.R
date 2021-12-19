
adi_sum <- function(data, initial_allocated_cores, policy_parameters) {
  data_with_auto_scaling <- auto_scaling_algorithm(data, initial_allocated_cores,
                                                   policy_parameters)
  data_with_adi <- calculate_adi(data_with_auto_scaling,
                                 policy_parameters[["lower_bound"]],
                                 policy_parameters[["upper_bound"]])
  return (sum(data_with_adi["ADI"]))
}

