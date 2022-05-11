# The target tracking policy works with a scaling metric and only one target value. 
# This policy focus more on delivering application availability than saving costs.
target_tracking_policy <- function(system_utilization, policy_parameters, ...) {

  # Arguments parameters
  arguments <- list(...)
  cooldown_countdown <- arguments$cooldown
  allocated <- arguments$allocated
  last_addition <- arguments$last_addition
    
  # Policy parameters
  target <- policy_parameters$target_value
  lower_threshold <- target - policy_parameters$scale_in_threshold
  vm_cores <- policy_parameters$vm_cores
  
  # Calculate scaling adjustment
  demand <- system_utilization * allocated
  step_cores <- ((demand/ target) - allocated)
  adjustment <- ceiling(step_cores / vm_cores) * vm_cores
  
  new_cores <- 0
  if(system_utilization > target | system_utilization < lower_threshold){
    # Adjust amount of cores if it's outside of boundaries
    new_cores <- adjustment
  }
  
  if (new_cores < 0) {
    if (cooldown_countdown$up != 0 || cooldown_countdown$down != 0)
      new_cores <- 0
  } else if (new_cores > 0) {
    if (cooldown_countdown$down != 0) {
      cooldown_countdown$down <- 0
    } else if (cooldown_countdown$up != 0) {
      if (new_cores > last_addition) {
        new_cores <- new_cores - last_addition
        cooldown_countdown$up <- 0
      } else new_cores <- 0
    }
  }
  
  return (new_cores)
}