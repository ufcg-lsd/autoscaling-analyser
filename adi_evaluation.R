# Load packages
library(dplyr)

# Read csv
raw_data <- read.csv("data/util_data.csv")

# Select only the columns timestamp, InstanceType and Average
data <- raw_data[,c("timestamp","InstanceType","Average")]

# Add new column capacity
data <- data %>% 
  dplyr::mutate(Capacity = dplyr::case_when(InstanceType == "t2.medium" ~ 2,
                                              InstanceType == "t2.micro" ~ 1,
                                              InstanceType == "c5.large" ~ 2,
                                              InstanceType == "c5.xlarge" ~ 4,
                                              InstanceType == "m5d.large" ~ 2,
                                              InstanceType == "m5d.xlarge" ~ 4,
                                              InstanceType == "r5.2xlarge" ~ 8,
                                              InstanceType == "t3.micro" ~ 2
  ))

capacidade_extra <- 0
step_size <- 2
upper_bound = 60
lower_bound = 39
previous <- 0

for (i in 1:dim(data)[1]) {
  data[["Capacity"]][i] <- data[["Capacity"]][i-previous] + capacidade_extra
  data[["Utilization"]][i] <- data[["Average"]][i] / data[["Capacity"]][i] * 100
  
  if (data[["Utilization"]][i] > upper_bound) {
    # Utilization level greater than upper bound
    print ("GREATER")
    data[["ADI"]][i] <- data[["Utilization"]][i] - upper_bound
    capacidade_extra <- 2
  
  } else if (data[["Utilization"]][i] < lower_bound) {
    # Utilization level less than lower bound
    print ("LESS")
    data[["ADI"]][i] <- lower_bound - data[["Utilization"]][i]
    
    if (data[["Capacity"]][i] > 2) { # Avoid zero capacity
      capacidade_extra <- -2 
    } else {
      capacidade_extra <- 0
    }

  } else {
    # Utilization level between desired limit
    print ("BETWEEN")
    data[["ADI"]][i] <- 0
    capacidade_extra = 0
  }
  
  if (i == 1) {
    previous <- 1
  }
  
}

# Print sum of all ADIs
sum(data["ADI"])
