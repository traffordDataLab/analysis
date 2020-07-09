# Population pyramid #

# Source: Mid-year population estimates, ONS
# URL: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(ggpol) ; library(ggtext)

df <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=E08000009&date=latest&gender=1,2&c_age=101...191&measures=20100&select=date_name,geography_name,geography_code,gender_name,c_age_name,measures_name,obs_value,obs_status_name") %>% 
  select(gender = GENDER_NAME, age = C_AGE_NAME, n = OBS_VALUE) %>% 
  mutate(gender = factor(gender, levels = c("Male", "Female")),
         age = parse_number(age))

# Single year of age
single_year <- df %>% 
  mutate(n = case_when(gender == "Male" ~ n * -1, TRUE ~ n))

ggplot(single_year, aes(x = age, y = n, fill = gender)) +
  geom_col(colour = "#FFFFFF", width = 1) + 
  scale_fill_manual(values = c("#15607A", "#96BA5C"), labels = c("Female", "Male")) +
  facet_share(~gender, dir = "h", scales = "free", reverse_num = TRUE) +
  scale_x_continuous(expand = c(0.005, 0.005), breaks = seq(10,90,10)) +
  coord_flip() +
  labs(x = NULL, y = NULL, 
       title = "Age profile of Trafford residents in mid-2019",
       subtitle = paste0("<span style = 'color:#757575;'>Number of residents by year of age</span>"),
       caption = "Source: Office for National Statistics",
       tag = "Those aged 90 or more\nare grouped together") +
  theme(plot.margin = unit(rep(0.5, 4), "cm"),
        panel.spacing = unit(-0.8, "lines"),
        panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        strip.background = element_blank(),
        axis.ticks = element_line(colour = NA),
        plot.title.position = "plot",
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_markdown(size = 12, margin = margin(b = 20)),
        plot.caption = element_text(colour = "grey60", margin = margin(t = 20, b = -10)),
        plot.tag.position = c(0.53, 0.9),
        plot.tag = element_text(size = 8, colour = "#757575", hjust = 0),
        strip.text = element_text(size = 11, face = "bold", vjust = 2),
        axis.text = element_text(size = 10),
        legend.position = "none")

ggsave("single_year.png", scale = 1, dpi = 300)

# 5-year age bands
five_year <- df %>% 
  mutate(ageband = cut(age,
                       breaks = c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,120),
                       labels = c("0-4","5-9","10-14","15-19","20-24","25-29","30-34","35-39",
                                  "40-44","45-49","50-54","55-59","60-64","65-69","70-74",
                                  "75-79","80-84","85-89","90+"),
                       right = FALSE)) %>% 
  group_by(gender, ageband) %>% 
  summarise(n = sum(n)) %>% 
  mutate(n = case_when(gender == "Male" ~ n * -1, TRUE ~ n))

ggplot(five_year, aes(x = ageband, y = n, fill = gender)) +
  geom_col() + 
  scale_fill_manual(values = c("#15607A", "#96BA5C"), labels = c("Female", "Male")) +
  facet_share(~gender, dir = "h", scales = "free", reverse_num = TRUE) +
  coord_flip() +
  labs(x = NULL, y = NULL, 
       title = "Age profile of Trafford residents in mid-2019",
       subtitle = paste0("<span style = 'color:#757575;'>Number of residents by 5-year age band</span>"),
       caption = "Source: Office for National Statistics") +
  theme(plot.margin = unit(rep(0.5, 4), "cm"),
        panel.spacing = unit(-0.8, "lines"),
        panel.background = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        strip.background = element_blank(),
        axis.ticks = element_line(colour = NA),
        plot.title.position = "plot",
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_markdown(size = 12, margin = margin(b = 20)),
        plot.caption = element_text(colour = "grey60", margin = margin(t = 20, b = -10)),
        strip.text = element_text(size = 11, face = "bold"),
        axis.text = element_text(size = 10),
        legend.position = "none")

ggsave("five_year.png", scale = 1, dpi = 300)
  
  