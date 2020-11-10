# English Indices of Deprivation 2019, electoral wards in Greater Manchester #

# Method -----------------------------------------------------------------------
# Ward level data are produced following "Appendix A. How to aggregate to different geographies" in the English Indices of Deprivation 2019 Research report
# URL: https://www.gov.uk/government/publications/english-indices-of-deprivation-2019-research-report

library(sf) ; library(tidyverse) ; library(janitor)

gm <- c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")

# Indices of Multiple Deprivation
# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2019
# Licence: Open Government Licence 3.0
iod <- read_csv("https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833982/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators.csv") %>%
  clean_names() %>%
  filter(`local_authority_district_name_2019` %in% gm) 

# Index of Multiple Deprivation
imd <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "index_of_multiple_deprivation_imd_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Index of Multiple Deprivation")

# Income
income <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "income_score_rate", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Income")

# Employment
employment <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "employment_score_rate", population = "working_age_population_18_59_64_for_use_with_employment_deprivation_domain_excluding_prisoners") %>% 
  mutate(indicator = "Employment")
  
# Education, Skills and Training
education <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "education_skills_and_training_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Education, Skills and Training")

# Health and Disability
health <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "health_deprivation_and_disability_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Health and Disability")

# Crime
crime <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "crime_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Crime")

# Barriers to Housing and Services
housing <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "barriers_to_housing_and_services_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Barriers to Housing and Services")

# Living Environment
environment <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "living_environment_score", population = "total_population_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Living Environment")

# Income Deprivation Affecting Children
idaci <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "income_deprivation_affecting_children_index_idaci_score_rate", population = "dependent_children_aged_0_15_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Income Deprivation Affecting Children")

# Income Deprivation Affecting Older People
idaopi <- iod %>% 
  select(lsoa11cd = "lsoa_code_2011", score = "income_deprivation_affecting_older_people_idaopi_score_rate", population = "older_population_aged_60_and_over_mid_2015_excluding_prisoners") %>% 
  mutate(indicator = "Income Deprivation Affecting Older People")

# Best-fit lookup between LSOAs and electoral wards
# Source: ONS Open Geography Portal 
# Publisher URL: http://geoportal.statistics.gov.uk/
# Licence: Open Government Licence 3.0
lookup <- read_csv("https://opendata.arcgis.com/datasets/8c05b84af48f4d25a2be35f1d984b883_0.csv") %>% 
  setNames(tolower(names(.)))  %>%
  filter(lad18nm %in% gm) %>%
  select(lsoa11cd, wd18cd, wd18nm, lad18cd, lad18nm)

# Calculate average scores for best-fit LSOAs
iod_wards <- bind_rows(imd, income, employment, education, health, crime, housing, environment, idaci, idaopi) %>% 
  left_join(lookup, by = "lsoa11cd") %>%
  group_by(wd18cd, wd18nm, lad18cd, lad18nm, indicator) %>%
  summarise(average_score = round(sum(score*population)/sum(population), 1)) %>%
  ungroup() %>% 
  pivot_wider(names_from = indicator, values_from = average_score) %>% 
  select(wd18cd, wd18nm, lad18cd, lad18nm, `Index of Multiple Deprivation`, everything()) %>% 
  arrange(desc(`Index of Multiple Deprivation`))

# write results
write_csv(iod_wards, "indices_of_multiple_deprivation_GM.csv")
openxlsx::write.xlsx(iod_wards, "indices_of_multiple_deprivation_GM.xlsx")
