split_data_by_application_azure <- function(data){
  print("Iniciou o split")
  folder_azure <- configs$azure_data$folder_data
  
  for(row in 1:nrow(data)) {
    ifelse(!dir.exists(file.path(folder_azure, "/app")), dir.create(file.path(folder_azure, "/app")), FALSE)
    filename = gsub('/| |+', '', paste((data[[row, "deployment_id"]]), ".csv"))
    #ifelse(!file.exists(paste("data/azure/app/", filename)), file.create(paste("data/azure/app/", filename)), FALSE)
    row_to_add <- data.frame(data[[row, "timestamp"]], data[[row, "deployment_id"]], data[[row, "Cores"]], data[[row, "CoresMax"]], data[[row, "RealAllocatedCores"]], data[[row, "RealSystemUtilization"]])
    colnames(row_to_add) <- c("timestamp", "deployment_id", "Cores", "CoresMax", "RealAllocatedCores", "RealSystemUtilization")
    if(gsub('.{4}$', '', filename) == gsub('/| |+', '', data[[row, "deployment_id"]])){
      print(paste(folder_azure, "/app/", filename, sep=""))
      write.table(row_to_add, file = paste(folder_azure, "/app/", filename, sep=""), sep = ",",
                  append = TRUE, quote = FALSE,
                  col.names = !file.exists(paste(folder_azure, "/app/", filename, sep="")), row.names = FALSE)
    gc()
    }
  }
}