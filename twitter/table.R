library(DT) ; library(htmltools)

mentions <- read_csv("data/mentions.csv") %>% 
  mutate(created_at = as.Date(as.POSIXct(created_at), format = "%d/%m/%Y"))
tweets <- read_csv("data/tweets.csv") %>% 
  mutate(created_at = as.Date(as.POSIXct(created_at), format = "%d/%m/%Y"))
likes <- read_csv("data/likes.csv") %>% 
  mutate(created_at = as.Date(as.POSIXct(created_at), format = "%d/%m/%Y"))

table <- tweets %>% 
  select(created_at, screen_name, text) %>% 
  datatable(caption = tags$caption(style = 'caption-side: bottom; text-align: center;',
                                   em('Tweets by @TraffordCouncil')),
            width = "100%",
            extensions = 'Scroller', 
            rownames = FALSE, 
            colnames = c("Date", "Handle", "Tweet"),
            options = list(
              deferRender = TRUE,
              autoWidth = TRUE,
              scrollY = 500,
              scroller = TRUE,
              columnDefs = list(list(className = 'dt-left', targets = 0:2)),
              initComplete = JS(
                "function(settings, json) {",
                "$('body').css({'font-family': 'Arial, Helvetica, sans-serif'});",
                "}"))) %>% 
  formatStyle(columns = 1:3, fontSize = "80%")
table

saveWidget(table, "tweets.html", 
           selfcontained = TRUE,
           title = "Tweets by Trafford Council")
