library(ggplot2)
library(cowplot)
plot_adi <- function(data, policy_parameters, configs) {
  
  data %>% ggplot(aes(x = factor(Policy), y = RealADI)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Real ADI")+
    geom_text(aes(label=round(RealADI,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic()
  
  adi_real_plot_filepath <- paste("./output/", "real_adi.pdf", sep='')
  ggplot2::ggsave(adi_real_plot_filepath, width = 7, height = 4)
  
  data %>% ggplot(aes(x = factor(Policy), y = SimulatedADI)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Simulated ADI")+
    geom_text(aes(label=round(SimulatedADI,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic()
  
  adi_real_plot_filepath <- paste("./output/", "simulated_adi.pdf", sep='')
  ggplot2::ggsave(adi_real_plot_filepath, width = 7, height = 4)
  
  data %>% ggplot(aes(x = factor(Policy), y = ADI_PDIFF)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "ADI PDIFF")+
    geom_text(aes(label=round(ADI_PDIFF,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic()
  
  adi_real_plot_filepath <- paste("./output/", "ADI_PDIFF.pdf", sep='')
  ggplot2::ggsave(adi_real_plot_filepath, width = 7, height = 4)

  data %>% ggplot(aes(x = factor(Policy), y = Jitter)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Jitter")+
    geom_text(aes(label=round(Jitter,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic()
  
  adi_real_plot_filepath <- paste("./output/", "Jitter.pdf", sep='')
  ggplot2::ggsave(adi_real_plot_filepath, width = 7, height = 4)
  
  
  ggplot(metrics, aes(x = factor(Policy), y = Acc_Over_Provisioning)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Acc Over Provisioning")+
    geom_text(aes(label=round(Acc_Over_Provisioning,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic() +
    theme(axis.text = element_text(size = 8))     
  
  ggplot(metrics, aes(x = factor(Policy), y = Acc_Under_Provisioning)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Acc Under Provisioning")+
    geom_text(aes(label=round(Acc_Under_Provisioning,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic() +
    theme(axis.text = element_text(size = 8)) 
  
plot_grid(x, y)
  
  adi_real_plot_filepath <- paste("./output/", "Acc_Over_and_Under_Provisioning.pdf", sep='')
  ggplot2::ggsave(adi_real_plot_filepath, width = 7, height = 4)
  
  ggplot(metrics, aes(x = factor(Policy), y = Timeshare_Over_Provisioning)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Timeshare Over Provisioning")+
    geom_text(aes(label=round(Timeshare_Over_Provisioning,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic() +
    theme(axis.text = element_text(size = 8))     
  
  ggplot(metrics, aes(x = factor(Policy), y = Timeshare_Under_Provisioning)) + 
    geom_bar(stat = "identity", fill="cadetblue") +
    labs(x="Policy", y = "Timeshare Under Provisioning")+
    geom_text(aes(label=round(Acc_Under_Provisioning,2)), vjust=1.6, 
              color="white", size=3.5)+
    theme_classic() +
    theme(axis.text = element_text(size = 8)) 
  
  plot_grid(x, y)
  
  adi_real_plot_filepath <- paste("./output/", "Timeshare_Over_and_Under_Provisioning.pdf", sep='')
  ggplot2::ggsave(adi_real_plot_filepath, width = 7, height = 4)
}
