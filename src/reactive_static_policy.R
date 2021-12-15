reactive_static_policy <- function(data, initial_allocated_cores, lower_bound,
                                   upper_bound){
  cores_allocated <- initial_allocated_cores
  
  for(row in 1:nrow(data)) {
    system_utilization <- (data[row,"Cores"]/cores_allocated) * 100
    
    data[row, "SystemUtilization"] <- system_utilization
    data[row, "AllocatedCores"] <- cores_allocated
    
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
  return(data) 
}

