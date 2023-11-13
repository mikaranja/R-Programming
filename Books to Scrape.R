library(tidyverse)
library(rvest)


get_title = function(book_link){
  book_info <- read_html(book_link)
  title <- book_info %>% 
    html_node("h1") %>% 
    html_text()
  return(title)
}

get_upc = function(book_link){
  book_info <- read_html(book_link)
  upc <- book_info %>% 
    html_node("tr:nth-child(1) td") %>% 
    html_text()
  return(upc)
}

get_description = function(book_link){
  book_info <- read_html(book_link)
  description <- book_info %>% 
    html_node("#product_description+ p") %>% 
    html_text()
  return(description)
}

get_category = function(book_link){
  book_info <- read_html(book_link)
  category <- book_info %>% 
    html_node(".breadcrumb li~ li+ li a") %>% 
    html_text()
  return(category)
}

get_availability = function(book_link){
  book_info <- read_html(book_link)
  availability <- book_info %>% 
    html_node(".availability") %>% 
    html_text()
  return(availability)
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
  book_price <- page %>% 
    html_nodes(".price_color") %>% 
    html_text()
  book_rating <- page %>% 
    html_nodes(".star-rating") %>% 
    html_attrs() %>% 
    unlist() %>% 
    str_remove_all(., "star-rating") %>% 
    str_trim()

  book_rating <- as.integer(factor(book_rating, levels = names(rating_mapping)))
  
  
  book_title <- sapply(book_link, FUN = get_title, USE.NAMES = FALSE)
  book_upc <- sapply(book_link, FUN = get_upc, USE.NAMES = FALSE) 
  book_description <- sapply(book_link, FUN = get_description, USE.NAMES = FALSE)
  book_category <- sapply(book_link, FUN = get_category, USE.NAMES = FALSE)  
  book_availability <- sapply(book_link, FUN = get_availability, USE.NAMES = FALSE)

  
  books_df <- rbind(books_df, data.frame(
    book_title, book_upc, book_description, book_category, book_rating, book_price,
    book_availability, book_link, stringsAsFactors = FALSE))  
  
  
  print(paste("Page", page_result))
}

write.csv(books_df, "Books to Scrape.csv")

