# Baby names in Greater Manchester, 2017 #

# Source: Office for National Statistics 
# URL: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/articles/babynameswhereyoulivecouldshapewhatyoucallyourbaby/2018-09-21
# Licence: Open Government Licence

library(tidyverse) ; library(httr) ; library(readxl) ; library(tidytext)

df <- tempfile(fileext = ".xlsx")
GET(url = "https://www.ons.gov.uk/visualisations/dvc526/downloadthedata/mapdata.xlsx",
    write_disk(df))

# baby girls' names
girls_names <- read_xlsx(df, sheet = 3) %>% 
  filter(AREACD %in% c("E08000001", "E08000002", "E08000003", "E08000004",
                       "E08000005", "E08000006",  "E08000007", "E08000008",
                       "E08000009", "E08000010")) %>% 
  select(-Total) %>% 
  rename(area_code = AREACD, area_name = AREANM) %>% 
  gather(name, n, -area_code, -area_name) %>% 
  drop_na() %>% 
  mutate(gender = "Female") %>% 
  arrange(desc(n)) %>%
  group_by(area_name) %>%
  slice(1:10) %>% 
  ungroup %>%
  mutate(area_name = as.factor(area_name),
         name = reorder_within(name, n, area_name)) 

ggplot(girls_names, aes(name, n, fill = area_name)) +
  geom_col(show.legend = FALSE) +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_brewer(palette = "Set3") + 
  facet_wrap(~area_name, scales = "free_y", nrow = 2) +
  geom_hline(yintercept = 3, size = 1, colour = "#000000") +
  coord_flip(ylim = c(3, max(girls_names$n))) +
  scale_x_reordered() +
  labs(y = "Number of baby girls",
       x = NULL,
       title = "Top 10 baby girls’ names in Greater Manchester, 2017",
       subtitle = "Names with counts less than 3 are redacted",
       caption = "Source: Office for National Statistics | @traffordDataLab") +
  theme_minimal(base_family = "Poppins") +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "cm"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(colour = "#212121", size = 16, vjust = 2, hjust = 0.01),
    plot.subtitle = element_text(colour = "#212121", size = 10, vjust = 2, hjust = 0.01),
    plot.caption = element_text(size = 9, colour = "#757575", hjust = 1, margin = margin(t = 15)),
    strip.text = element_text(colour = "#212121", size = 11, hjust = 0.01),
    axis.title.x = element_text(colour = "#212121", size = 10, hjust = 1, margin = margin(t = 10)),
    axis.text.x = element_text(colour = "#212121", size = 9),
    axis.text.y = element_text(colour = "#212121", size = 9)
  ) 

ggsave("girls_names.png", width = 13, height = 9, dpi = 300)

# baby boys' names
boys_names <- read_xlsx(df, sheet = 1) %>% 
  filter(AREACD %in% c("E08000001", "E08000002", "E08000003", "E08000004",
                       "E08000005", "E08000006",  "E08000007", "E08000008",
                       "E08000009", "E08000010")) %>% 
  select(-Total) %>% 
  rename(area_code = AREACD, area_name = AREANM) %>% 
  gather(name, n, -area_code, -area_name) %>% 
  drop_na() %>% 
  mutate(gender = "Male")  %>% 
  arrange(desc(n)) %>%
  group_by(area_name) %>%
  slice(1:10) %>% 
  ungroup %>%
  mutate(area_name = as.factor(area_name),
         name = reorder_within(name, n, area_name)) 

ggplot(boys_names, aes(name, n, fill = area_name)) +
  geom_col(show.legend = FALSE) +
  scale_y_continuous(expand = c(0,0)) +
  scale_fill_brewer(palette = "Set3") + 
  facet_wrap(~area_name, scales = "free_y", nrow = 2) +
  geom_hline(yintercept = 3, size = 1, colour = "#000000") +
  coord_flip(ylim = c(3, max(boys_names$n))) +
  scale_x_reordered() +
  labs(y = "Number of baby boys",
       x = NULL,
       title = "Top 10 baby boys’ names in Greater Manchester, 2017",
       subtitle = "Names with counts less than 3 are redacted",
       caption = "Source: Office for National Statistics | @traffordDataLab") +
  theme_minimal(base_family = "Poppins") +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "cm"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(colour = "#212121", size = 16, vjust = 2, hjust = 0.01),
    plot.subtitle = element_text(colour = "#212121", size = 10, vjust = 2, hjust = 0.01),
    plot.caption = element_text(size = 9, colour = "#757575", hjust = 1, margin = margin(t = 15)),
    strip.text = element_text(colour = "#212121", size = 11, hjust = 0.01),
    axis.title.x = element_text(colour = "#212121", size = 10, hjust = 1, margin = margin(t = 10)),
    axis.text.x = element_text(colour = "#212121", size = 9),
    axis.text.y = element_text(colour = "#212121", size = 9)
  ) 

ggsave("boys_names.png", width = 13, height = 9, dpi = 300)