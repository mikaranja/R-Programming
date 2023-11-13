#install.packages("rvest")
#install.packages("dplyr")
#install.packages("polite")

library(rvest)
library(dplyr)
library(polite)

page <- bow(url = "http://quotes.toscrape.com/",
            user_agent = "analyst",
            delay = 5,
            force = FALSE) %>% 
  scrape()


text <- page %>% html_nodes(".text") %>% html_text()
author <- page %>% html_nodes(".author") %>% html_text()


quotes <- data.frame(text, author, stringsAsFactors = FALSE)
write.csv(quotes, "quotes.csv")
View(quotes)

