# The target tracking policy works with a scaling metric and only one target value. 
# This policy focus more on delivering application availability than saving costs.
target_tracking_policy <- function(system_utilization, policy_parameters, ...) {

  # Arguments parameters
  arguments <- list(...)
  allocated <- arguments$allocated
    
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
  
  return (new_cores)
}