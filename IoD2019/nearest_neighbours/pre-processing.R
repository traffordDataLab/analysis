# English Indices of Deprivation 2019 ---------------------------------------- #
# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2019
# Licence: Open Government Licence 3.0

library(tidyverse) ; library(janitor) ; library(httr) ; library(readxl) ; library(sf) 

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833995/File_10_-_IoD2019_Local_Authority_District_Summaries__lower-tier__.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))
sheets <- excel_sheets(tmp) 
df <- set_names(sheets[2:11]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A1:J318", col_names = FALSE), .id = "sheet") %>% 
  filter(`...2` %in% c("Bedford", "Swindon", "South Gloucestershire","Reading", "Stockport",
                       "Milton Keynes", "Trafford", "York", "Poole", "Warrington", "Solihull",
                       "Darlington", "Cheshire West and Chester", "Thurrock", "Telford and Wrekin",
                       "Peterborough")) %>% 
  select(index_domain = sheet, 
         lad19cd = `...1`,
         lad19nm = `...2`,
         rank_average_score = `...6`,
         percent_bottom_decile = `...7`) %>% 
  mutate(index_domain = case_when(
    index_domain == "IMD" ~ "Index of Multiple Deprivation", 
    index_domain == "Income" ~ "Income",
    index_domain == "Employment" ~ "Employment",
    index_domain == "Education" ~ "Education, Skills and Training",
    index_domain == "Health" ~ "Health and Disability",
    index_domain == "Crime" ~ "Crime",
    index_domain == "Barriers" ~ "Barriers to Housing and Services",
    index_domain == "Living" ~ "Living Environment",
    index_domain == "IDACI" ~ "Income Deprivation Affecting Children",
    index_domain == "IDAOPI" ~ "Income Deprivation Affecting Older People")) %>% 
  select(lad19cd, lad19nm, everything()) %>% 
  mutate(rank_average_score = as.integer(rank_average_score),
         percent_bottom_decile = as.numeric(percent_bottom_decile),
         year = "2019")

write_csv(df, "nearest_neighbours.csv")

