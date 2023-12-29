library(rvest)
library(tidyverse)


url <- "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population"

country_links <- rvest::read_html(url) |>
  rvest::html_nodes(".wikitable a") |>
  rvest::html_attr("href") |>
  tibble::enframe() |>
  dplyr::filter(base::grepl("wiki", value)) |>
  dplyr::mutate(value = paste0("https://en.wikipedia.org", value)) |>
  dplyr::slice(-c(1:3)) |>
  dplyr::select(Country = value) |>
  dplyr::distinct()
  
base::saveRDS(object = country_links, file = "./data/country_link.rds")

