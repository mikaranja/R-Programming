library(rvest)
library(tidyverse)


get_title = function(book_link){
  book_info <- read_html(book_link)
  title <- book_info %>% 
    html_node("h1") %>% 
    html_text()
  return(title)
}

get_desc = function(book_link){
  book_info <- read_html(book_link)
  desc <- book_info %>% 
    html_node("#product_description+ p") %>% 
    html_text()
  return(desc)
}

get_upc = function(book_link){
  book_info <- read_html(book_link)
  upc <- book_info %>% 
    html_node("tr:nth-child(1) td") %>% 
    html_text()
  return(upc)
}

get_cat = function(book_link){
  book_info <- read_html(book_link)
  cat <- book_info %>% 
    html_node("li~ li+ li a") %>% 
    html_text()
  return(cat)
}

get_avail = function(book_link){
  book_info <- read_html(book_link)
  avail <- as.integer(book_info %>% 
                        html_node("tr:nth-child(6) td") %>% 
                        html_text() %>%
                        str_extract("\\d+"))
  return(avail)
}

get_cover = function(book_link){
  book_info <- read_html(book_link)
  cover <- book_info %>% 
    html_node("img") %>% 
    html_attr("src") 
  cover_suffix <- str_replace_all(cover, "\\.{2}/\\.{2}/", "")
  cover_url <- paste0("https://books.toscrape.com/", cover_suffix)
  return(cover_url)
}


rating_mapping <- c("One" = 1, "Two" = 2, "Three" = 3, "Four" = 4, "Five" = 5)

books_df <- data.frame()


for (page_result in seq(from=1,to=50)) {
  url_link <- paste0("https://books.toscrape.com/catalogue/page-", page_result, ".html")
  page <- read_html(url_link)
  
  book_link <- page %>% 
    html_nodes(".product_pod a") %>%
    html_attr("href") %>% 
    paste0("https://books.toscrape.com/catalogue/", .) %>% 
    unique()
  book_price <- as.integer(page %>% 
                             html_nodes(".price_color") %>% 
                             html_text() %>% 
                             unlist() %>% 
                             str_remove_all("£") %>% 
                             str_trim())
  book_rating <- page %>% 
    html_nodes(".star-rating") %>% 
    html_attrs() %>% 
    unlist() %>% 
    str_remove_all("star-rating") %>% 
    str_trim()
  
  book_rating <- as.integer(factor(book_rating, levels = names(rating_mapping)))
  
  
  book_title <- sapply(book_link, FUN = get_title, USE.NAMES = FALSE)
  book_desc <- sapply(book_link, FUN = get_desc, USE.NAMES = FALSE)
  book_cat <- sapply(book_link, FUN = get_cat, USE.NAMES = FALSE)
  book_upc <- sapply(book_link, FUN = get_upc, USE.NAMES = FALSE)
  book_cover <- sapply(book_link, FUN = get_cover, USE.NAMES = FALSE) 
  book_avail <- sapply(book_link, FUN = get_avail, USE.NAMES = FALSE)
  
  
  books_df <- rbind(books_df, data.frame(
    book_title, book_desc, book_cat, book_upc, book_cover, book_rating, book_price,
    book_avail, book_link, stringsAsFactors = FALSE))  
  
  
  print(paste("Page", page_result))
}

write.csv(books_df, "books_to_scrape.csv")
