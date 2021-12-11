calculate_adi <- function(df, lower_bound, upper_bound){
  
  for(row in 1:nrow(df)) {
    if(df[row,3] > upper_bound){
      adi <- df[row,3] - upper_bound
    }
    else if(df[row,3] < lower_bound){
      adi <- lower_bound - df[row,3] 
    }
    else{
      adi <- 0
    }
    df[row, "ADI"] <- adi
  }
  return(df)
}