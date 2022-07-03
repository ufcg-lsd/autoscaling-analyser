library(tidyverse)

plot_simulation <- function(data, policy_parameters, configs) {
  utilization_plot_filepath <- configs$utilization_plot_file
  cores_plot_filepath <- configs$cores_plot_file

  if (configs$policies$use == "simple_scaling") {
    upper_bound <- policy_parameters$upper_bound
    lower_bound <-policy_parameters$lower_bound
    
    data %>% ggplot2::ggplot(aes(x = timestamp - min(timestamp), y = SystemUtilization)) +
      geom_line() +
      theme_minimal() +
      labs(y = "CPUtilization (%)", x = "Time (s)") +
      geom_hline(yintercept = upper_bound, color = "red") +
      geom_text(aes(x = 70, y = upper_bound+2, label = "Upper Bound"), size = 3, color = "red") +
      geom_hline(yintercept = lower_bound, color = "blue") +
      geom_text(aes(x = 70, y = lower_bound-2, label = "Lower Bound"), size = 3, color = "blue")
  
  } else if (configs$policies$use == "target_tracking") {
    target <- policy_parameters$target_value
    
    data %>% ggplot2::ggplot(aes(x = timestamp - min(timestamp), y = SystemUtilization)) +
      geom_line() +
      theme_minimal() +
      labs(y = "CPUtilization (%)", x = "Time (s)") +
      geom_hline(yintercept = target, color = "red") +
      geom_text(aes(x = 120, y = target+2, label = "Target threshold"), size = 3, color = "red")
  
  }

  ggplot2::ggsave(utilization_plot_filepath, width = 7, height = 4)
  
  data %>% ggplot2::ggplot(aes(x = timestamp - min(timestamp), y = AllocatedCores)) +
    geom_line() +
    theme_minimal() +
    labs(y = "Cores", x = "Tempo (s)")
  
  ggplot2::ggsave(cores_plot_filepath, width = 7, height = 4)
  
}
