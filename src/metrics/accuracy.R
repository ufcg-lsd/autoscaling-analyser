calculate_acc <- function(data){
  sum_over_provisioning <- 0
  sum_under_provisioning <- 0
  
  for(row in 1:nrow(data)) {
    sum_over_provisioning <- sum_over_provisioning + data[row, "Over-Provisioning"]
    sum_under_provisioning <- sum_under_provisioning + data[row, "Under-Provisioning"]
  }
  
  accuracy_over_provisioning <- sum_over_provisioning / nrow(data)
  accuracy_under_provisioning <- sum_under_provisioning  / nrow(data)
  
  output <- list(accuracy_over_provisioning, accuracy_under_provisioning)
  
  return(output)
}