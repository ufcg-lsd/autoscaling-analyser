# The reactive static policy reacts to the demand and scales up and down
# based on upper and lower bound parameters. The scale happens at a fixed
# step size.
target_tracking_sw <- function(system_utilization, policy_parameters, 
                                  time_parameters, ...){
  
  arguments <- list(...)
  evaluation_period <- 5
  system_utilization <- min(get_system_utilization(arguments, evaluation_period))
  cooldown_countdown <- arguments$cooldown
  allocated <- arguments$allocated
  
  upper_bound <- policy_parameters$target_value * (1 + policy_parameters$scale_threshold/100)
  lower_bound <- policy_parameters$target_value * (1 - policy_parameters$scale_threshold/100)
  
  new_cores <- 0
  if(system_utilization > upper_bound || system_utilization < lower_bound){
    
    vm_cores <- policy_parameters$vm_cores
    target <- policy_parameters$target_value
    
    demand <- system_utilization * allocated
    step_cores <- ((demand/target) - allocated)
    adjustment <- ceiling(step_cores / vm_cores) * vm_cores
    new_cores <- adjustment
    
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
