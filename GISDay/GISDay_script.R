## GISDay (14 November 2018) script ##

# credits: https://stackoverflow.com/questions/52937483/r-fitting-a-grid-over-a-city-map-and-inputting-data-into-grid-squares/53131001#53131001

# load the necessary R packages
library(tidyverse) ; library(httr) ; library(jsonlite) ; library(sf) ; library(viridis) ; library(ggspatial)

# download a vector boundary of Trafford
bdy <- st_read("https://opendata.arcgis.com/datasets/fab4feab211c4899b602ecfbfbc420a3_3.geojson", quiet = TRUE) %>% 
  filter(lad17nm == "Trafford") # select local authority district

# extract the coordinates and format for inclusion in the API request parameter
coords <- bdy %>% 
  st_coordinates() %>%
  as.data.frame() %>%
  select(X, Y) %>% 
  unite(coords, Y, X, sep = ',') %>% 
  mutate(coords = sub("$", ":", coords)) %>% 
  .[["coords"]] %>% 
  paste(collapse = "") %>% 
  str_sub(., 1, str_length(.)-1)

# sumbit the API request
path <- "https://data.police.uk/api/crimes-street/all-crime"
request <- POST(url = path,
                query = list(poly = coords, date = "2018-08"))

# check for any server error
request$status_code

# parse the response and convert to a data frame
response <- content(request, as = "text", encoding = "UTF-8") %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble()

# convert to a data frame
df <- data.frame(
  month = response$month,
  category = response$category,
  location = response$location.street.name,
  long = as.numeric(as.character(response$location.longitude)),
  lat = as.numeric(as.character(response$location.latitude)),
  stringsAsFactors = FALSE
)

# filter by category and convert to geospatial object
sf <- df %>%
  filter(category == "burglary") %>% # select category
  st_as_sf(crs = 4326, coords = c("long", "lat")) %>% 
  st_transform(27700)

# create a 250m x 250m grid
grid <- st_transform(bdy, 27700) %>%
  st_make_grid(cellsize = c(250, 250)) %>%
  st_intersection(st_transform(bdy, 27700)) %>%
  st_cast("MULTIPOLYGON") %>%
  st_sf() %>%
  mutate(id = row_number())

# join and calculate frequency per grid square
crime_grid <- grid %>%
  st_join(., sf, join = st_intersects) %>%
  filter(!is.na(category)) %>% 
  group_by(id) %>%
  summarise(num_crimes = n())

# plot results
ggplot() + 
  #annotation_map_tile(type = "cartolight", zoomin = -0) +
  geom_sf(data = crime_grid, aes(fill = num_crimes), alpha = 0.8, colour = 'white', size = 0.3) +
  geom_sf(data = grid, fill = NA, colour = "#757575", size = 0.3) +
  scale_fill_viridis(discrete = F, direction = -1, name = "Police recorded crimes",
                     guide = guide_colourbar(
                       direction = "horizontal",
                       barheight = unit(3, units = "mm"),
                       barwidth = unit(70, units = "mm"),
                       draw.ulim = F,
                       title.position = 'top',
                       title.hjust = 0.5,
                       label.hjust = 0.5,
                       frame.colour = "#757575", 
                       ticks.colour = "#757575")) +
  annotation_scale(location = "bl", style = "ticks", line_col = "#212121", text_col = "#212121") +
  annotation_north_arrow(height = unit(0.8, "cm"), width = unit(0.8, "cm"), location = "tr", which_north = "true") +
  labs(x = NULL, y = NULL,
       title = "Burglary offences reported in Trafford",
       subtitle = "August 2018",
       caption = "Source: data.police.uk | @traffordDataLab\n Contains Ordnance Survey data © Crown copyright and database right 2018") +
  coord_sf(datum = NA) +
  theme_void() +
  theme(text = element_text(colour = "#212121"),
        plot.title = element_text(size = 18, face = "bold", colour = "#757575", margin = margin(t = 15), vjust = 4),
        plot.subtitle = element_text(size = 12, face = "bold", colour = "#757575", margin = margin(t = 5), vjust = 4),
        plot.caption = element_text(size = 10, colour = "#212121", margin = margin(b = 15), vjust = -4),
        legend.title = element_text(colour = "#757575"),
        legend.text = element_text(colour = "#757575"),
        legend.position = c(0.02, 0.9), # adjust legend position
        legend.justification = c(0, 0))

# write results
ggsave("GISDaymap.png", dpi = 300, scale = 1)

