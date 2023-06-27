library(tidyverse)
library(httr2)
library(glue)

# TODO: Paginated endpoints - amend via the limit and offset parameters
# TODO: Error handling
# TODO: Unit tests

# All the custom dataset functionality is available through the ONS
# population types API, so all URLs will begin:
base_url <- "https://api.beta.ons.gov.uk/v1/population-types"

#' Convert ONS population types API URL to a data frame
#'
#' This function takes a URL and converts the JSON response into a data frame.
#'
#' @param url The URL from which to fetch the JSON data.
#' @return A data frame containing the parsed JSON data.
#'
#' @examples
#' url <- "https://api.beta.ons.gov.uk/v1/population-types"
#' df <- url_to_df(url)
#' head(df)
#'
#' @importFrom httr request req_perform resp_body_json
#' @importFrom tibble as_tibble select unnest_wider
url_to_df <- function(url) {
  request(url) |>
    req_perform() |>
    resp_body_json() |>
    as_tibble() |>
    select("items") |>
    unnest_wider("items")
}

#' Get ONS population types
#'
#' This function retrieves ONS population types.
#'
#' @return A data frame containing population types.
#'
#' @importFrom utils url
#' @importFrom readr read_csv
#'
#' @examples
#' get_population_types()
#'
get_population_types <- function() {
  url_to_df(base_url)
}

population_types <- get_population_types()

all_usual_residents <- "atc-rm-pk2-ur-ct-oa"

#' Get area types based on population type name
#'
#' This function retrieves area types based on the provided population type name.
#' It constructs a URL using the base URL and the population type name and
#' fetches the corresponding data frame from that URL.
#'
#' @param population_type_name The name of the population type. Default is
#'                             "atc-rm-pk2-ur-ct-oa" i.e. all usual residents
#'
#' @return A data frame containing the area types.
#'
#' @examples
#' get_area_types()  # Retrieves area types for all usual residents
#' get_area_types("atc-rm-pk3-hh-ct-ltla")  # Retrieves area types for all
#' households
#'
#' @export
get_area_types <- function(population_type_name = all_usual_residents) {
  url_to_df(glue("{base_url}/{population_type_name}/area-types"))
}

area_types <- get_area_types()

lower_tier_las <- "ltla"

#' Retrieve areas based on population type and area type
#'
#' This function retrieves areas based on the specified population type and area
#' type.
#'
#' @param population_type_name A character string specifying the population type.
#' Default is "atc-rm-pk3-hh-ct-ltla" i.e. all usual residents
#' @param area_type_id An integer specifying the area type ID. Default is
#' "ltla" i.e. lower tier local authorities
#'
#' @return A data frame containing the retrieved areas.
#'
#' @examples
#' get_areas()
#' get_areas(population_type_name = "atc-rm-pk3-hh-ct-ltla",
#' area_type_id = "ltla")
#'
#' @export
get_areas <- function(
    population_type_name = all_usual_residents,
    area_type_id = lower_tier_las
  ) {
  url_to_df(glue("{base_url}/{population_type_name}/area-types/{area_type_id}/areas"))
}

areas <- get_areas()

#' Get Variables
#'
#' Retrieves variables based on the population type name. Default is
#'                             "atc-rm-pk2-ur-ct-oa" i.e. all usual residents.
#'
#' @param population_type_name A character string specifying the population type name.
#'
#' @return A data frame containing the retrieved variables.
#'
#' @export
#'
#' @examples
#' get_variables()
#' get_variables("atc-rm-pk2-ur-ct-oa")
get_variables <- function(population_type_name = all_usual_residents) {
  url_to_df(glue("{base_url}/{population_type_name}/dimensions"))
}

variables <- get_variables()

ethnic_group <- "ethnic_group_tb_8a"

#' Get categories for a population type and variable ID
#'
#' This function retrieves categories for a given population type and variable
#'  ID from a specified URL.
#'
#' @param population_type_name The name of the population type.
#' Default is "atc-rm-pk3-hh-ct-ltla" i.e. all usual residents
#' @param variable_id The ID of the variable. Default is "ethnic_group_tb_8a".
#'
#' @return A data frame with the categories.
#'
#' @importFrom glue glue
#' @importFrom dplyr select
#' @importFrom tidyr unnest_longer, unnest_wider
#'
#' @examples
#' get_categories()  # Retrieves categories for all_usual_residents and ethic_group
#' get_categories("atc-rm-pk3-hh-ct-ltla", "ethnic_group_tb_8a")
#'
get_categories <- function(
    population_type_name = all_usual_residents,
    variable_id = ethnic_group
) {
  url_to_df(
    glue("{base_url}/{population_type_name}/dimensions/{variable_id}/categorisations")
  ) |>
    select("categories") |>
    unnest_longer("categories") |>
    unnest_wider("categories")
}

# TODO: Handle "if" i.e. If a specific level of detail is required ...

categories <- get_categories()

sheffield <- "E08000019"

# custom_url <- glue("{base_url}/{all_usual_residents}/census-observations?area-type={lower_tier_las},{sheffield}&dimensions={ethnic_group},1,2")
#
# get_custom_dataset <- function(
#     population_type_name = all_usual_residents,
#     area_type = lower_tier_las,
#     area_id = sheffield,
#     variable_id = ethnic_group
#   ) {
#  glue("{base_url}/{population_type_name}/census-observations?area-type={area_type_id},{area_id}&dimensions={variable_id},{variable_id}")
# }

# Once all the required information has been collated to run the query, the query structure is
# as follows: https://api.beta.ons.gov.uk/v1/population-types/{population-type-name}/censusobservations?area-type={area-type-id},{area-id}&dimensions={variable-id},{variable-id}
# ● The area-type id that was stored should be used in the area-type parameter.
# ● Any required areas should be provided after this using commas, e.g. areatype=wd,E05000650,E05000651,E05000652
# ● Variables and/or categorisations should be provided in a comma separated list in the
# dimensions parameter - e.g. dimensions=accommodation_type,disability_3a.
# ● If the query triggers the disclosure rules, then 0 results will be returned. There is a limit on
# the number of variables that can be provided which varies depending on the level of
# geography applied. A message will be returned if this has been reached.

