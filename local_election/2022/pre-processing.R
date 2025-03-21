# Script for creating the datasets required for visualising the election results data.

# Required packages
library(tidyverse) ; library(lubridate)

# Load in the full election results dataset from 2016 onwards
election_results <- read_csv("https://www.trafforddatalab.io/open_data/elections/trafford_council_election_results.csv")

#----------------------------------
# Create a subset of the full elections results, just for the latest year
latest_results <- election_results %>%
  filter(ElectionDate == "2022-05-05") %>%
  mutate(ward_code = str_extract(ElectoralAreaURI, "E050008[0-9]{2}")) %>%
  select(election_date = ElectionDate,
         ward_code,
         ward_name = ElectoralAreaLabel,
         candidate_surname = CandidateSurname,
         candidate_forenames = CandidateForenames,
         candidate_commonly_used_surname = CommonlyUsedSurname,
         candidate_commonly_used_forenames = CommonlyUsedForenames,
         candidate_description = CandidatesDescription,
         political_party_uri = PoliticalPartyURI,
         political_party_name = PoliticalPartyLabel,
         election_result = Elected,
         votes_won = VotesWon,
         votes_cast = VotesCast,
         eligible_electorate = EligibleElectorate,
         turnout = PercentageTurnout)

write_csv(latest_results, "data/local_election_results_2022.csv")
#----------------------------------

# Create a sub-set of the full election results dataset containing only those candidates who were elected
elected_candidates <- election_results %>%
  filter(TypeofElection == "DistrictAndBorough",
         Elected == "ELECTED") %>%
  mutate(councillor_party_label = case_when(
         CandidatesDescription == "Labour and Co-operative Party" ~ "Labour and Co-operative Party",
         PoliticalPartyLabel == "Conservative and Unionist Party" ~ "Conservative Party",
         TRUE ~ PoliticalPartyLabel)) %>%
  mutate(PoliticalPartyLabel = case_when(
         PoliticalPartyLabel == "Labour and Co-operative Party" ~ "Labour Party",
         PoliticalPartyLabel == "Conservative and Unionist Party" ~ "Conservative Party",
         TRUE ~ PoliticalPartyLabel)) %>%
  mutate(forenames = if_else(is.na(CommonlyUsedForenames), CandidateForenames, str_c(CandidateForenames, " [", CommonlyUsedForenames, "]"))) %>%
  select(election_date = ElectionDate,
         ward = ElectoralAreaLabel,
         surname = CandidateSurname,
         forenames,
         party = PoliticalPartyLabel,
         councillor_party_label,
         votes_won = VotesWon,
         votes_cast = VotesCast,
         electorate = EligibleElectorate,
         turnout = PercentageTurnout)

# Create a dataset only containing the currently serving councillors
current_councillors <- elected_candidates %>%
  # Remove candidates who were elected for only 1 term in the 2021 local elections
  filter(!(election_date == "2021-05-06" & ward == "Priory" & surname == "DAGNALL")) %>%
  arrange(election_date, ward) %>%
  group_by(ward) %>%
  # select the latest 3 councillors
  slice(tail(row_number(), 3))

#----------------------------------
# Political Control dataset

# Amend the current_councillors dataset to produce the data
political_control <- current_councillors %>%
  group_by(ward) %>%
  mutate(elected_ordinal = row_number()) %>%
  ungroup() %>%
  mutate(elected_year = year(election_date)) %>%
  mutate(councillor_name = str_c(surname, ", ", forenames)) %>%
  select(ward,
         councillor_name,
         councillor_party = party,
         councillor_party_label,
         elected_year,
         elected_ordinal)

write_csv(political_control, "data/political_control_2022.csv")

#----------------------------------
# Turnout dataset for all local elections we have data for

turnout <- election_results %>%
  filter(TypeofElection == "DistrictAndBorough") %>%
  mutate(ward_code = str_extract(ElectoralAreaURI, "E050008[0-9]{2}"),
         election_year = year(ElectionDate)) %>%
  select(election_year,
         ward_code,
         ward_name = ElectoralAreaLabel,
         turnout = PercentageTurnout) %>%
  distinct() # remove the multiple rows which are due to there being one row per candidate

write_csv(turnout, "data/local_election_turnout.csv")

#----------------------------------
# Share of the vote from the latest and previous election for the parties who have elected members

vote_share <- election_results %>%
  mutate(ward_code = str_extract(ElectoralAreaURI, "E050008[0-9]{2}"),
         election_year = year(ElectionDate),
         party = case_when(
           # Normalise the party names for ease of grouping
           grepl("Conservative", PoliticalPartyLabel) ~ "Conservative Party",
           PoliticalPartyLabel == "Green Party" ~ "Green Party",
           grepl("Labour", PoliticalPartyLabel) ~ "Labour Party",
           PoliticalPartyLabel == "Liberal Democrats" ~ "Liberal Democrats",
           TRUE ~ "other"
         )) %>%
  filter(TypeofElection == "DistrictAndBorough",
         election_year %in% c(2019, 2021),
         party != "other") %>%
  select(election_year,
         ward_code,
         ward_name = ElectoralAreaLabel,
         party,
         VotesWon,
         VotesCast)
