library(here)
library(tidyverse)
library(furrr)

# CREDIT:  Carlos I. Rodriguez
# https://www.carlosivanrodriguez.com/guides/workflow/parameterized-and-parallelized-quarto-reports/

render_reports <- function(community_name){

  # Create new name for Quarto (.qmd) copy
  community_qmd <- here("R", str_c("report-layout-", community_name, ".qmd"))

  # Create copy of the layout file using the modified file name
  file.copy(
    from = here("R", "report-layout.qmd"),
    to = community_qmd,
    overwrite = TRUE
  )

  # Render report (.pdf) using Quarto copy
  # TODO: Use Quarto "projects" to render to a different folder i.e. \output
  # https://quarto.org/docs/projects/quarto-projects.html
  quarto::quarto_render(
    input = community_qmd,
    execute_params = list(community = community_name),
    output_file = str_c("report-for-", community_name, ".pdf")
  )

  # Remove Quarto copy
  file.remove(community_qmd)
}

# Set options and cores for parallel processing
plan(cluster, workers = 3)

# Iterate through our different communities
# TODO: Swap sample Iris dataset and different "species",
#       for our CKP dataset and different "communities"
as.character(unique(iris$Species)) %>%
  future_walk(~ render_reports(.x))
