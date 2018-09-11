## Boundary map ##

# load libraries
library(tidyverse) ; library(sf) ; library(ggplot2) ; library(ggthemes) ; library(ggrepel) ; library(ggspatial)

# load geospatial data
wards <- st_read("https://www.traffordDataLab.io/spatial_data/ward/2017/trafford_ward_generalised.geojson")
localities <- st_read("https://www.traffordDataLab.io/spatial_data/council_defined/trafford_localities.geojson")

# plot map
ggplot() +
  geom_sf(data = wards, fill = "#DDDDCC", alpha = 1, colour = "#ffffff") +
  geom_sf(data = localities, fill = "transparent", colour = "#757575", size = 1) +
  geom_label_repel(data = wards, mapping = aes(x = lon, y = lat, label = area_name), size = 2) +
  geom_text_repel(data = localities, mapping = aes(x = lon, y = lat, label = area_code), colour = "#757575", fontface = "bold", size = 4) +
  annotation_scale(location = "bl", style = "ticks") +
  annotation_north_arrow(height = unit(0.8, "cm"), width = unit(0.8, "cm"), location = "tr", which_north = "true") +
  labs(title = "Trafford's localities and wards",
       subtitle = NULL,
       caption = "Contains OS data © Crown copyright and database right (2018) | @traffordDataLab",
       x = NULL, y = NULL) +
  theme_map() +
  theme(plot.margin = unit(c(1,1,2,1), "cm"),
        plot.title = element_text(size = 16, hjust = 0.5)) +
  coord_sf(crs = st_crs(4326), datum = NA) 

ggsave(file = "boundary_map.png", dpi = 300, scale = 1)


