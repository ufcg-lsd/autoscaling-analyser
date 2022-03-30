split_data_by_application_azure <- function(data){
  for(row in 1:nrow(data)) {
    
    ifelse(!dir.exists(file.path("data/azure", "app")), dir.create(file.path('data/azure', "app")), FALSE)
    filename = gsub('/| |+', '', paste((data[[row, "deployment_id"]]), ".csv"))
    #ifelse(!file.exists(paste("data/azure/app/", filename)), file.create(paste("data/azure/app/", filename)), FALSE)
    
    row_to_add <- data.frame(data[[row, "timestamp"]], data[[row, "deployment_id"]], data[[row, "Cores"]])
    colnames(row_to_add) <- c("timestamp", "deployment_id", "Cores")
    
    if(gsub('.{4}$', '', filename) == gsub('/| |+', '', data[[row, "deployment_id"]])){
      write.table(row_to_add, file = paste("data/azure/app/", filename), sep = ",",
                  append = TRUE, quote = FALSE,
                  col.names = !file.exists(paste("data/azure/app/", filename)), row.names = FALSE)
    }
  }
}