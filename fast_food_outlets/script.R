## Density of fast food outlets ##
# https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/741555/Fast_Food_map.pdf

# load libraries
library(tidyverse) ; library(sf) ; library(units) ; library(tmap)

# load wards and calculate area in sq km
wards <- st_read("https://www.trafforddatalab.io/spatial_data/ward/2017/trafford_ward_full_resolution.geojson") %>%
  st_transform(4326) %>% 
  select(area_code, area_name)

# load fast food outlets
fast_food <- read_csv("https://www.trafforddatalab.io/open_data/fast_food_outlets/trafford_fast_food_outlets.csv") %>% 
  select(name, type, long, lat) %>% 
  st_as_sf(coords = c("long", "lat"), crs = 4326) %>% 
  st_join(wards, join = st_within) %>% # find points within polygons
  count(area_code) %>% 
  st_set_geometry(value = NULL)

# load mid-year population estimates
pop <- read_csv("https://www.trafforddatalab.io/open_data/mid-2017_population_estimates/mid-2017_population_estimates_ward.csv") %>% 
  filter(gender == "Persons") %>% 
  select(area_code, all_ages)

# join datasets and calculate density
sf <- left_join(wards, fast_food) %>% # join ward area data
  left_join(pop) %>% 
  mutate(density = as.numeric(n / all_ages) * 100000) # calculate density
  
# plot choropleth map
tmap_mode("view")
tm_shape(sf) +
  tm_fill(
    col = "density",
    palette = "Reds",
    style = 'jenks',
    contrast = c(0.1, 1),
    title = "Density of fast food outlets",
    id = "area_name",
    showNA = FALSE,
    alpha = 0.8,
    popup.vars = c(
      "Fast food outlets" = "n",
      "Outlets per 100,000 residents" = "density"
    ),
    popup.format = list(
      n = list(format = "f", digits = 0),
      density = list(format = "f", digits = 1)
    )
  ) +
  tm_borders(col = "darkgray", lwd = 0.7) +
  tm_view(basemaps = "OpenStreetMap", 
          view.legend.position = c("left","bottom"))
