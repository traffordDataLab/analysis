# --- Build script for the IoD19 ward reports

library(tidyverse) ; library(sf) ;

# Get the Trafford ward names
wards <- st_read("https://www.trafforddatalab.io/spatial_data/ward/2017/trafford_ward_generalised.geojson") %>%
  st_drop_geometry() %>% # remove the current geometry
  .$area_name

# Create a tibble of the ward names and the parameters to pass the markdown document
reports <- tibble(
  filename = str_c(str_to_lower(str_replace_all(wards, " ", "_")), ".html"),
  params = map(wards, ~list(ward_name = .))
)

# Iterate through the tibble to create a report for each ward
reports %>%
  select(output_file = filename, params) %>%
  pwalk(rmarkdown::render, input = "iod_ward_report_template.Rmd", output_dir = "./")
