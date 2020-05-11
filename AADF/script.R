# Average annual daily flow (AADF) #

# Source: Department for Transport
# URL: https://roadtraffic.dft.gov.uk/local-authorities/91
# Licence: OGL 3.0

library(tidyverse) ; library(sf) ; library(leaflet) ; library(htmltools) ; library(nord) ; library(scales)

sf <- read_csv("https://dft-statistics.s3.amazonaws.com/road-traffic/downloads/aadf/local_authority_id/dft_aadf_local_authority_id_91.csv") %>% 
  filter(!is.na(easting)) %>% 
  st_as_sf(crs = 27700, coords = c("easting", "northing")) %>% 
  st_transform(4326)

# find nearest count point(s)
temp <- filter(sf, year == "2018") %>% 
  mutate(popup = str_c("<strong>Count point ID: </strong>", count_point_id, "<br/>",
                       "<strong>Road name: </strong>", road_name) %>%
           map(HTML))

leaflet() %>% 
  addProviderTiles(providers$CartoDB.Positron,
                   options = tileOptions(minZoom = 9, maxZoom = 17)) %>%
  setView(lng = -2.398630, lat= 53.432013, zoom = 14) %>% 
  addMarkers(data = temp, popup = ~popup) %>% 
  addControl("<strong>Road traffic count points in Trafford (2018)</strong><br /><em>Source: Department for Transport</em>",
             position = "topright")

# filter and recode 
df <- sf %>% 
  st_set_geometry(NULL) %>% 
  mutate(road = paste0(road_name, " (", start_junction_road_name, "-", end_junction_road_name, ")")) %>% 
  select(count_point_id, year, road,
         cars_and_taxis, lgvs, all_hgvs, 
         two_wheeled_motor_vehicles, buses_and_coaches, all_motor_vehicles) %>% 
  pivot_longer(-c(count_point_id, year, road), names_to = "mode", values_to = "n") %>% 
  mutate(
    mode = case_when(
      mode == "cars_and_taxis" ~ "Car",
      mode == "two_wheeled_motor_vehicles" ~ "Powered 2 Wheeler",
      mode == "lgvs" ~ "LGV",
      mode == "all_hgvs" ~ "HGV",
      mode == "buses_and_coaches" ~ "Bus and coach",
      mode == "all_motor_vehicles" ~ "All motor vehicles"))

# plot
vehicle_plot <- function (x) { 
  
  temp <- filter(df, count_point_id == x, 
                 mode != "All motor vehicles")
  
  ggplot(temp, aes(x = year, y = n)) +
  geom_col(aes(fill = mode), show.legend = FALSE) +
  scale_fill_nord("algoma_forest") +
  scale_y_continuous(expand = c(0.005, 0.005), limits = c(0,NA), labels = comma) +
  labs(x = NULL, y = "Number of vehicles",
       title = paste("Average annual daily flow on", unique(temp$road)), 
       subtitle = paste(min(temp$year), "-", max(temp$year)),
       caption = "Source: Department for Transport") +
  facet_wrap(~mode, nrow = 1) +
  theme_minimal(base_size = 14) +
  theme(plot.margin = unit(rep(0.5, 4), "cm"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 12, margin = margin(b = 20)),
        plot.caption = element_text(colour = "grey60", margin = margin(t = 30, b = -10)),
        plot.title.position = "plot",
        axis.title.y = element_text(hjust = 0),
        axis.text.x = element_text(angle = 90),
        strip.text = element_text(face = "bold", hjust = 0))
  
  ggsave(paste(unique(temp$count_point_id), ".png"), dpi = 300, scale = 1)
}

# "7760", "74005"
vehicle_plot("74005")
