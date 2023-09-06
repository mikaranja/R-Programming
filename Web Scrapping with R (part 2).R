#install.packages("rvest")
#install.packages("dplyr")

library(rvest)
library(dplyr)

quotes <- data.frame()

for (page_result in seq(from = 1, to = 10)) {
  url <- paste0("http://quotes.toscrape.com/page/", page_result, "/")
  page <- read_html(url)
  
  text <- page %>% html_nodes(".text") %>% html_text()
  author <- page %>% html_nodes(".author") %>% html_text()
  
  quotes <- rbind(quotes, data.frame(text, author, stringsAsFactors = FALSE))
  print(paste("Page:", page_result))
  }

write.csv(quotes, "quotes.csv")
View(quotes)