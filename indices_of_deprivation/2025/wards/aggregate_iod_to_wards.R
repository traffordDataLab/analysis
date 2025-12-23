# English Indices of Deprivation 2025 - aggregating to Trafford Wards #
# Source: Ministry of Housing, Communities and Local Government
# Publisher URL: https://www.gov.uk/government/statistics/announcements/english-indices-of-deprivation-2025
# Licence: Open Government Licence 3.0 - https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/

# NOTE: Methodology for the calculations can be found in Appendix A of The English Indices of Deprivation Research Report:
#       https://assets.publishing.service.gov.uk/media/68ff547a49d08dd781b48351/ID_2025_Research_Report.pdf

library(sf) ; library(tidyverse) ; library(janitor)

# Load in the best-fit LSOAs to Ward file for Greater Manchester and filter for Trafford
best_fit_lsoa <- read_csv("https://www.trafforddatalab.io/spatial_data/lookups/2025/lsoa_to_ward_best-fit_lookup.csv") %>%
    filter(lad25nm == "Trafford") %>%
    rename(ward_code = wd25cd,
           ward_name = wd25nm) %>%
    select(lsoa21cd, ward_code, ward_name)


# Read in LSOA level IoD2025 data with population denominators, filter for Trafford and just the scores for each domain and index by LSOA
iod_2025 <- read_csv("https://assets.publishing.service.gov.uk/media/691ded56d140bbbaa59a2a7d/File_7_IoD2025_All_Ranks_Scores_Deciles_Population_Denominators.csv") %>% 
    clean_names() %>% 
    select(lsoa21cd = 1, lad24cd = 3, lad24nm = 4, 5:34, 53:56, # we don't want the sub-domain data in columns 35:52
           total_population = total_population_mid_2022,
           dependent_children_population = dependent_children_aged_0_15_mid_2022,
           older_population = older_population_aged_60_and_over_mid_2022,
           working_age_population = working_age_population_18_66_for_use_with_employment_deprivation_domain_mid_2022) %>%
    filter(lad24nm == "Trafford") %>%
    gather(variable, value, -lsoa21cd, -lad24cd, -lad24nm, 
           -total_population, -dependent_children_population, -older_population, -working_age_population) %>% 
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
    select(lsoa21cd, measure, value, index_domain, 
           total_population, dependent_children_population, older_population, working_age_population)

# Take the above and just extract the scores data - we might use the other data later
iod_2025_scores <- iod_2025 %>%
    filter(measure == "score") %>%
    rename(score = value) %>%
    select(lsoa21cd, index_domain, score, everything(), -measure)


# Calculate the weighted scores for each of the domains/indices by multiplying the LSOA score by the appropriate population.
# We will also need to keep the appropriate population figure to use as a denominator later
total_population_weighted_scores <- iod_2025_scores %>%
    filter(!index_domain %in% c("Employment","Income Deprivation Affecting Children","Income Deprivation Affecting Older People")) %>%
    rename(population = total_population) %>%
    mutate(weighted_score = score*population) %>%
    select(lsoa21cd, index_domain, score, population, weighted_score)

working_population_weighted_scores <- iod_2025_scores %>%
    filter(index_domain == "Employment") %>%
    rename(population = working_age_population) %>%
    mutate(weighted_score = score*population) %>%
    select(lsoa21cd, index_domain, score, population, weighted_score)

children_population_weighted_scores <- iod_2025_scores %>%
    filter(index_domain == "Income Deprivation Affecting Children") %>%
    rename(population = dependent_children_population) %>%
    mutate(weighted_score = score*population) %>%
    select(lsoa21cd, index_domain, score, population, weighted_score)

older_population_weighted_scores <- iod_2025_scores %>%
    filter(index_domain == "Income Deprivation Affecting Older People") %>%
    rename(population = older_population) %>%
    mutate(weighted_score = score*population) %>%
    select(lsoa21cd, index_domain, score, population, weighted_score)

iod_2025_weighted_scores <- bind_rows(total_population_weighted_scores,
                                      working_population_weighted_scores,
                                      children_population_weighted_scores,
                                      older_population_weighted_scores)


# Join the best-fit LSOAs to the wards and calculate the ward average scores by summing all the scores and populations.
# Then calculate the ranks based on the scores (highest score is lowest rank which is the most deprived).
ward_average_scores_ranks <- iod_2025_weighted_scores %>%
    left_join(best_fit_lsoa, by = "lsoa21cd") %>%
    group_by(ward_code, ward_name, index_domain) %>%
    summarise(ward_weighted_score = sum(weighted_score),
              ward_population = sum(population),
              ward_average_score = ward_weighted_score/ward_population) %>%
    ungroup() %>%
    group_by(index_domain) %>%
    mutate(ward_average_score_rank = min_rank(desc(ward_average_score))) %>%
    select(ward_code, ward_name, index_domain, ward_average_score, ward_average_score_rank) %>%
    write_csv("trafford_wards_iod2025_average_scores_ranks.csv")
    

