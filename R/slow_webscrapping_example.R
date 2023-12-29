box::use(dplyr)
box::use(tidyr) 
box::use(tibble)
box::use(tidytext) 
box::use(rvest)
box::use(tictoc)
box::use(./ngrams)


country_url <- readRDS("./data/country_link.rds")

ngrams$get_ngrams(country_links$Country[1])

ngrams$get_ngrams_silent(country_links$Country[1])
