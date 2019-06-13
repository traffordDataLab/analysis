## Bird sightings at Carrington Moss over the last 30 days ##

# Source: https://ebird.org/hotspot/L3267897

library(rebird) ; library(tidyverse) ; library(sf) ; library(osmdata) ; library(ggrepel)

bdy <- getbb("Trafford", format_out = "sf_polygon")
centroids <- st_centroid(bdy) %>% st_coordinates() %>%  as.data.frame()
distance <- bdy %>% st_cast("POINT") %>% st_distance() %>% max() * 0.5

hotspots <- ebirdgeo(key = "#",
                     species = NULL,
                     lat = centroids$Y,
                     lng = centroids$X, 
                     dist = as.numeric(units::set_units(distance, "km")),
                     back = 30) %>% 
  st_as_sf(coords = c("lng", "lat"), crs = 4326)  %>% 
  st_intersection(bdy) %>% 
  distinct(locId, locName) %>% 
  st_set_geometry(value = NULL) %>% 
  pull(locId)

birds <- ebirdregion(key = "6hanhdiola5p", loc = "L3267897", back = 30) %>% 
  as_tibble() %>%
  mutate(obsDt = as.Date(obsDt, format = "%Y-%m-%d %H:%M")) %>%
  group_by(comName) %>%
  summarise(total = sum(howMany)) %>% 
  arrange(total) %>% 
  mutate(comName = factor(comName, levels = comName))

birds_sf <- ebirdregion(key = "#", loc = paste(hotspots, collapse = ", "), back = 30) %>% 
  as_tibble() %>%
  group_by(locName, lat, lng) %>%
  summarise(n = sum(howMany)) %>% 
  st_as_sf(coords = c("lng", "lat"), crs = 4326) %>% 
  mutate(lon = map_dbl(geometry, ~st_coordinates(.x)[[1]]),
         lat = map_dbl(geometry, ~st_coordinates(.x)[[2]]))

chart <- ggplot(birds, aes(comName, total)) +
  geom_col(width = 0.7, fill = "#1AA0E0", alpha = 0.8) +
  geom_text(aes(label = total), colour = "#212121", size = 3.3, hjust = 0, nudge_y = 0.15) +
  scale_y_continuous(expand = c(0, 0), limits = c(0,63)) +
  coord_flip() +
  labs(title = "Birds sighted at Carrington Moss, Trafford over the last 30 days",
       subtitle = paste0("up to ", format(Sys.time(), "%d %B %Y")),
       caption = "Data: ebird.org | traffordDataLab.io",
       x = NULL, y = NULL, fill = NULL) +
  theme_minimal(base_family = "Poppins") +
  theme(plot.margin = unit(rep(1, 4), "cm"),
        plot.background = element_rect(fill = "#FFFFFF", colour = NA),
        panel.background = element_rect(fill = "#FFFFFF", colour = NA),
        panel.grid = element_blank(),
        plot.title = element_text(size = 20, colour = "#212121"),
        plot.subtitle = element_text(colour = "#212121"),
        plot.caption = element_text(size = 9, color = "#212121", margin = margin(t = 20, unit = "pt")),
        axis.title.x = element_text(color = "#212121", face = "italic", hjust = 0),
        axis.text.x = element_blank(),
        axis.text.y = element_text(size = 10))
chart 

map <- ggplot() +
  geom_sf(data = bdy, fill = "#bdbdbd", colour = "#999999") +
  geom_sf(data = birds_sf,
          aes(size = n), 
          shape = 21, 
          fill = ifelse(birds_sf$locName == "Carrington Moss", "#1AA0E0", "transparent"),
          colour = "#444444", show.legend = "point") +
  geom_text_repel(data = filter(birds_sf, locName == "Carrington Moss"), 
                  aes(x = lon, y = lat, label = "Carrington Moss"), 
                  size = 3, colour = "#212121", segment.color = "#212121", nudge_y = 0.01) +
  labs(x = NULL, y = NULL, title = NULL, subtitle = NULL,
       size = "Sightings in Trafford") +
  coord_sf(crs = st_crs(4326), datum = NA) +
  theme_void(base_family = "Poppins") +
  theme(legend.position = "bottom",
        legend.title = element_text(colour = "#212121"),
        legend.text = element_text(colour = "#212121"))
map

chart + annotation_custom(ggplotGrob(map),
                          xmin = 0, xmax = 50, 
                          ymin = 12, ymax = 60)

ggsave("eBird_sightings.png", width = 13, height = 9, dpi = 300)
