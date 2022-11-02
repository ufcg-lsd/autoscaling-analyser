# Calculates the amount of under and over provisioned resources
calculate_over_and_under_provisioning <- function(data){
  for(row in 1:nrow(data)) {
    # Calculate the amount of missing resources in relation to demand
    data[row, "Under-Provisioning"] <- max(data[row,"Cores"] - data[row,"RealAllocatedCores"], 0)/data[row,"Cores"]
    
    #Calculate the amount of surplus resources in relation to demand
    data[row, "Over-Provisioning"] <- max(data[row,"RealAllocatedCores"] - data[row,"Cores"], 0)/data[row,"Cores"]
  }
  return(data)
}