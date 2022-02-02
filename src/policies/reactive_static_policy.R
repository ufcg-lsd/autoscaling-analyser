# The reactive static policy reacts to the demand and scales up and down
# based on upper and lower bound parameters. The scale happens at a fixed
# step size.
reactive_static_policy <- function(system_utilization, upper_bound, lower_bound,
                                   step_size){
  new_cores <- 0
  if(system_utilization > upper_bound){
    # Increase cores by step size if system utilization is higher than upper bound
    new_cores <- step_size
  } else if(system_utilization < lower_bound){
    # Decrease cores by step size if system utilization is lower than upper bound
    new_cores <- step_size * -1
  }
  
  return (new_cores)
}