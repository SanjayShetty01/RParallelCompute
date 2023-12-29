# Coding Session: Text Visualization with wordcloud
box::use(wordcloud)
box::use(dplyr)
box::use(RColorBrewer)


res_map_future <- readRDS('./data/res_map_future.rds')

data <- res_map_future |> 
  purrr::reduce(dplyr::bind_rows) |> 
  dplyr::rename(word = 1, freq = 2) |> 
  dplyr::summarise(freq = sum(freq), .by = word) |> 
  dplyr::arrange(dplyr::desc(freq)) |> 
  dplyr::filter(!grepl('parser', word)) |> 
  dplyr::filter(!grepl('0px', word))

set.seed(1234) # for reproducibility 
wordcloud::wordcloud(words = data$word,
          freq = data$freq,
          min.freq = 1,
          max.words = 100,
          random.order = FALSE,
          # rot.per=0.35,
          # scale=c(3.5,0.25),
          colors = RColorBrewer::brewer.pal(8, "Dark2"))
