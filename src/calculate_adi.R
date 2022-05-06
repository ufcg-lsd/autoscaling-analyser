calculate_row_adi <- function(util, L, U){
  
  if(util > U) {
    return(util - U)
  } else if (util < L) {
    return(util - L)
  } else {
    return(0)
  }
}

calculate_adi <- function(data, lower_bound, upper_bound){

  # calculating ADI
  data$ADI = data$SystemUtilization %>% map_dbl(calculate_row_adi, L=lower_bound, U=upper_bound)
  data$RealADI = data$SystemRealUtilization %>% map_dbl(calculate_row_adi, L=lower_bound, U=upper_bound)
  
  # calculating ADI sign
  data <- data %>%
    mutate(ADISign = ADI / abs(ADI),
           RealADISign = RealADI / abs(RealADI)) %>%
    mutate(ADI = abs(ADI),
           RealADI = abs(RealADI))

  # calculating overutilization
  data <- data %>% 
    mutate(OverUtilization = ifelse(ExceededCores > 0, 
                                    ExceededCores / AllocatedCores * 100,0)
           )
  return(data)
}