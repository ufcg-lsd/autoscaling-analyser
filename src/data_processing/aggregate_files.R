library(sjmisc)

# Aggregates files related to VM usage
aggregate_data_azure <- function(){
  vector_vm_ids = c("gVb4X4iS13nJrM0KZsy7SrHzWAHix0CEPlK7/deV5vkwjt03xw5+QRtEJ9c8lHcD", "wmva0HFczHYpbUFnj91lLAx8wJ5pJQ3KSYYn+1dVCwAlCeLptXKYbw+Jcm+UFn0J",
          "lAT3Guc/DEmbl9GSA2JhbS83tdhA7xLeSqahlwQ+hG8xD1DMA/imYlE3XYIi96Gb", "hNv0tXIYs+hDNKwjvE/04oRDSIEcl54FaiUAZ6NlO0cCiovRIiZLzQ8XllDLb2CU",
          "9+UA3TLCKTGJ3Vtv1Y1iFOy0xG7HYoa5kol6WzXs8PgvkvmiYMZqIjV6fgjMQVJ9", "cSBxPHB4CdQFAXRnSCWAAihVvm/kJqU0yh+VmMJuYYwQVjr/iBemOB0o/ehvP7lZ",
          "wcEn5gUoyyP5gjDSNzRP+GFjIf3W4G5WkgXB23g22EZETicebUq42VqdiIEaGUgj", "FnubmS4VFzNpcHamirGrOOfE7cOOPZhgQKc9GMnuNkW449Kk+iS6ys1cZtM/kzxW",
          "Cf2TDfirlK8FJtaANTPBP5gc143YRjxHddA0Xec/DKwoUQr7cswJ/yLQ36YatMWy", "A9+GvnL/eTtEGH4yipw7E4Dm8Lp/6U+fO4TnKImA3z/4A0rRUvV7y2BIRCOLE8xT")
  
  folder_azure <- configs$azure_data$folder_data
  files_workload <- list.files(path=folder_azure, pattern="*.csv", full.names=TRUE, recursive=FALSE)
  for (file in files_workload){
    if(str_contains(file, "vm_cpu_readings-file")){
      print(file)
      csv_to_add <- read.csv(file)
      colnames(csv_to_add) <- c("timestamp", "vm_id", "min_cpu", "max_cpu", "avg_cpu")
      csv_to_add <- filter(csv_to_add, vm_id %in% vector_vm_ids)
      write.table(csv_to_add, file = paste(folder_azure, "/aggregate.csv", sep=""), sep = ",",
                  append = TRUE, quote = FALSE,
                  col.names = !file.exists(paste(folder_azure, "/aggregate.csv", sep="")), row.names = FALSE)
      rm(file)
      gc()
    }
  }
}
