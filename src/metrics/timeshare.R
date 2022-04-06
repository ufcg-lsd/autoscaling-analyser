calculate_timeshare <- function(data){
  sum_time_over_provisioning <- 0
  sum_time_under_provisioning <- 0
  
  for(row in 1:nrow(data)) {
    if(data[row, "Over-Provisioning"] > 0){
      sum_time_over_provisioning <- sum_time_over_provisioning + 1
    }else if(data[row, "Under-Provisioning"] > 0){
      sum_time_under_provisioning <- sum_time_under_provisioning + 1
    }
  }
  
  timeshare_over_provisioning <- sum_time_over_provisioning * 100 / nrow(data)
  timeshare_under_provisioning <- sum_time_under_provisioning * 100 / nrow(data)
  
  output <- list(timeshare_over_provisioning, timeshare_under_provisioning)
  
  return(output)
}