library(forecast)

# The target tracking policy works with a scaling metric and only one target value. 
# This policy focus more on delivering application availability than saving costs.
predictive_scaling_policy <- function(system_utilization, policy_parameters, ...) {
  
  # Arguments parameters
  arguments <- list(...)
  allocated <- arguments$allocated
  used_cores <- arguments$data[1:arguments$current,]
  cooldown_countdown <- arguments$cooldown
  
  #Policy parameters
  vm_cores <- policy_parameters$vm_cores
  prediction_frame <- policy_parameters$prediction_frame
  train_file <- bind_rows(policy_parameters$train_file, used_cores) %>% pull(Cores)
  
  horizon <- 12
  start <- length(train_file) - prediction_frame
  end <- length(train_file) - 1
  prediction <- forecast(auto.arima(train_file[start:end]), h=horizon)
  adjustment <- prediction$mean[length(prediction$mean)] - allocated
  new_cores <- ceiling(adjustment / vm_cores) * vm_cores
  
  print(arguments$current)
  
  if (cooldown_countdown$up != 0 || cooldown_countdown$down != 0)
    new_cores <- 0
  
  return (new_cores)
}