library(onsr)
library(tidyverse)
library(janitor)
library(here)

la_code <- "E08000019"
la_name <- "Sheffield"

ons_datasets <- ons_datasets() |>
  select(id, description)

get_data <- function(dataset_id, la_name = "Sheffield") {
  df <- ons_get(id = dataset_id) |>
    clean_names() |>
    filter(lower_tier_local_authorities == la_name) |>
    select(-starts_with("lower")) |>
    rename_with(~ return("code"), ends_with("_code")) |>
    rename_with(~ return("category"), ends_with("_categories")) |>
    filter(category != "Does not apply")
}

sexual_orientation <- get_data("TS079")
gender_identity <- get_data("TS078")
multi_religion <- get_data("TS075")
veteran <- get_data("TS074")
armed_forces <- get_data("TS073")

community <- tibble::tribble(
  ~community_name,      ~community_code,
  "Sexual orientation", "sexual_orientation",
  "Gender identity",    "gender_identity",
  "Muti-religion",      "multi_religion",
  "Veteran",            "veteran",
  "Armed forces",       "armed_forces"
)

ons_data <- here("pipeline", "processed", "ons.RData")

save(
  community,
  sexual_orientation,
  gender_identity,
  multi_religion,
  veteran,
  armed_forces,
  file = ons_data
)
