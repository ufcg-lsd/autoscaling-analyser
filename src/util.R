# Library to implement utility functions

generate_output_filepaths <- function(configs) {
  # Generate output base filepath
  output_basename <- str_split(basename(configs$input_file), '[.]')[[1]][1]
  output_base_filepath <- paste(configs$output_directory, output_basename, sep='')
  
  # Generate each specific filpath
  configs["policy_filepath"] <- paste(output_base_filepath, "_policy.csv", sep='')
  configs["metrics_filepath"] <- paste(output_base_filepath, '_metrics.csv', sep='')
  configs["cores_filepath"] <- paste(output_base_filepath, "_cores.pdf", sep='')
  configs["utilization_filepath"] <- paste(output_base_filepath, "_utilization.pdf", sep='')
  
  return (configs)
}
