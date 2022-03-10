source(here::here("src/policies/reactive_static_policy.R"))

auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters){
  cores_allocated <- initial_allocated_cores
  
  for(row in 1:nrow(data)) {
    # Maximum system utilization is 100%
    system_utilization <- min((data[row,"Cores"]/cores_allocated) * 100, 100)
    
    if (system_utilization == 100) {
      data[row, "ExceededCores"] <- data[row,"Cores"] - cores_allocated
    } else {
      data[row, "ExceededCores"] <- 0 
    }
    
    data[row, "SystemUtilization"] <- system_utilization
    data[row, "AllocatedCores"] <- cores_allocated
    
    new_cores <- reactive_static_policy(system_utilization,
                                        policy_parameters[["upper_bound"]],
                                        policy_parameters[["lower_bound"]],
                                        policy_parameters[["up_step_size"]],
                                        policy_parameters[["down_step_size"]])
    
    # Minimum allocated cores is the min_cap, and maximum is max_cap
    cores_allocated <- min(max(cores_allocated + new_cores,
                           policy_parameters[["min_cap"]]),
                           policy_parameters[["max_cap"]])
    data[row, "NewCores"] <- new_cores
  }
  
  return(data)
}
