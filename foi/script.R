## FOI requests recorded by WhatDoTheyKnow.com ##

# load libraries
library(tidyverse) ; library(rvest) ; library(tidytext) ; library(ggplot2)

# scrape data
url <- "https://www.whatdotheyknow.com/body/trafford_council?page=%d"

df <- map_df(1:20, function(i) {
  html <- read_html(sprintf(url, i))
  data.frame(summary = str_trim(html_text(html_nodes(html, ".head a"))),
             requester = str_trim(html_text(html_nodes(html, ".requester a:nth-child(2)"))),
             status = str_trim(html_text(html_nodes(html, "#public_body_show strong"))),
             status_date = as.Date(html_text(html_nodes(html, "time")), format = "%d %B %Y"),
             stringsAsFactors=FALSE)
})

# write data
write.csv(df, "foi_requests.csv")