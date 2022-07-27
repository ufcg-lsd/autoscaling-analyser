library(ggplot2)
library(tidyr)
library(stringr)
library(lubridate)

get_title <- function(data, policy_name) {
  version <- data$Version[1]
  date <- as.Date(data$date[1]) %>% str_replace_all("-", "/")
  pretty_policy_name <- str_replace(policy_name, "_", " ") %>% str_to_title()
  title <- paste(pretty_policy_name, "simulation from version", version,  "at", date)
}

plot_util <- function(data, policy_parameters, policy_name, filepath) {
  title <- get_title(data, policy_name)
  
  # Rename plot legend
  data <- data %>%
    rename(simulation = SystemUtilization, real = RealSystemUtilization) %>%
    pivot_longer(c(simulation, real))

  # Creating plot
  plot <- data %>% ggplot(
    aes(x = datetime, y = value, color = name)) +
    ggtitle(title) +
    geom_line() +
    theme_minimal() +
    labs(y = "CPUtilization (%)", x = "Time (hour)", color = "") +
    theme(legend.position = "top", legend.direction = "horizontal") +
    scale_x_datetime(date_breaks = "30 min", date_labels = "%H:%M")
  
  if (policy_name == "simple_scaling") {
    # Draw a line for each threshold
    upper_bound <- policy_parameters$upper_bound
    lower_bound <- policy_parameters$lower_bound
    
    plot <- plot +
      geom_hline(yintercept = upper_bound, color = "red") +
      geom_text(aes(x = min(datetime),y = upper_bound+2, label = "Upper Bound"), size = 2, color = "red") +
      geom_hline(yintercept = lower_bound, color = "blue") +
      geom_text(aes(x = min(datetime), y = lower_bound-2, label = "Lower Bound"), size = 2, color = "blue")

  } else if (policy_name == "target_tracking") {
    # Draw a line for target threshold
    target <- policy_parameters$target_value
    
    plot <- plot +
      geom_hline(yintercept = target, color = "red") +
      geom_text(aes(x = 120, y = target+2, label = "Target threshold"), size = 3, color = "red")
    
  }
  
  ggplot2::ggsave(filepath, width = 7, height = 4)
}

plot_cores <- function(data, filepath) {
  # Plot allocated cores over the time for both real and simulation
  data %>% ggplot(aes(x = datetime, y = AllocatedCores)) +
    geom_line() +
    theme_minimal() +
    labs(y = "Cores", x = "Tempo (min)") + 
    scale_x_datetime(date_breaks = "30 min", date_labels = "%H:%M")

  ggplot2::ggsave(filepath, width = 7, height = 4)
}

plot_simulation <- function(data, policy_parameters, configs) {
  policy_name = configs$policies$use
  utilization_plot_filepath <- configs$plot_utilization_output_file
  cores_plot_filepath <- configs$plot_cores_output_file
  
  # Add datetime column to make the plot more readable in time perspective
  data <- data %>% mutate(datetime = as.POSIXct(timestamp, origin="1970-01-01"))

  plot_util(data, policy_parameters, policy_name, utilization_plot_filepath)
  plot_cores(data, cores_plot_filepath)
}
