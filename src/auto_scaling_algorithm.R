
auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters, time_parameters){

  cores_allocated <- initial_allocated_cores
  cooldown_start <- -1
  cooldown_countdown <- 0
  adding_time <- -1
  adding_cores <- 0
  
  for(row in 1:nrow(data)) {
    # Maximum system utilization is 100%
    system_utilization <- min((data[row,"Cores"]/cores_allocated) * 100, 100)
    current_time <- data[row, "timestamp"]
    
    if (system_utilization == 100) {
      data[row, "ExceededCores"] <- data[row,"Cores"] - cores_allocated
    } else {
      data[row, "ExceededCores"] <- 0 
    }
    
    data[row, "SystemUtilization"] <- system_utilization
    data[row, "AllocatedCores"] <- cores_allocated
    
    new_cores <- 0
    
    if (cooldown_start == current_time) {
      # TODO
      cooldown_countdown <- time_parameters$cooldown
      cooldown_start <- -1
      
    }
    
    if (adding_time == current_time) {
      # TODO
      new_cores <- adding_cores
      adding_time <- -1 # TODO Boot time
      adding_cores <- 0
    }
    
    if (cooldown_countdown == 0) {
      cores <- policy_parameters$func(system_utilization,
                                     policy_parameters,
                                     history = data["SystemUtilization"],
                                     current = row,
                                     allocated = cores_allocated)
      
      
      if (cores < 0) {
        # If cores are to be removed, they will be removed immediately.
        # The cooldown period will start just after the removal.
        
        new_cores <- cores
        cooldown_countdown <- time_parameters$cooldown
        
      } else if (cores > 0) {
        
        # If cores are to be added: 
        #   - they will have to wait for boot and warm-up times.
        #   - the cooldown period will start only after the boot time.
        
        warmup_time <- round(runif(
          1,
          time_parameters$warm_up$min,
          time_parameters$warm_up$max
        ))
        
        cooldown_start <- current_time + time_parameters$boot * 60
        
        adding_time <- cooldown_start + warmup_time * 60
        
        adding_cores <- cores
        
      }
      
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
