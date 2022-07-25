source(here::here("src/calculate_adi.R"))

calculate_metrics <- function(data_with_auto_scaling, policy_parameters) {
  # TODO calculate metrics based on policy
  data_with_adi <- calculate_adi(data_with_auto_scaling,
                                 policy_parameters[["lower_bound"]],
                                 policy_parameters[["upper_bound"]])
  metrics <- tibble(
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
  )
  
  return (metrics)
}
