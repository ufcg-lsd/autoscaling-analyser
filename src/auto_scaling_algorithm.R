
auto_scaling_algorithm <- function(data, initial_allocated_cores,
                                   policy_parameters, application_start_time){
  
  # Initialize global variables
  cores_allocated <- initial_allocated_cores
  
  # Queue to keep track of cooldown and scaling actions
  action_queue <- list()
  
  cooldown <- get_cooldown(policy_parameters$cooldown)
  
  # Countdown is env type because we need to change it's value inside the policy
  cooldown_countdown <- new.env()
  cooldown_countdown$up <- 0
  cooldown_countdown$down <- 0
  
  for(row in 1:nrow(data)) {
    
    # Decremento do cooldown
    
    cooldown_countdown$up <- max(0, cooldown_countdown$up - 1)
    cooldown_countdown$down <- max(0, cooldown_countdown$down - 1)
    
    # Inicializa variáveis locais
    
    current_time <- data[row, "timestamp"]
    
    # Execute queue actions
    action <- action_queue[[as.character(current_time)]]
    if (!is.null(action)) {
    
      cores_allocated <-
        min(max(cores_allocated + action, policy_parameters[["min_cap"]]),
            policy_parameters[["max_cap"]])
      
      if (action < 0) {
        cooldown_countdown$down <- cooldown$down
      } else if (action > 0) { 
        cooldown_countdown$up <- cooldown$up
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
      application_start_time,
      history = data["SystemUtilization"],
      current = row,
      allocated = cores_allocated,
      cooldown = cooldown_countdown,
      last_addition = action_queue[["-1"]]
    )
    
    if (cores < 0) {
      
      adding_time <- current_time + 60
      action_queue[as.character(adding_time)] <- cores
      
    } else if (cores > 0) {
      start_time <- 1 + round(runif(
        1,
        application_start_time$min,
        application_start_time$max
      ))
      
      cooldown_up_start <- current_time + start_time * 60
      action_queue[as.character(cooldown_up_start)] <- cores
      
      action_queue["-1"] <- cores
  
    }
    
    # Update data
    data[row, "AllocatedCores"] <- cores_allocated
    data[row, "ExceededCores"] <- excedded_cores
    data[row, "Decision"] <- cores
    data[row, "Action"] <- ifelse(is.null(action), 0, action)
    data[row, "CooldownUp"] <- cooldown_countdown$up
    data[row, "CooldownDown"] <- cooldown_countdown$down

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
