
auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters){
  
  cores_allocated <- initial_allocated_cores
  cooldown_countdown <- 0
  cooldown_cores <- 0
  
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
    
    new_cores <- 0
    if (cooldown_countdown == 0) {
      
      cooldown_cores <- policy_parameters$fun(system_utilization,
                                              policy_parameters,
                                              history = data["SystemUtilization"],
                                              current = row)
      
      if (cooldown_cores != 0) {
        cooldown_countdown <- policy_parameters$cooldown
      }
      
    } else if (cooldown_countdown == 1) {
      
      # The addition of new cores is done by the end of the cooldown period
      new_cores <- cooldown_cores
      cooldown_cores <- 0
      
    }
    
    cooldown_countdown <- max(0, cooldown_countdown - 1)
    
    # Minimum allocated cores is the min_cap, and maximum is max_cap
    cores_allocated <- min(max(cores_allocated + new_cores,
                           policy_parameters[["min_cap"]]),
                           policy_parameters[["max_cap"]])
    data[row, "NewCores"] <- new_cores
  }
  
  return(data)
}
