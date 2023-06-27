library(here)
library(tidyverse)
library(janitor)

ethnic_csv <- here("pipeline", "raw", "sheffield-custom-area-ethnic-group.csv")

ethnic_group <- read_csv(ethnic_csv, skip = 6) |>
  clean_names() |>
  select(-variable)

ckp_data_model <- here("pipeline", "processed", "ckp.RData")

save(ethnic_group, file = ckp_data_model)
