
auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters, time_parameters){
  
  # Initialize global variables
  cores_allocated <- initial_allocated_cores
  warm_up <- time_parameters$warm_up
  
  # Queue to keep track of cooldown and scaling actions
  action_queue <- list()
  
  cooldown <- get_cooldown(policy_parameters$cooldown)
  # Countdown is env type because we need to change it's value inside the policy
  cooldown_countdown <- new.env()
  cooldown_countdown$up <- 0
  cooldown_countdown$down <- 0
  
  for(row in 1:nrow(data)) {
    
    # Initialize local variables
    current_time <- data[row, "timestamp"]
    new_cores <- 0
    
    # Execute queue actions
    action <- action_queue[[as.character(current_time)]]
    if (!is.null(action)) {
      
      if (action == 'cup') {
        cooldown_countdown$up <- cooldown$up
      } else { # Aqui tem um problema se warm-up = 0
        new_cores <- new_cores + action
        
        cores_allocated <-
          min(max(cores_allocated + action, policy_parameters[["min_cap"]]),
              policy_parameters[["max_cap"]])
      }
      
    }
    
    # Calculate utilization
    system_utilization <- min((data[row, "Cores"] / cores_allocated) * 100, 100)
    data[row, "SystemUtilization"] <- system_utilization
    
    excedded_cores <- ifelse(
      system_utilization == 100, 
      data[row, "Cores"] - cores_allocated, 
      0)
    
    # Call auto-scaling policy (including cooldown verification))
    cores <- policy_parameters$func(
      system_utilization,
      policy_parameters,
      time_parameters,
      history = data["SystemUtilization"],
      current = row,
      allocated = cores_allocated,
      cooldown = cooldown_countdown,
      last_addition = action_queue[["-1"]]
    )
    
    if (cores < 0) {
      
      new_cores <- new_cores + cores
      # If cores are to be removed, they will be removed immediately.
      # Minimum allocated cores is the min_cap, and maximum is max_cap
      cores_allocated <-
        min(max(cores_allocated + cores, policy_parameters[["min_cap"]]),
            policy_parameters[["max_cap"]])
      
      cooldown_countdown$down <- cooldown$down

    } else if (cores > 0) {
        # If cores are to be added they will have to wait for the warm-up.
        boot <- get_random_time(warm_up$boot) * 60
        startup <- get_random_time(warm_up$startup) * 60
        
        # the cooldown period will start only after the boot time.
        cooldown_up_start <- current_time + boot 
        action_queue[as.character(cooldown_up_start)] <- "cup"
        
        # Timestamp to add cores
        adding_time <- cooldown_up_start + startup
        
        # Add to queue the amount of cores to add at that timestamp
        action_queue[as.character(adding_time)] <- cores
        action_queue["-1"] <- cores
    }
    
    # Update data
    data[row, "AllocatedCores"] <- cores_allocated
    data[row, "ExceededCores"] <- excedded_cores
    data[row, "NewCores"] <- new_cores
    
    # Cooldown decrement
    cooldown_countdown$up <- max(0, cooldown_countdown$up - 1)
    cooldown_countdown$down <- max(0, cooldown_countdown$down - 1)
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

get_random_time <- function(time_parameter) {
  random_time <- round(runif(
    1,
    time_parameter$min,
    time_parameter$max
  ))

  return (random_time)
}
