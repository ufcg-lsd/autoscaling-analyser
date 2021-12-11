library(readr)
library(dplyr)

source(here::here("src/data_processing.R"))

df <- read_csv("data/util_data.csv")

data <- processing_data(df)
