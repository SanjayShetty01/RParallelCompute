box::use(doSNOW)
box::use(dplyr)
box::use(./ngrams)
box::use(tibble)
box::use(tictoc)
box::use(parallel)
box::use(foreach)

all_urls <- ngrams$get_data(244)

tictoc::tic()
res_all <- tibble::tibble()

for (i in 1:length(all_urls)) {
  print('---------')
  print(i)
  url_i <- all_urls[i]
  print(url_i)
  res_i <- ngrams$get_ngrams(url_i)
  
  res_all <- res_all |> 
    dplyr::bind_rows(res_i)
}

tictoc::toc()

all_urls <- ngrams$get_data(244)


tictoc::tic()
ngrams$get_ngrams(all_urls[1])
tictoc::toc()

`%dopar%` <- foreach::`%dopar%`

tictoc::tic()
cl <- parallel::makeCluster(6) 
doSNOW::registerDoSNOW(cl)

result <- foreach::foreach(i = all_urls, 
                  .packages = c('dplyr', 'tidyr', 'tibble', 'rvest', 'tidytext'),
                  .errorhandling = "stop") %dopar%
  {
    ngrams$get_ngrams(i)
  }

parallel::stopCluster(cl)
tictoc::toc()


result <- result |> 
  purrr::reduce(dplyr::bind_rows)


all_urls2 <- c(all_urls[1:10], 'abcd')

tictoc::tic()
cl <- parallel::makeCluster(3) 
doSNOW::registerDoSNOW(cl)

res_stop <- foreach(i = all_urls2, 
                    .packages = c('dplyr', 'tidyr', 'tibble', 'rvest', 'tidytext'),
                    .errorhandling = "stop") %dopar%
  {
    ngrams$get_ngrams(i)
  }


res_remove <- foreach::foreach(i = all_urls2, 
                      .packages = c('dplyr', 'tidyr', 'tibble', 'rvest', 'tidytext'),
                      .errorhandling = "remove") %dopar%
  {
    ngrams$get_ngrams(i)
  }

res_pass <- foreach::foreach(i = all_urls2, 
                    .packages = c('dplyr', 'tidyr', 'tibble', 'rvest', 'tidytext'),
                    .errorhandling = "pass") %dopar%
  {
    ngrams$get_ngrams(i)
  }

res_pass %>% 
  purrr::reduce(bind_rows)

parallel::stopCluster(cl)
tictoc::toc()


tictoc::tic()
cl <- parallel::makeCluster(10) 
doSNOW::registerDoSNOW(cl)

iterations <- length(all_urls)
pb <- txtProgressBar(max = iterations, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress = progress)

result <- foreach::foreach(i = all_urls, 
                  .packages = c('dplyr', 'tidyr', 'tibble', 'rvest', 'tidytext'),
                  .options.snow = opts,
                  .errorhandling = "stop") %dopar%
  {
    ngrams$get_ngrams_local_save_silent(i)
  }

close(pb)
parallel::stopCluster(cl)
tictoc::toc()