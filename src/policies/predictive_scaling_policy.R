library(forecast)

# The target tracking policy works with a scaling metric and only one target value. 
# This policy focus more on delivering application availability than saving costs.
predictive_scaling_policy <- function(system_utilization, policy_parameters, ...) {
  
  # Arguments parameters
  arguments <- list(...)
  allocated <- arguments$allocated
  used_cores <- arguments$used_cores
  cores <- arguments$cores
  
  horizon = 12
  prediction = forecast(auto.arima(data[start:end, 2]), h=horizon)
  new_cores <- 0
  # if(system_utilization > target | system_utilization < lower_threshold){
  #   # Adjust amount of cores if it's outside of boundaries
  #   new_cores <- adjustment
  # }
  # 
  # if (new_cores < 0) {
  #   if (cooldown_countdown$up != 0 || cooldown_countdown$down != 0)
  #     new_cores <- 0
  # } else if (new_cores > 0) {
  #   if (cooldown_countdown$down != 0) {
  #     cooldown_countdown$down <- 0
  #   } else if (cooldown_countdown$up != 0) {
  #     if (new_cores > last_addition) {
  #       new_cores <- new_cores - last_addition
  #       cooldown_countdown$up <- 0
  #     } else new_cores <- 0
  #   }
  # }
  
  return (new_cores)
}