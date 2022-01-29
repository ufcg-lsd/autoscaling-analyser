calculate_adi <- function(data, lower_bound, upper_bound){
  
  for(row in 1:nrow(data)) {
    if(data[row,"SystemUtilization"] > upper_bound){
      adi <- data[row,"SystemUtilization"] - upper_bound
      # Take in consideration exceeded cores
      if (data[row, "ExceededCores"] > 0) {
        over_utilization <- data[row, "ExceededCores"] /
                            data[row, "AllocatedCores"] * 100
        data[row, "OverUtilization"] <- over_utilization
      }
      
    }else if(data[row,"SystemUtilization"] < lower_bound){
      adi <- lower_bound - data[row,"SystemUtilization"] 
    
    } else{
      adi <- 0
    }
    
    data[row, "ADI"] <- adi
  }
  
  return(data)
}