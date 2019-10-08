# English Indices of Deprivation: LSOA #

library(tidyverse) ; library(janitor) ; library(httr) ; library(readxl) ; library(sf) 

# English Indices of Deprivation 2015 ----------------------------------------- #
# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2019
# Licence: Open Government Licence 3.0

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

# English Indices of Deprivation 2015 ----------------------------------------- #
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

# Bind lsoa2019 and lsoa2015 and write results
bind_rows(lsoa2019, lsoa2015) %>%  write_csv("../trafford_IoD.csv")