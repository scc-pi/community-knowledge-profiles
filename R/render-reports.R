library(here)
library(tidyverse)
library(furrr)

# CREDIT:  Carlos I. Rodriguez
# https://www.carlosivanrodriguez.com/guides/workflow/parameterized-and-parallelized-quarto-reports/

render_report <- function(community_name){

  # Create new name for Quarto (.qmd) copy
  community_qmd <- here("R", str_c("report-layout-", community_name, ".qmd"))

  # Create copy of the layout file using the modified file name
  file.copy(
    from = here("R", "report-layout.qmd"),
    to = community_qmd,
    overwrite = TRUE
  )

  # Change working directory to "/output" so the PDF lands there
  setwd(here("output"))

  # Render report (.pdf) using Quarto copy
  quarto::quarto_render(
    input = community_qmd,
    execute_params = list(community = community_name),
    output_file = str_c("report_for_", community_name, ".pdf")
  )

  # Reset working directory
  setwd(here())

  # Remove Quarto copy
  file.remove(community_qmd)
}

# Load ONS data frames
load(here("pipeline", "processed", "ons.RData"))

# Set options and cores for parallel processing
plan(cluster, workers = 3)

# Iterate through our different communities
as.character(unique(community$community_code)) |>
  future_walk(~ render_report(.x))
