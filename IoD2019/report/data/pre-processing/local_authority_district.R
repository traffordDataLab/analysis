# English Indices of Deprivation: local authority district summary #

library(tidyverse) ; library(janitor) ; library(httr) ; library(readxl) ; library(sf) 

# English Indices of Deprivation 2019 ---------------------------------------- #
# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2019
# Licence: Open Government Licence 3.0

url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833995/File_10_-_IoD2019_Local_Authority_District_Summaries__lower-tier__.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))
sheets <- excel_sheets(tmp) 
la2019 <- set_names(sheets[2:11]) %>% 
  map_df(~ read_xlsx(path = tmp, sheet = .x, range = "A1:J318", col_names = FALSE), .id = "sheet") %>% 
  filter(`...2` %in% c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")) %>% 
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

# English Indices of Deprivation 2015 ---------------------------------------- #
# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/english-indices-of-deprivation-2015
# Licence: Open Government Licence 3.0

# Please note: IoD2015 data are reaggregated to 2019 local authority district boundaries

# Method #
# Calculation of average scores: (Appendix A of the Research Report: https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833947/IoD2019_Research_Report.pdf)
# Population denominators: (15, FAQs: https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/835119/IoD2019_FAQ.pdf)

# Read LSOA level IoD2015 data with population variable
lsoa2015 <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/467774/File_7_ID_2015_All_ranks__deciles_and_scores_for_the_Indices_of_Deprivation__and_population_denominators.csv") %>% 
  clean_names() %>% 
  select(lsoa11cd = 1, lad13cd = 3, lad13nm = 4, 5:34, 
         total_population = total_population_mid_2012_excluding_prisoners,
         working_age = working_age_population_18_59_64_for_use_with_employment_deprivation_domain_excluding_prisoners,
         dependent_children = dependent_children_aged_0_15_mid_2012_excluding_prisoners,
         older_population = older_population_aged_60_and_over_mid_2012_excluding_prisoners) %>% 
  gather(variable, value, -lsoa11cd, -lad13cd, -lad13nm, 
         -total_population, -working_age, -dependent_children, -older_population) %>% 
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
  select(lsoa11cd, lad13cd, lad13nm, measure, value, index_domain, 
         total_population, working_age, dependent_children, older_population) %>% 
  spread(measure, value)

# Create LSOA > LA lookup for 2019 boundaries using IoD2019 data
lookup <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833982/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators.csv") %>% 
  clean_names() %>% 
  select(lsoa11cd = 1, lad19cd = 3, lad19nm = 4) %>% 
  distinct(lsoa11cd, .keep_all = TRUE)

# Calculate average score for IMD and domains (excluding Employment, IDOACI and IDOPCI)
rank_average_score_total_population <- 
  left_join(filter(lsoa2015, !index_domain %in% c("Employment","Income Deprivation Affecting Children","Income Deprivation Affecting Older People")), 
            lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lad19cd, lad19nm, index_domain, score, total_population) %>% 
  # multiply each LSOA score by its population 
  mutate(pop_weighted_score = score*total_population) %>% 
  group_by(index_domain, lad19cd, lad19nm) %>%
  # sum scores by local authority district
  summarise(total_pop_weighted_score = sum(pop_weighted_score),
            # sum LSOA population by local authority district
            district_pop = sum(total_population),
            # divide summed score by local authority district population
            average_district_score = total_pop_weighted_score/district_pop) %>% 
  ungroup() %>% 
  # rank in ascending order
  group_by(index_domain) %>%
  mutate(rank_average_score = dense_rank(desc(average_district_score))) %>% 
  select(lad19cd, lad19nm, index_domain, rank_average_score)

# Calculate average score for Employment domain
rank_average_score_working_age <- 
  left_join(filter(lsoa2015, index_domain == "Employment"), lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lad19cd, lad19nm, index_domain, score, working_age) %>% 
  mutate(pop_weighted_score = score*working_age) %>% 
  group_by(index_domain, lad19cd, lad19nm) %>%
  summarise(total_pop_weighted_score = sum(pop_weighted_score),
            district_pop = sum(working_age),
            average_district_score = total_pop_weighted_score/district_pop) %>% 
  ungroup() %>% 
  group_by(index_domain) %>%
  mutate(rank_average_score = dense_rank(desc(average_district_score))) %>% 
  select(lad19cd, lad19nm, index_domain, rank_average_score)

# Calculate average score for Income Deprivation Affecting Children index
rank_average_score_dependent_children <- 
  left_join(filter(lsoa2015, index_domain == "Income Deprivation Affecting Children"), lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lad19cd, lad19nm, index_domain, score, dependent_children) %>% 
  mutate(pop_weighted_score = score*dependent_children) %>% 
  group_by(index_domain, lad19cd, lad19nm) %>%
  summarise(total_pop_weighted_score = sum(pop_weighted_score),
            district_pop = sum(dependent_children),
            average_district_score = total_pop_weighted_score/district_pop) %>% 
  ungroup() %>% 
  group_by(index_domain) %>%
  mutate(rank_average_score = dense_rank(desc(average_district_score))) %>% 
  select(lad19cd, lad19nm, index_domain, rank_average_score)

# Calculate average score for Income Deprivation Affecting Older People index
rank_average_score_older_population <- 
  left_join(filter(lsoa2015, index_domain == "Income Deprivation Affecting Older People"), lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lad19cd, lad19nm, index_domain, score, older_population) %>% 
  mutate(pop_weighted_score = score*older_population) %>% 
  group_by(index_domain, lad19cd, lad19nm) %>%
  summarise(total_pop_weighted_score = sum(pop_weighted_score),
            district_pop = sum(older_population),
            average_district_score = total_pop_weighted_score/district_pop) %>% 
  ungroup() %>% 
  group_by(index_domain) %>%
  mutate(rank_average_score = dense_rank(desc(average_district_score))) %>% 
  select(lad19cd, lad19nm, index_domain, rank_average_score)

rank_average_score <- bind_rows(rank_average_score_total_population,
                                rank_average_score_working_age,
                                rank_average_score_dependent_children,
                                rank_average_score_older_population)

# Calculate proportion of LSOAs in the most deprived 10 per cent nationally
percent_bottom_decile <- left_join(lsoa2015, lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lad19cd, lad19nm, index_domain, decile) %>% 
  group_by(index_domain, lad19cd, lad19nm) %>% 
  summarise(n = sum(decile[decile == 1]),
            lsoas = n(),
            percent_bottom_decile = n/lsoas) %>% 
  select(lad19cd, index_domain, percent_bottom_decile)

# Join recalculated data
la2015 <- left_join(rank_average_score, percent_bottom_decile, by = c("lad19cd", "index_domain")) %>% 
  mutate(year = "2015")

# Bind la2019 and la2015 and write results
bind_rows(la2019, la2015) %>% 
  filter(lad19nm %in% c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")) %>% 
  write_csv("../IoD_local_authority.csv")   
