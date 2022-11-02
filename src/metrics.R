source(here::here("src/calculate_adi.R"))
source(here::here("src/data_processing/over_and_under_provisioning.R"))
source(here::here("src/metrics/accuracy.R"))
source(here::here("src/metrics/timeshare.R"))
source(here::here("src/metrics/jitter.R"))


calculate_metrics <- function(data_with_auto_scaling, policy_parameters, policy) {
  if(policy == "simple_scaling"){
    # TODO calculate metrics based on policy
    data_with_adi <- calculate_adi(data_with_auto_scaling,
                                   policy_parameters[["lower_bound"]],
                                   policy_parameters[["upper_bound"]])
  }
  else if(policy == "target_tracking"){
   
    data_with_adi <- calculate_adi(data_with_auto_scaling,
                                   policy_parameters[["target_value"]],
                                   (policy_parameters[["target_value"]]*(1-policy_parameters[["scale_in_threshold"]]/100)))
  }
    data_with_adi_and_provisioning <- calculate_over_and_under_provisioning(data_with_adi)

    metrics <- tibble(
      Policy = policy,
      SimulatedADI = sum(data_with_adi["ADI"]),
      RealADI = sum(data_with_adi["RealADI"]),
      ADI_PDIFF = (SimulatedADI/RealADI - 1)*100,
      MAE = mae_vec(
        data_with_adi$RealAllocatedCores,
        data_with_adi$AllocatedCores
      ),
      SMAPE = smape_vec(
        data_with_adi$RealAllocatedCores,
        data_with_adi$AllocatedCores
      ),
      PDIFF = (
        sum(data_with_adi$AllocatedCores) - sum(data_with_adi$RealAllocatedCores)
      ) / sum(data_with_adi$RealAllocatedCores) * 100,
  
      Jitter = calculate_jitter(data_with_adi_and_provisioning),
  
      Acc_Over_Provisioning = accuracy_over_provisioning(data_with_adi_and_provisioning),
  
      Acc_Under_Provisioning = accuracy_under_provisioning(data_with_adi_and_provisioning),
  
      Timeshare_Over_Provisioning = timeshare_over_provisioning(data_with_adi_and_provisioning),
  
      Timeshare_Under_Provisioning = timeshare_under_provisioning(data_with_adi_and_provisioning),
    )
  
    return (metrics)
  }
 




