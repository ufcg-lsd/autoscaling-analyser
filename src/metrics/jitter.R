calculate_jitter <- function(data){
  demand_curve_adaptations  <- 0
  supply_curve_adaptations <- 0
  
  if(nrow(data) > 1){  
    for(row in 2:nrow(data)) {
      demand_curve_adaptations <- abs(data[row, "Cores"] - data[row - 1, "Cores"])
      supply_curve_adaptations <- abs(data[row, "AllocatedCores"] - data[row - 1, "AllocatedCores"])
    }
    jitter <- (supply_curve_adaptations - demand_curve_adaptations) / nrow(data) 
  }else{
    jitter <- 0
  }

  return(as.numeric(jitter))
}