library(tictoc)
library(bench)

calc_slow <- function(x){
  Sys.sleep(1)
  return(x + 1)
}

tictoc::tic()
calc_slow(1)
tictoc::toc()

bench::mark(base::replicate(10, calc_slow(1)))
