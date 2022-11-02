calculate_adi <- function(data, lower_bound, upper_bound){
  
  for(row in 1:nrow(data)) {
    if(data[row,"RealSystemUtilization"] > upper_bound){
      adi <- data[row,"RealSystemUtilization"] - upper_bound
      # Take in consideration exceeded cores
      if (data[row, "ExceededCores"] > 0) {
        over_utilization <- data[row, "ExceededCores"] /
          data[row, "RealAllocatedCores"] * 100
        data[row, "OverUtilization"] <- over_utilization
      }
      
    }else if(data[row,"RealSystemUtilization"] < lower_bound){
      adi <- lower_bound - data[row,"RealSystemUtilization"] 
      
    } else{
      adi <- 0
    }
    
    data[row, "ADI"] <- adi
  }
  
  return(data)
}