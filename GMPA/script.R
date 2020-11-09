# English Indices of Deprivation 2019 #
# Index of Multiple Deprivation #

# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2019
# Licence: Open Government Licence 3.0

# MHCLG does not publish the Indices of Deprivation at ward level. 
# Ward level data produced according to the Appendix A. How to aggregate to different geographies of the English Indices of Deprivation 2019 Research report

library(sf) ; library(tidyverse) ; library(janitor)

gm <- c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")

iod <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833982/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators.csv") %>%
  clean_names() %>%
  filter(`local_authority_district_name_2019` %in% gm) %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "index_of_multiple_deprivation_imd_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Index of Multiple Deprivation")

# LSOA to electoral ward lookup #

# Source: ONS Open Geography Portal 
# Publisher URL: http://geoportal.statistics.gov.uk/
# Licence: Open Government Licence 3.0

# Best-fit lookup between LSOAs and electoral wards
lookup <- read_csv("https://opendata.arcgis.com/datasets/8c05b84af48f4d25a2be35f1d984b883_0.csv") %>% 
  setNames(tolower(names(.)))  %>%
  filter(lad18nm %in% gm) %>%
  select(lsoa11cd, wd18cd, wd18nm, lad18cd, lad18nm)

# IoD LSOA to electoral ward
iod_wards <- left_join(iod, lookup, by = "lsoa11cd") %>%
  group_by(wd18cd, wd18nm, lad18cd, lad18nm, indicator) %>%
  summarise(average_score = round(sum(score*population)/sum(population), 1)) %>%
  ungroup %>%
  arrange(desc(average_score)) %>% 
  mutate(rank_average_score = rank(desc(average_score), ties.method = "min"))

write_csv (iod_wards, "index_of_multiple_deprivation.csv")

