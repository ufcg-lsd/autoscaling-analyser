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

plot_util <- function(data, policy_parameters, title, date_break, filepath) {
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
    scale_x_datetime(date_breaks = date_break, date_labels = "%H:%M")
  
  if (startsWith(title, "Simple Scaling")) {
    # Draw a line for each threshold
    upper_bound <- policy_parameters$upper_bound
    lower_bound <- policy_parameters$lower_bound
    
    plot <- plot +
      geom_hline(yintercept = upper_bound, color = "red") +
      geom_text(aes(x = min(datetime),y = upper_bound+2, label = "Upper Bound"), size = 2, color = "red") +
      geom_hline(yintercept = lower_bound, color = "blue") +
      geom_text(aes(x = min(datetime), y = lower_bound-2, label = "Lower Bound"), size = 2, color = "blue")

  } else if (startsWith(title, "Target Tracking")) {
    # Draw a line for target threshold
    target <- policy_parameters$target_value
    
    plot <- plot +
      geom_hline(yintercept = target, color = "red") +
      geom_text(aes(x = 120, y = target+2, label = "Target threshold"), size = 3, color = "red")
    
  }
  
  ggplot2::ggsave(filepath, width = 7, height = 4)
}

plot_cores <- function(data, title, date_break, filepath) {
  # Add plot both real and simulation
  data <- data %>%
    rename(simulation = AllocatedCores, real = RealAllocatedCores) %>%
    pivot_longer(c(simulation, real))
  
  # Plot allocated cores over the time for both real and simulation
  data %>% ggplot(aes(x = datetime, y = value, color = name)) +
    ggtitle(title) +
    geom_line() +
    theme_minimal() +
    labs(y = "Cores", x = "Time (hour)", color = "") +
    theme(legend.position = "top", legend.direction = "horizontal") +
    scale_x_datetime(date_breaks = date_break, date_labels = "%H:%M")
  
  ggplot2::ggsave(filepath, width = 7, height = 4)
}

plot_simulation <- function(data, policy_parameters, configs) {
  # Creates two plots for cores and system utilization over time comparing
  # real and simulation results.
  title <- get_title(data, configs$policies$use)
  date_break <- get_plot_date_break(configs)

  # Add datetime column to make the plot more readable in time perspective
  data <- data %>% mutate(datetime = as.POSIXct(timestamp, origin="1970-01-01"))

  plot_util(data, policy_parameters, title, date_break, configs$utilization_filepath)
  plot_cores(data, title, date_break, configs$cores_filepath)
}

get_plot_date_break <- function(configs) {
  if (is.null(configs$plot_scale_datetime)) {
    date_break <- "1 hour"
  } else {
    date_break <- configs$plot_scale_datetime
  }
  
  return (date_break)
}
