# os dados de utilização passados por ítallo
# lower bound
# upper bound
data <- read_csv("data/utilizacao-gateway.csv")

calculate_adi_marcella <- function(data, lower_bound, upper_bound){
  
  for(row in 1:nrow(data)) {
    if(data[row,"SystemUtilization"] > upper_bound){
      adi <- data[row,"SystemUtilization"] - upper_bound

    }else if(data[row,"SystemUtilization"] < lower_bound){
      adi <- data[row,"SystemUtilization"] - lower_bound
      
    } else{
      adi <- 0
    }
    
    data[row, "ADI"] <- adi
  }
  
  return(data)
}
