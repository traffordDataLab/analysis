# Overlay Trafford schools and Air Quality Management Areas (AQMA)

# --- Required libraries
library(sf) ; library(tidyverse) ; library(ggspatial) ;

# --- Load in the boundary file of Trafford
sf_traff <- st_read("https://www.trafforddatalab.io/spatial_data/local_authority/2016/trafford_local_authority_full_resolution.geojson")

# --- Load in Trafford's AQMA
sf_aqma <- st_read(paste0("https://www.trafforddatalab.io/open_data/AQMA/trafford_aqma.geojson"))

# --- Load in Trafford's schools
sf_schools <- st_read(paste0("https://www.trafforddatalab.io/open_data/schools_and_colleges/trafford_schools_and_colleges.geojson"))

# --- Plot the map
ggplot() +
  # Add in background map tiles
  annotation_map_tile(
    type = "osm",
    zoom = NULL,
    zoomin = 0,
    forcedownload = FALSE,
    cachedir = NULL,
    progress = c("text", "none"),
    quiet = TRUE,
    interpolate = TRUE,
    data = NULL,
    mapping = NULL,
    alpha = 0.5
  ) +  
  # Add in Trafford boundary
  geom_sf(data = sf_traff, fill = "#DDDDCC", alpha = 0, colour = "#212121",  size = 0.5) +
  # Add in AQMA
  geom_sf(data = sf_aqma, fill = "#727C81", alpha = 0.5, colour = "#727C81",  size = 1) +
  # Add in Schools
  geom_sf(data = sf_schools, colour = "#ffffff", fill = "#046dc3", shape = 21, size = 3.5, stroke = 0.5) +
  # Title/attribution
  labs(title = "Proximity of Trafford schools to Air Quality Management Areas (AQMA)",
       subtitle = NULL,
       caption = "Source: Department for Environment Food & Rural Affairs (AQMA 2018), Department for Education (Schools 2019) | @traffordDataLab\nContains Ordnance Survey data © Crown copyright and database right 2020",
       x = NULL, y = NULL) +
  coord_sf(crs = st_crs(4326), datum = NA) +
  theme_void(base_family = "Roboto") +
  theme(plot.margin = unit(c(0.25,0.25,0.25,0.25), "cm"),
        text = element_text(colour = "#212121"),
        plot.title = element_text(size = 16, face = "bold", colour = "#707070", margin = margin(t = 15), vjust = 2),
        plot.caption = element_text(size = 8.75, colour = "#212121"))

# --- Output as a .png
ggsave(paste0("trafford_schools_aqma_proximity.png"), dpi = 300, scale = 1, width = 8, height = 8)