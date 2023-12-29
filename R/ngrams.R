box::use(dplyr)
box::use(tidyr) 
box::use(tibble)
box::use(tidytext) 
box::use(rvest)
box::use(tictoc)

#' Get a list of country links from a saved RDS file.
#'
#' @param n Number of country links to retrieve.
#'
#' @return A vector of country links.
#'
#' @examples
#' \dontrun{
#' get_data(10)
#' }
get_data <- function(n){
  country_links <- readRDS("./data/country_link.rds") |> 
    dplyr::pull(1) |> 
    utils::head(n)

  return(country_links)
}

#' Extract n-grams from the specified URL.
#'
#' @param url The URL from which to extract n-grams.
#'
#' @return A tibble containing n-grams and their frequencies.
#'
#' @examples
#' \dontrun{
#' get_ngrams("https://example.com")
#' }
get_ngrams <- function(url){
  rvest::read_html(url) |> 
    rvest::html_elements("p") |> 
    rvest::html_text() |> 
    tibble::enframe() |> 
    tidyr::drop_na() |> 
    dplyr::rename(line = 1, text = 2) |> 
    tidytext::unnest_tokens(bigram, text, token = "ngrams", n = 2) |>
    dplyr::filter(!is.na(bigram)) |> 
    tidyr::separate(bigram, c("word1", "word2"), sep = " ") |> 
    dplyr::filter(!word1 %in% tidytext::stop_words$word) |>
    dplyr::filter(!word2 %in% tidytext::stop_words$word) |> 
    dplyr::count(word1, word2, sort = TRUE) |> 
    tidyr::unite(bigram, word1, word2, sep = " ") |> 
    dplyr::filter(n >= 5)
}


#' Extract n-grams from the specified URL silently, with error handling.
#'
#' @param url The URL from which to extract n-grams.
#'
#' @return A tibble containing n-grams and their frequencies, or an empty tibble if an error occurs.
#'
#' @examples
#' \dontrun{
#' get_ngrams_silent("https://example.com")
#' }
get_ngrams_silent <- function(url){
  res <- try(get_ngrams(url), silent = T)
  if (identical(class(res), "try-error")) {
    warning(paste('Incorrect URL:', url)) 
    return(tibble::tibble())
  }else{
    return(res)
  }
}

#' Extract n-grams from the specified URL, save the result locally, and handle errors silently.
#'
#' @param url The URL from which to extract n-grams.
#' @param save_path The path to save the result RDS file.
#'
#' @return A tibble containing n-grams and their frequencies, or an empty tibble if an error occurs.
#'
#' @examples
#' \dontrun{
#' get_ngrams_local_save_silent("https://example.com", "./data/output/")
#' }
get_ngrams_local_save_silent <- function(url, save_path = "./data/output/"){
  res <- try(get_ngrams(url), silent = T)
  if (identical(class(res), "try-error")) {
    warning(paste('Incorrect URL:', url)) 
    return(tibble::tibble())
  }else{
    url2 <- url |> 
      (\(x) gsub('[/]', '_', x))() |>
      (\(x) gsub('[:]', '_', x))() |>
      (\(x) gsub('https___en.wikipedia.org_wiki_', '', x))()
    
    saveRDS(res, file = paste0(save_path, url2, '.rds'))
    return(res)
  }
}
