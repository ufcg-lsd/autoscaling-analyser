calculate_exceeded_cores <- function(data){
  for(row in 1:nrow(data)) {
    if (data[row, "RealSystemUtilization"] == 100) {
      data[row, "ExceededCores"] <- data[row,"Cores"] - data[row,"RealAllocatedCores"]
    } else {
      data[row, "ExceededCores"] <- 0 
    }
  }
  return(data)
}
