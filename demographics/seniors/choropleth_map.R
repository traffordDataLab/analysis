## Choropleth map ##

# load libraries
library(tidyverse) ; library(readxl) ; library(sf) ; library(ggplot2) ; library(classInt) ; library(ggspatial)

# load geospatial data
wards <- st_read("https://www.traffordDataLab.io/spatial_data/ward/2017/trafford_ward_generalised.geojson")
localities <- st_read("https://www.traffordDataLab.io/spatial_data/council_defined/trafford_localities.geojson")
towns <- st_read("https://www.traffordDataLab.io/spatial_data/town_centres/trafford_town_centres.geojson")

# load tabular data
raw <- read_xlsx("data.xlsx", sheet = 1, range = "A3:F24")

# select and rename variables
df <- raw %>% 
  select(area_code = `Ward code`,
         percent = `Aged 65+ %`) %>% 
  mutate(percent = round(percent*100, 1))

# join tabular data to geospatial data
sf <- left_join(wards, df, by = "area_code")

# set class intervals: natural breaks
classes <- classIntervals(sf$percent, n = 5, style = "jenks")

# assign class breaks to spatial data and format labels
sf <- sf %>%
  mutate(percent_class = factor(cut(percent, classes$brks, include.lowest = T),
         labels = c(
           paste0(classes$brks[1], "% - ", classes$brks[2], "%"),
           paste0(classes$brks[2], "% - ", classes$brks[3], "%"),
           paste0(classes$brks[3], "% - ", classes$brks[4], "%"),
           paste0(classes$brks[4], "% - ", classes$brks[5], "%"),
           paste0(classes$brks[5], "% - ", classes$brks[6], "%")
           )))

# plot map
ggplot() +
  geom_sf(data = sf, aes(fill = factor(percent_class)), alpha = 0.8, colour = "#ffffff", size = 0.4) +
  geom_sf(data = localities, fill = "transparent", colour = "#757575", size = 1) +
  geom_sf(data = towns, shape = 21, color = "#ffffff", fill = "#de2d26", alpha = 1, size = 2.5) +
  geom_text(data = towns, aes(lon, lat, label = name), color = "#212121", fontface = "bold", size = 3, nudge_y = -0.0025) +
  geom_text(data = localities, aes(x = lon, y = lat, label = area_name), colour = "#000000", fontface = "bold", size = 4, nudge_y = 0.003) +
  scale_fill_brewer(palette = "Blues",
                    name = "Percent aged 65+") +
  labs(x = NULL, y = NULL,
       title = "Ward residents aged 65 years and over, mid-2016",
       subtitle = "Source: Office for National Statistics",
       caption = "Contains OS data © Crown copyright and database right (2018) | @traffordDataLab") +
  theme(plot.title = element_text(size = 16, hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.background = element_blank(),
        legend.position = c(0.2, 0.09),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 8)) +
  coord_sf(datum = NA)

ggsave(file = "choropleth_map.png", dpi = 300, scale = 1)
