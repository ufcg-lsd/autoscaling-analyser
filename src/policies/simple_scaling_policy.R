# The reactive static policy reacts to the demand and scales up and down
# based on upper and lower bound parameters. The scale happens at a fixed
# step size.
simple_scaling_policy <- function(system_utilization, policy_parameters, 
                                  time_parameters, ...){
  
  arguments <- list(...)
  evaluation_period <- policy_parameters$evaluation_period
  system_utilization <- get_system_utilization(arguments, evaluation_period)
  step_size <- get_step_size(policy_parameters, arguments$allocated)
  cooldown_countdown <- arguments$cooldown
  
  new_cores <- 0
  if(length(which(system_utilization > policy_parameters$upper_bound)) >= evaluation_period){
    # Increase cores by step size if system utilization is higher than upper bound
    new_cores <- step_size$up
  } else if(length(which(system_utilization < policy_parameters$lower_bound)) >= evaluation_period){
    # Decrease cores by step size if system utilization is lower than upper bound
    new_cores <- step_size$down
  }
  
  if (cooldown_countdown$up != 0 || cooldown_countdown$down != 0)
    new_cores <- 0

  return (new_cores)
}

# Get system utilization from current until up to four previous timestamps
get_system_utilization <- function(arguments, evaluation_period) {
  utilization_history <- unlist(arguments$history)
  current_time <- arguments$current
  start_time <- max(1, current_time - (evaluation_period - 1))
  system_utilization <- utilization_history[start_time:current_time]

  return (system_utilization)
}

# The step size is either the amount of cores or the percentage of cores
get_step_size <- function(policy_parameters, allocated) {
  step_size <- data.frame(
    up = policy_parameters$up_step_size,
    down = policy_parameters$down_step_size * -1
  )

  step_type <- policy_parameters$step_type
  if (step_type == "percentage") {
    step_size$up <- max(floor(step_size$up * allocated), 1)
    step_size$down <- min(ceiling(step_size$down * allocated), -1)
  }

  return (step_size)
}
