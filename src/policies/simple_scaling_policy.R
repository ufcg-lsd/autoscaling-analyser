# The reactive static policy reacts to the demand and scales up and down
# based on upper and lower bound parameters. The scale happens at a fixed
# step size.
simple_scaling_policy <- function(system_utilization, policy_parameters, 
                                  time_parameters, ...){
  
  arguments <- list(...)
  system_utilization <- unlist(arguments$history)
  current <- arguments$current
  cooldown_countdown <- arguments$cooldown
  
  start_time <- max(1, current-4)
  system_utilization <- system_utilization[start_time:current]
  
  new_cores <- 0
  if(length(which(system_utilization > policy_parameters$upper_bound)) >= policy_parameters$evaluation_period){
    # Increase cores by step size if system utilization is higher than upper bound
    new_cores <- policy_parameters$up_step_size
  } else if(length(which(system_utilization < policy_parameters$lower_bound)) >= policy_parameters$evaluation_period){
    # Decrease cores by step size if system utilization is lower than upper bound
    new_cores <- policy_parameters$down_step_size * -1
  }
  
  if (cooldown_countdown$up != 0 || cooldown_countdown$down != 0)
    new_cores <- 0
  
  return (new_cores)
}