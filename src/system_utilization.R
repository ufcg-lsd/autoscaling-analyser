calculate_allocated_cores_and_utilization <- function(df, alocated_cores_initial, lower_bound, upper_bound){
  cores_allocated <- alocated_cores_initial
  
  for(row in 1:nrow(df)) {
    system_utilization <- (df[row,2]/cores_allocated) * 100
    
    df[row, "SystemUtilization"] <- system_utilization
    df[row, "AllocatedCores"] <- cores_allocated
    
    if(system_utilization > upper_bound){
      cores_allocated <- cores_allocated + 2
    }
    else if(system_utilization < lower_bound){
      cores_allocated <- cores_allocated - 2
    }
    else{
      cores_allocated <- cores_allocated
    }
  }
  return(df) 
}

