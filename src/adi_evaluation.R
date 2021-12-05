# Load packages
library(dplyr)

# Set working directory to avoid wrong PATHs
setwd("/home/kilian/Computer-Science/PIBIC/autoscaling-analyser")

# Read csv
raw_data <- read.csv("data/util_data.csv")

# Select only the columns: timestamp, InstanceType and Average.
data <- raw_data[,c("timestamp","InstanceType","Average")]

# Add new column instance capacity based on the instance type
data <- data %>% 
  dplyr::mutate(InstanceCapacity = dplyr::case_when(
    InstanceType == "t2.medium" ~ 2,
    InstanceType == "t2.micro" ~ 1,
    InstanceType == "c5.large" ~ 2,
    InstanceType == "c5.xlarge" ~ 4,
    InstanceType == "m5d.large" ~ 2,
    InstanceType == "m5d.xlarge" ~ 4,
    InstanceType == "r5.2xlarge" ~ 8,
    InstanceType == "t3.micro" ~ 2
  ))

# Set test parameters
step_size <- 2
upper_bound <- 60
lower_bound <- 39

# Auxiliary variables
previous <- 0
extra_capacity <- 0
data[["CurrentCapacity"]][1] = data[["InstanceCapacity"]][1]

# Loop thought each line on the data frame
for (i in 1:dim(data)[1]) {
  # Calculate the capacity based on the previous one
  data[["CurrentCapacity"]][i] <- data[["CurrentCapacity"]][i-previous] + extra_capacity
  # Calculate utilization level by percentage
  data[["Utilization"]][i] <- data[["Average"]][i] / data[["CurrentCapacity"]][i] * 100
  
  if (data[["Utilization"]][i] > upper_bound) {
    # Utilization level greater than upper bound
    data[["ADI"]][i] <- data[["Utilization"]][i] - upper_bound
    extra_capacity <- 2
  
  } else if (data[["Utilization"]][i] < lower_bound) {
    # Utilization level less than lower bound
    data[["ADI"]][i] <- lower_bound - data[["Utilization"]][i]
    
    if (data[["CurrentCapacity"]][i] > data[["InstanceCapacity"]][i]) { # Avoid zero capacity
      extra_capacity <- -2 
    } else {
      extra_capacity <- 0
    }

  } else {
    # Utilization level between desired limit
    data[["ADI"]][i] <- 0
    extra_capacity = 0
  }
  
  if (i == 1) {
    previous <- 1
  }
 
}

# Print sum of all ADIs
sum(data["ADI"])
