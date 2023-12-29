box::use(./ngrams)
box::use(purrr)
box::use(tictoc)

## All countries
country_links <- ngrams$get_data(10)

## Using Loop ----
for (i in 1:10) {
  print(i)
  res_i <- ngrams$get_ngrams(country_links[i])
}

# Using Base R and Apply Scripts ----
tictoc::tic()
res_apply <- lapply(country_links[1:10],  ngrams$get_ngrams)
tictoc::toc()

# Using purrr and map ----
tictoc::tic()
res_map <- purrr::map(.x = country_links[1:10], .f =  ngrams$get_ngrams)
tictoc::toc()


iris |>
  dplyr::group_by(Species) |>
  dplyr::group_map(~ broom::tidy(lm(Petal.Length ~ Sepal.Length, data = .x)))