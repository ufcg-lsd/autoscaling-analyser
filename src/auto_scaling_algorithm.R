
auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters, time_parameters){
  cores_allocated <- initial_allocated_cores
  
  cooldown <- get_cooldown(policy_parameters$cooldown)
  
  prior_cores <- 0
  
  # Cooldown counters
  cooldown_up_start <- 0
  cooldown_countdown <- data.frame(
    up = 0,
    down = 0
  )
  
  adding_time <- c() # Timestaps when there is a scaling operation
  adding_cores <- c()
  
  for(row in 1:nrow(data)) {
    # Iterate over each timestamp
    new_cores <- 0
    
    if (length(adding_time) > 0 && adding_time[1] == current_time) {
      
      new_cores <- adding_cores[1]
      adding_time <- adding_time[-1]
      adding_cores <- adding_cores[-1]

      cores_allocated <- 
        min(
          max(cores_allocated + new_cores, policy_parameters[["min_cap"]]),
          policy_parameters[["max_cap"]]
        )
      
    }

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
    
    # Scale up countdown reset
    if (cooldown_up_start == current_time) {
      cooldown_countdown$up <- cooldown$up
      cooldown_up_start <- -1
    }
    
    # Scale operation based on policy 
    cores <- policy_parameters$func(
      system_utilization,
      policy_parameters,
      history = data["SystemUtilization"],
      current = row,
      allocated = cores_allocated
    )
    
    if (cores < 0) {

      if (cooldown_countdown$down == 0 && cooldown_countdown$up == 0) {
        new_cores <- new_cores + cores
        
        # If cores are to be removed, they will be removed immediately.
        # Minimum allocated cores is the min_cap, and maximum is max_cap
        cores_allocated <-
          min(max(cores_allocated + cores, policy_parameters[["min_cap"]]),
              policy_parameters[["max_cap"]])
        
        # The cooldown period will start just after the removal.
        cooldown_countdown$down <- cooldown$down
      }
      
    } else if (cores > 0) {
      
      add_cores <- cores
      
      if (cooldown_countdown$down != 0) cooldown_countdown$down <- 0
      
      if (cooldown_countdown$up != 0) {
        
        if (add_cores > prior_cores) {
          add_cores <- add_cores - prior_cores
          cooldown_countdown$up <- 0
        }
        
      }
      
      if (cooldown_countdown$up == 0) {
        
        new_cores <- new_cores + add_cores
        prior_cores <- cores
      
        # If cores are to be added: 
        #   - they will have to wait for boot and warm-up times.
        #   - the cooldown period will start only after the boot time.
        
        warmup_time <- round(runif(
          1,
          time_parameters$warm_up$min,
          time_parameters$warm_up$max
        ))
        
        cooldown_up_start <- current_time + time_parameters$boot * 60
        adding_time <- c(adding_time, cooldown_up_start + warmup_time * 60)
        adding_cores <- c(adding_cores, add_cores)
        
      }
      
    }

    # Decrease cooldown countdowns
    cooldown_countdown$up <- max(0, cooldown_countdown$up - 1)
    cooldown_countdown$down <- max(0, cooldown_countdown$down - 1)

    data[row, "NewCores"] <- new_cores
  }
  
  return(data)
}

get_cooldown <- function(cooldown_param) {
  # TODO What if you don't add the cooldown param?
  if (is.atomic(cooldown_param)) {
    cooldown_up <- cooldown_param
    cooldown_down <- cooldown_param
  } else if (!is.null(cooldown_param$up) & !is.null(cooldown_param$down)) {
    cooldown_up <- cooldown_param$up
    cooldown_down <- cooldown_param$down
  } else {
    cooldown_up <- 1
    cooldown_down <- 1
  }
  
  cooldown <- data.frame(
    up = cooldown_up,
    down = cooldown_down
  )
  
  return (cooldown)
}
