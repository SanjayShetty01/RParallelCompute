box::use(./ngrams)
box::use(purrr)
box::use(tictoc)

# Retrieve a vector of country links using the get_data function from the 
# ngrams module.
country_links <- ngrams$get_data(10)

tictoc::tic()

# Use purrr::map to apply the get_ngrams_local_save_silent function 
# to each country link.
res_map <- purrr::map(.x = country_links,
                      .f = ngrams$get_ngrams_local_save_silent)
tictoc::toc()
