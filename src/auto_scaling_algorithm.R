
auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters, time_parameters){
  cores_allocated <- initial_allocated_cores
  
  cooldown <- get_cooldown(policy_parameters)
  
  # Cooldown counters
  cooldown_start <- c(-1, -1)
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
    if (cooldown_start[[1]] == current_time) {
      cooldown_countdown$up <- cooldown$up
      cooldown_start[[1]] <- -1
    }
    
    # Scale down countdown reset
    if (cooldown_start[[2]] == current_time) {
      cooldown_countdown$down <- cooldown$down
      cooldown_start[[2]] <- -1
    }
    
    scale_type <- get_scale_type(cooldown_countdown)
    
    if (scale_type != "none") {

      # Scale operation based on policy 
      cores <- policy_parameters$func(
        system_utilization,
        policy_parameters,
        scale_type,
        history = data["SystemUtilization"],
        current = row,
        allocated = cores_allocated
      )
      
      if (cores < 0) {
        new_cores <- new_cores + cores
        
        # If cores are to be removed, they will be removed immediately.
        # Minimum allocated cores is the min_cap, and maximum is max_cap
        cores_allocated <- 
          min(
            max(cores_allocated + cores, policy_parameters[["min_cap"]]),
            policy_parameters[["max_cap"]]
          )
        
        # The cooldown period will start just after the removal.
        cooldown_countdown[[scale_type]] <- time_parameters$cooldown
  
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
        adding_time <- c(adding_time, cooldown_start + warmup_time * 60)
        adding_cores <- c(adding_cores, cores)
      }
      
    }
    
    cooldown_countdown[[1]] <- max(0, cooldown_countdown[[1]] - 1)
    cooldown_countdown[[2]] <- max(0, cooldown_countdown[[2]] - 1)

    data[row, "NewCores"] <- new_cores
  }
  
  return(data)
}

get_scale_type <- function(cooldown_countdown) {
  cooldown_up_triggered <- cooldown_countdown[[1]] == 0
  cooldown_down_triggered <- cooldown_countdown[[2]] == 0
  
  if (cooldown_up_triggered) {
    scale_type <- "up"
  } else if (cooldown_down_triggered) {
    scale_type <- "down"
  } else {
    scale_type <- "none"
  }
  
  return (scale_type)
}

get_cooldown <- function(cooldown_param) {
  # TODO Do we need a default cooldown?
  if (is.atomic(cooldown_param)) {
    cooldown_up <- cooldown_param
    cooldown_down <- cooldown_param
  } else if (!is.null(cooldown_param$up) & !is.null(cooldown_param$down)) {
    cooldown_up <- cooldown_param$up
    cooldown_down <- cooldown_param$down
  }
  
  cooldown <- data.frame(
    up = cooldown_up,
    down = cooldown_down
  )
  
  return (cooldown)
}

