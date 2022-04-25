# The target tracking policy works with a scaling metric and only one target value. 
# This policy focus more on delivering application availability than saving costs.
target_tracking_policy <- function(system_utilization, policy_parameters, ...) {
  
  arguments <- list(...)
  allocated <- arguments$allocated

  target <- policy_parameters$target_value
  lower_threshold <- target - policy_parameters$scale_in_threshold
  vm_cores <- policy_parameters$vm_cores
  adjustment = (arguments$demanded_cores / target - allocated) / vm_cores
  
  new_cores <- 0
  if(system_utilization > target || system_utilization < lower_threshold){
    # Adjust amount of cores if it's outside of boundaries
    new_cores <- ceiling(adjustment)
  }

  return (new_cores)
}