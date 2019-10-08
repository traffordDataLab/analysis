# English Indices of Deprivation #

library(tidyverse) ; library(janitor) ; library(httr) ; library(readxl) ; library(sf) 

# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2019
# Licence: Open Government Licence 3.0

# LSOA
lsoa2019 <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833982/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators.csv") %>% 
  clean_names() %>% 
  filter(local_authority_district_name_2019 == "Trafford") %>% 
  select(lsoa11cd = 1, lad19cd = 3, lad19nm = 4, 5:34) %>% 
  gather(variable, value, -lsoa11cd, -lad19cd, -lad19nm) %>% 
  mutate(measure = case_when(str_detect(variable, "score") ~ "score", 
                             str_detect(variable, "decile") ~ "decile", 
                             str_detect(variable, "rank") ~ "rank"),
         index_domain = case_when(str_detect(variable, "index_of_multiple_deprivation") ~ "Index of Multiple Deprivation", 
                                  str_detect(variable, "employment") ~ "Employment",
                                  str_detect(variable, "education") ~ "Education, Skills and Training",
                                  str_detect(variable, "health") ~ "Health and Disability",
                                  str_detect(variable, "crime") ~ "Crime",
                                  str_detect(variable, "barriers") ~ "Barriers to Housing and Services",
                                  str_detect(variable, "living") ~ "Living Environment",
                                  str_detect(variable, "idaci") ~ "Income Deprivation Affecting Children",
                                  str_detect(variable, "idaopi") ~ "Income Deprivation Affecting Older People",
                                  TRUE ~ "Income")) %>% 
  select(lsoa11cd, lad19cd, lad19nm, measure, value, index_domain) %>% 
  spread(measure, value) %>% 
  mutate(year = "2019")

# Local authority district summary
url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833995/File_10_-_IoD2019_Local_Authority_District_Summaries__lower-tier__.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))
sheets <- excel_sheets(tmp) 
la2019 <- set_names(sheets[2:11]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A1:J318", col_names = FALSE), .id = "sheet") %>% 
  filter(`...2` %in% c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")) %>% 
  select(index_domain = sheet, 
         lad19cd = `...1`,
         lad19nm = `...2`,
         `Rank of average IMD 2019 score` = `...6`,
         `LSOAs in 1st decile` = `...7`) %>% 
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
  mutate(year = "2019")

# ------------------------------------------

# English Indices of Deprivation 2015 #

# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/english-indices-of-deprivation-2015
# Licence: Open Government Licence 3.0

# LSOA
lsoa2015 <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/467774/File_7_ID_2015_All_ranks__deciles_and_scores_for_the_Indices_of_Deprivation__and_population_denominators.csv") %>% 
  clean_names() %>% 
  filter(local_authority_district_name_2013 == "Trafford") %>% 
  select(lsoa11cd = 1, lad19cd = 3, lad19nm = 4, 5:34) %>% 
  gather(variable, value, -lsoa11cd, -lad19cd, -lad19nm) %>% 
  mutate(measure = case_when(str_detect(variable, "score") ~ "score", 
                             str_detect(variable, "decile") ~ "decile", 
                             str_detect(variable, "rank") ~ "rank"),
         index_domain = case_when(str_detect(variable, "index_of_multiple_deprivation") ~ "Index of Multiple Deprivation", 
                                  str_detect(variable, "employment") ~ "Employment",
                                  str_detect(variable, "education") ~ "Education, Skills and Training",
                                  str_detect(variable, "health") ~ "Health and Disability",
                                  str_detect(variable, "crime") ~ "Crime",
                                  str_detect(variable, "barriers") ~ "Barriers to Housing and Services",
                                  str_detect(variable, "living") ~ "Living Environment",
                                  str_detect(variable, "idaci") ~ "Income Deprivation Affecting Children",
                                  str_detect(variable, "idaopi") ~ "Income Deprivation Affecting Older People",
                                  TRUE ~ "Income")) %>% 
  select(lsoa11cd, lad19cd, lad19nm, measure, value, index_domain) %>% 
  spread(measure, value) %>% 
  mutate(year = "2015")

# Local authority district summary
url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/464464/File_10_ID2015_Local_Authority_District_Summaries.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))
sheets <- excel_sheets(tmp) 
la2015 <- set_names(sheets[2:11]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A1:J318", col_names = FALSE), .id = "sheet") %>% 
  filter(`...2` %in% c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")) %>% 
  select(index_domain = sheet, 
         lad19cd = `...1`,
         lad19nm = `...2`,
         `Rank of average IMD 2019 score` = `...6`,
         `LSOAs in 1st decile` = `...7`) %>% 
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
  mutate(year = "2015")

# Bind lsoa2019 and lsoa2015
bind_rows(lsoa2019, lsoa2015) %>%  write_csv("trafford_IoD.csv")

# Bind la2019 and la2015
bind_rows(la2019, la2015) %>% write_csv("IoD_local_authority.csv")

# ------------------------------------------------------------------------------

# Trafford administrative and statistical boundaries #

# Source: ONS Open Geography Portal 
# Publisher URL: http://geoportal.statistics.gov.uk/
# Licence: Open Government Licence 3.0

# Lower-layer Super Output Area boundaries #
lsoa <- st_read("https://opendata.arcgis.com/datasets/da831f80764346889837c72508f046fa_2.geojson") %>% 
  filter(lsoa11cd %in% pull(distinct(filter(lsoa2019, lad19nm == "Trafford"), lsoa11cd))) %>%
  select(lsoa11cd) %>% 
  st_as_sf(crs = 4326, coords = c("long", "lat"))

# Best-fit lookup between LSOAs and wards
best_fit_lookup <- read_csv("https://opendata.arcgis.com/datasets/8c05b84af48f4d25a2be35f1d984b883_0.csv") %>% 
  setNames(tolower(names(.)))  %>%
  filter(lsoa11cd %in% pull(distinct(filter(lsoa2019, lad19nm == "Trafford"), lsoa11cd))) %>%
  select(lsoa11cd, lsoa11nm, wd18cd, wd18nm)

# Join and write results
left_join(lsoa, best_fit_lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lsoa11nm, wd18cd, wd18nm) %>%
  st_write("trafford_lsoa.geojson")

# Trafford's electoral ward boundaries
st_read("https://opendata.arcgis.com/datasets/a0b43fe01c474eb9a18b6c90f91664c2_2.geojson") %>%
  filter(wd18cd %in% pull(distinct(best_fit_lookup, wd18cd),wd18cd)) %>%
  select(wd18cd, wd18nm, lon = long, lat) %>% 
  st_write("trafford_wards.geojson")


