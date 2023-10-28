#install.packages("rvest")
#install.packages("dplyr")

library(rvest)
library(dplyr)


get_born = function(author_link) {
  author_born <- read_html(author_link)
  born <- author_born %>%
    html_node(".author-title+ p") %>%
    html_text()
  return(born)
}

get_bio = function(author_link) {
  author_bio <- read_html(author_link)
  bio <- author_bio %>%
    html_node(".author-description") %>%
    html_text()
  return(bio)
}

quotes <- data.frame()

for (page_result in seq(from = 1, to = 10)){
  url <- paste0("http://quotes.toscrape.com/page/", page_result, "/")
  page <- read_html(url)

  author_link <-page %>%
    html_nodes(".quote span a") %>% html_attr("href") %>%
    paste0("https://quotes.toscrape.com/", .)
  
  text <- page %>% html_nodes(".text") %>% html_text()
  author <- page %>% html_nodes(".author") %>% html_text()

  born <- sapply(author_link, FUN = get_born, USE.NAMES = FALSE)
  bio <- sapply(author_link, FUN = get_bio, USE.NAMES = FALSE)

  quotes <-rbind(quotes, data.frame(text, author, author_link, born, bio,
                                    stringsAsFactors = FALSE))

  print(paste("Page:", page_result))
}

write.csv(quotes, "quotes.csv")
View(quotes)
