# Coding Session: Data Manipulation with multidplyr
box::use(multidplyr)
box::use(dplyr)
box::use(nycflights13)
box::use(tictoc)
box::use(mgcv)
box::use(gam)

utils::str(nycflights13::flights)

nycflights13::flights |>
  head() |>
  View()


?multidplyr::new_cluster

cluster <- multidplyr::new_cluster(4)

print(cluster)

flights1 <- 
  nycflights13::flights |> 
  dplyr::group_by(dest) |> 
  multidplyr::partition(cluster)

flights1


tictoc::tic()
nycflights13::flights |> 
  dplyr::group_by(dest) |> 
  dplyr::summarise(dep_delay = mean(dep_delay, na.rm = TRUE))
tictoc::toc()

tictoc::tic()
flights1 |> 
  dplyr::summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  dplyr::collect()
tictoc::toc()

## WHEN TO USE ----
# For basic dplyr verbs, multidplyr is unlikely to give you significant speed ups 
# unless you have 10s or 100s of millions of data points
# (and in that scenario you should first try dtplyr, which uses data.table).
# 
# multipldyr might help, however, if you’re doing more complex things. 
# Let’s see how that plays out when fitting a moderately complex model. 

daily_flights <- nycflights13::flights |>
  dplyr::count(dest) |>
  dplyr::filter(n >= 365)

common_dest <- nycflights13::flights |> 
  dplyr::semi_join(daily_flights, by = "dest") |> 
  dplyr::mutate(yday = lubridate::yday(ISOdate(year, month, day))) |> 
  dplyr::group_by(dest)

by_dest <- common_dest |> 
  multidplyr::partition(cluster)

by_dest

tictoc::tic()
models <- common_dest |> 
  dplyr::group_by(dest) |> 
  dplyr::do(mod = gam::gam(dep_delay ~ gam::s(yday) + gam::s(dep_time), data = .))
tictoc::toc()

multidplyr::cluster_library(cluster, "mgcv")

tictoc::tic()
models <- by_dest |> 
  dplyr::do(mod =gam::gam(dep_delay ~ gam::s(yday) + gam::s(dep_time), data = .))
tictoc::toc()
