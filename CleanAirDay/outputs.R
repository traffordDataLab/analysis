library(tidyverse) ; library(scales)

# Diesel cars
diesel <- read_csv("data/diesel_cars.csv") %>% 
  mutate(pct = (n/total_cars))

diesel %>% # proportion in Greater Manchester at end of 2018
  filter(period == "2018-01-01") %>% 
  summarise(pct = (sum(n)/sum(total_cars))*100)
  
ggplot(diesel, aes(x = period, y = pct, colour = area_name, fill = area_name)) +
  geom_line(size = 1.5) +
  scale_colour_manual(values = ifelse(diesel$area_name == "Trafford", "#fc6721", "#d9d9d9")) +
  scale_fill_manual(values = ifelse(diesel$area_name == "Trafford", "#fc6721", "#d9d9d9")) +
  scale_y_continuous(limits = c(0, NA), labels = percent_format(accuracy = 1)) +
  labs(title = "Diesel cars as a proportion of all licensed cars",
       subtitle = "Greater Manchester, 2009-2018",
       caption = "Data: DfT and DVLA | @traffordDataLab",
       x = NULL,
       y = "Percentage") +
  facet_wrap(~area_name, nrow = 2) +
  theme_minimal(base_family = "Poppins") +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "cm"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 20, colour = "#212121", vjust = 5),
    plot.subtitle = element_text(size = 12, colour = "#212121", vjust = 4),
    plot.caption = element_text(color = "grey50", size = 8, hjust = 1, margin = margin(t = 15)),
    axis.title.x = element_text(size = 9, hjust = 1, margin = margin(t = 10)),
    axis.title.y = element_text(size = 9, angle = 90, hjust = 1, margin = margin(r = 10)),
    axis.text.x = element_text(angle = 90, hjust = 1, margin = margin(t = 0)),
    legend.position = "none"
  )

ggsave("outputs/diesel_cars.png", dpi = 300)

# Electric vehicles
ev <- read_csv("data/electric_vehicles.csv")

ev %>% # count in Greater Manchester at end 0f 2018
  group_by(period) %>% 
  summarise(total = (sum(n, na.rm = TRUE))) %>% 
  filter(period == "2018-10-01")

ggplot(ev, aes(x = period, y = n, colour = area_name, fill = area_name)) +
  geom_line(size = 1.5) +
  scale_colour_manual(values = ifelse(ev$area_name == "Trafford", "#fc6721", "#d9d9d9")) +
  scale_fill_manual(values = ifelse(ev$area_name == "Trafford", "#fc6721", "#d9d9d9")) +
  scale_y_continuous(limits = c(0, NA), labels = comma) +
  labs(title = "Number of licensed electric vehicles",
       subtitle = "Greater Manchester, 2011-2018",
       caption = "Data: DfT and DVLA | @traffordDataLab",
       x = NULL,
       y = "Count") +
  facet_wrap(~area_name, nrow = 2) +
  theme_minimal(base_family = "Poppins") +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "cm"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(size = 20, colour = "#212121", vjust = 5),
    plot.subtitle = element_text(size = 12, colour = "#212121", vjust = 4),
    plot.caption = element_text(color = "grey50", size = 8, hjust = 1, margin = margin(t = 15)),
    axis.title.x = element_text(size = 9, hjust = 1, margin = margin(t = 10)),
    axis.title.y = element_text(size = 9, angle = 90, hjust = 1, margin = margin(r = 10)),
    axis.text.x = element_text(angle = 90, hjust = 1, margin = margin(t = 0)),
    legend.position = "none"
  )

ggsave("outputs/electric_vehicles.png", dpi = 300)

