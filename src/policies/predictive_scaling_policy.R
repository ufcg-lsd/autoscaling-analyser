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
  test_file <- process_util_data(policy_parameters$train_file)
  vm_cores <- policy_parameters$vm_cores
  train_file <- bind_rows(test_file, used_cores) %>% pull(Cores)
  
  horizon <- 12
  prediction_frame <- 21600
  start <- max(1, arguments$current - prediction_frame + 1)
  end <- arguments$current + nrow(test_file)
  prediction <- forecast(auto.arima(train_file[start:end]), h=horizon)
  adjustment <- prediction$mean[length(prediction$mean)] - allocated
  new_cores <- ceiling(adjustment / vm_cores) * vm_cores
  
  if (cooldown_countdown$up != 0 || cooldown_countdown$down != 0)
    new_cores <- 0
  
  return (new_cores)
}