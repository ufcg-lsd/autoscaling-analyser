library(ggplot2)
library(tidyr)
library(stringr)

get_title <- function(data, policy_name) {
  version <- data$Version[1]
  date <- as.Date(data$date[1]) %>% str_replace_all("-", "/")
  pretty_policy_name <- str_replace(policy_name, "_", " ") %>% str_to_title()
  title <- paste(pretty_policy_name, "simulation from version", version,  "at", date)
}

plot_util <- function(data, policy_parameters, policy_name, filepath) {
  title <- get_title(data, policy_name)
  
  data <- data %>%
    rename(simulation = SystemUtilization, real = RealSystemUtilization) %>%
    pivot_longer(c(simulation, real))
  
  plot <- data %>% ggplot(
    aes(x = timestamp - min(timestamp), y = value, color = name)) +
    ggtitle(title) +
    geom_line() +
    theme_minimal() +
    labs(y = "CPUtilization (%)", x = "Time (min)", color = "") +
    theme(legend.position = "top", legend.direction = "horizontal")
  
  if (policy_name == "simple_scaling") {
    upper_bound <- policy_parameters$upper_bound
    lower_bound <-policy_parameters$lower_bound
    
    plot <- plot +
      geom_hline(yintercept = upper_bound, color = "red") +
      geom_text(aes(x = length(timestamp) %/% 2,y = upper_bound+2, label = "Upper Bound"), size = 2, color = "red") +
      geom_hline(yintercept = lower_bound, color = "blue") +
      geom_text(aes(x = length(timestamp) %/% 2, y = lower_bound-2, label = "Lower Bound"), size = 2, color = "blue")
    
  } else if (policy_name == "target_tracking") {
    target <- policy_parameters$target_value
    
    plot <- plot +
      geom_hline(yintercept = target, color = "red") +
      geom_text(aes(x = 120, y = target+2, label = "Target threshold"), size = 3, color = "red")
    
  }
  
  ggplot2::ggsave(filepath, width = 7, height = 4)
}

plot_simulation <- function(data, policy_parameters, configs) {
  policy_name = configs$policies$use
  utilization_plot_filepath <- configs$plot_utilization_output_file
  cores_plot_filepath <- configs$plot_cores_output_file

  plot_util(data, policy_parameters, policy_name, utilization_plot_filepath)
  
  # TODO plot cores
  # data %>% ggplot(aes(x = timestamp - min(timestamp), y = AllocatedCores)) +
  #   geom_line() +
  #   theme_minimal() +
  #   labs(y = "Cores", x = "Tempo (min)")
  # 
  # ggplot2::ggsave(cores_plot_filepath, width = 7, height = 4)
}

plot_real <- function(data, upper_bound, lower_bound) {
  version <- 55
  day <- 15
  title <- paste("Version", version, "from", day)

  # utilization_plot <- data %>% ggplot(
  #   aes(x = timestamp - min(timestamp), y = RealSystemUtilization)) +
  #   ggtitle(title) +
  #   geom_line() +
  #   theme_minimal() +
  #   labs(y = "CPUtilization (%)", x = "Time (min)") +
  #   geom_hline(yintercept = upper_bound, color = "red") +
  #   geom_text(aes(x = 80, y = upper_bound+2, label = "Upper Bound"), size = 2, color = "red") +
  #   geom_hline(yintercept = lower_bound, color = "blue") +
  #   geom_text(aes(x = 80, y = lower_bound-2, label = "Lower Bound"), size = 2, color = "blue")
  # 
  # plot_filepath <- paste("output/experiments/utilization/", version, "_", day, ".pdf", sep='')
  # ggplot2::ggsave(plot_filepath, width = 7, height = 4)

  cores_plot <- data %>% ggplot(
    aes(x = timestamp - min(timestamp) , y = RealAllocatedCores)) +
    ggtitle(title) +
    geom_line() +
    theme_minimal() +
    labs(x = "Time (min)", y = "Cores")

  plot_filepath <- paste("output/experiments/cores/", version, "_", day, ".pdf", sep='')
  ggplot2::ggsave(plot_filepath, width = 7, height = 4)

}
