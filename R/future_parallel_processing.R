# Coding Session: future parallel processing
box::use(dplyr)
box::use(tidyr)
box::use(tibble)
box::use(tidytext)
box::use(rvest)
box::use(tictoc)
box::use(furrr) 
box::use(./ngrams)
box::use(future)
box::use(progressr)

all_urls <- ngrams$get_data(244)


future::plan(future::sequential)


# Using purrr and map
tictoc::tic()
res_map <- purrr::map(.x = all_urls[1:10], .f = ngrams$get_ngrams)
tictoc::toc()

# Using furrr and future map -----
tictoc::tic()
future::plan(future::multisession, workers = 3) # Multiple parallel processes
res_map_future <- furrr::future_map(.x = all_urls[1:10], 
                                    .f = ngrams$get_ngrams, 
                                    .options = furrr::furrr_options(seed = T))
future::plan(future::sequential)
tictoc::toc()

# Using furrr and future map -----
tictoc::tic()
future::plan(future::multisession, workers = 8) # Multiple parallel processes
res_map_future <- furrr::future_map(.x = all_urls[1:10], 
                                    .f = ngrams$get_ngrams, 
                                    .options = furrr::furrr_options(seed = T))
future::plan(future::sequential)
tictoc::toc()

saveRDS(res_map_future, file = './data/res_map_future.rds')

# Using furrr and map -----

tictoc::tic()
future::plan(future::multisession, workers = 6) # Multiple parallel processes
res_map_future <- furrr::future_map(.x = all_urls, 
                                    .f = ngrams$get_ngrams_local_save_silent,
                                    .options = furrr::furrr_options(seed = T))
future::plan(future::sequential)
tictoc::toc()

## Error handling? purr codes only
?safely
?quietly
?possibly


## Progress bar -----
x <- base::replicate(n = 10, stats::runif(20), simplify = FALSE)

fn <- function(x) {
  Sys.sleep(2)
  sum(x)
}

future::plan(future::multisession, workers = 2)
result <- furrr::future_map(x, fn, .progress = T)
future::plan(future::sequential)
###


x <- replicate(n = 10, runif(20), simplify = FALSE)

future::plan(future::multisession, workers = 2)


fn <- function(x, p) {
  p()
  Sys.sleep(2)
  sum(x)
}


progressr::with_progress({
  p <- progressr::progressor(steps = length(x))
  result <- furrr::future_map(x, fn, p = p)
})

future::plan(future::sequential)
