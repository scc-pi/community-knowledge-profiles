library(onsr)
library(tidyverse)
library(janitor)

la_code <- "E08000019"
la_name <- "Sheffield"

ons_datasets <- ons_datasets()
ons_ids <- ons_ids()|>
  as_tibble()

sexual_orientation_id <- "TS079"
sexual_orientation_href <- ons_latest_href(id = sexual_orientation_id)
sexual_orientation_version <- ons_latest_version(id = sexual_orientation_id)
sexual_orientation_edition <- ons_latest_edition(id = sexual_orientation_id)

sexual_orientation <- ons_get(id = sexual_orientation_id) |>
  filter(`Lower tier local authorities` == la_name) |>
  clean_names() |>
  select(-starts_with("lower"))
