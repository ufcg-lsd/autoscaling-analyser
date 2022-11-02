calculate_summation_provisioning <- function(data){
  sum_over_provisioning <- 0
  sum_under_provisioning <- 0
  
  for(row in 1:nrow(data)) {
    sum_over_provisioning <- sum_over_provisioning + data[row, "Over-Provisioning"]
    sum_under_provisioning <- sum_under_provisioning + data[row, "Under-Provisioning"]
  }
  
  output <- list(sum_over_provisioning, sum_under_provisioning)
  
  return(output)
}

accuracy_over_provisioning <- function(data){
  accuracy_over_provisioning <- calculate_summation_provisioning(data)
  acc_over_provisioning <- accuracy_over_provisioning[[1]] / nrow(data)
  
  return(as.numeric(acc_over_provisioning))
}

accuracy_under_provisioning <- function(data){
  accuracy_under_provisioning <- calculate_summation_provisioning(data)
  acc_under_provisioning <- accuracy_under_provisioning[[2]] / nrow(data)
 
   return(as.numeric(acc_under_provisioning))
}