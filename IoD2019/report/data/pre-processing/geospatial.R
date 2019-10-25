# Trafford's administrative and statistical boundaries #

library(tidyverse) ; library(jsonlite) ; library(sf)

# Source: ONS Open Geography Portal 
# Publisher URL: http://geoportal.statistics.gov.uk/
# Licence: Open Government Licence 3.0

# Pull a vector of LSOA codes
lookup <- st_read(paste0("https://ons-inspire.esriuk.com/arcgis/rest/services/Census_Boundaries/Lower_Super_Output_Areas_December_2011_Boundaries/MapServer/2/query?where=UPPER(lsoa11nm)%20like%20'%25", URLencode(toupper("Trafford"), reserved = TRUE), "%25'&outFields=lsoa11cd,lsoa11nm&outSR=4326&f=geojson")) %>% 
  pull(lsoa11cd)

# Lower-layer Super Output Area boundaries #
lsoa <- st_read("https://opendata.arcgis.com/datasets/da831f80764346889837c72508f046fa_2.geojson") %>% 
  filter(lsoa11cd %in% lookup) %>%
  select(lsoa11cd) %>% 
  st_as_sf(crs = 4326, coords = c("long", "lat"))

# Best-fit lookup between LSOAs and wards
best_fit_lookup <- read_csv("https://opendata.arcgis.com/datasets/8c05b84af48f4d25a2be35f1d984b883_0.csv") %>% 
  setNames(tolower(names(.)))  %>%
  filter(lsoa11cd %in% lookup) %>%
  select(lsoa11cd, lsoa11nm, wd18cd, wd18nm)

# Join and write results
left_join(lsoa, best_fit_lookup, by = "lsoa11cd") %>% 
  select(lsoa11cd, lsoa11nm, wd18cd, wd18nm) %>%
  st_write("../trafford_lsoa.geojson")

# Trafford's electoral ward boundaries
st_read("https://opendata.arcgis.com/datasets/a0b43fe01c474eb9a18b6c90f91664c2_2.geojson") %>%
  filter(wd18cd %in% pull(distinct(best_fit_lookup, wd18cd),wd18cd)) %>%
  select(wd18cd, wd18nm, lon = long, lat) %>% 
  st_write("../trafford_wards.geojson")
