calculate_adi <- function(data, lower_bound, upper_bound){
  
  for(row in 1:nrow(data)) {
    if(data[row,"SystemUtilization"] > upper_bound){
      adi <- data[row,"SystemUtilization"] - upper_bound
      adi_sign <- 1
      # Take in consideration exceeded cores
      if (data[row, "ExceededCores"] > 0) {
        over_utilization <- data[row, "ExceededCores"] /
                            data[row, "AllocatedCores"] * 100
        data[row, "OverUtilization"] <- over_utilization
      }
      
    }else if(data[row,"SystemUtilization"] < lower_bound){
      adi <- lower_bound - data[row,"SystemUtilization"]
      adi_sign <- -1
    
    } else{
      adi <- 0
      adi_sign <- 0
    }
    
    if(data[row,"SystemRealUtilization"] > upper_bound){
      real_adi <- data[row,"SystemRealUtilization"] - upper_bound
      real_adi_sign <- 1
    }else if(data[row,"SystemRealUtilization"] < lower_bound){
      real_adi <- lower_bound - data[row,"SystemRealUtilization"]
      real_adi_sign <- -1
    } else{
      real_adi <- 0
      real_adi_sign <- 0
    }
    
    data[row, "ADI"] <- adi
    data[row, "ADISign"] <- adi_sign
    data[row, "RealADI"] <- real_adi
    data[row, "RealADISign"] <- real_adi_sign
  }
  
  return(data)
}