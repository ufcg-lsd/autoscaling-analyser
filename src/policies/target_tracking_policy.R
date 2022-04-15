# The target tracking policy works with a scaling metric and only one target value. 
# This policy focus more on delivering application availability than saving costs.
target_tracking_policy <- function(system_utilization, policy_parameters, ...) {
  
  arguments <- list(...)
  allocated <- arguments$allocated
  
  target_value <- policy_parameters$target_value
  lower_threshold <- target_value - policy_parameters$scale_in_threshold
  
  # Dynamic step size
  step_size <- round(system_utilization / target_value * allocated)
  
  new_cores <- 0
  if(system_utilization > target_value){
    # Scale out: increase system capacity
    new_cores <- step_size
  } else if(system_utilization < lower_threshold){
    # Scale in: decrease system capacity
    new_cores <- step_size * -1
  }
  
  return (new_cores)
}