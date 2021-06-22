# Parliament chart visualisation showing the political control of Trafford

# Required packages
library(tidyverse) ; library(ggpol) ; library(svglite)

# Load the source data
political_control <- read_csv("data/political_control_2021.csv")

parliament_chart <- political_control %>%
  count(councillor_party) %>%
  mutate(colours = case_when(
    councillor_party == "Green Party" ~ "#6ab023",
    councillor_party == "Liberal Democrats" ~ "#fdbb30",
    councillor_party == "Conservative Party" ~ "#0087dc",
    TRUE ~ "#dc241f"
  )) %>%
  select(party = councillor_party,
         seats = n,
         colours) %>%
  arrange(seats)

ggplot(parliament_chart) + 
  geom_parliament(aes(seats = seats, fill = party), colour = "#ffffff") + 
  scale_fill_manual(values = parliament_chart$colours, labels = parliament_chart$party,
                    guide = guide_legend(reverse = TRUE)) +
  labs(title = "Trafford Council Seats by Party",
       subtitle = "Following local election: 06 May 2021",
       caption = "Source: trafford.gov.uk | @traffordDataLab",
       fill = NULL) +
  coord_fixed() + 
  theme_void() +
  theme(plot.margin = unit(rep(0.1, 4), "cm"),
        plot.title = element_text(size = 14, face = "bold", hjust = 0.5, color = "#707070"),
        plot.subtitle = element_text(size = 10, hjust = 0.5, color = "#212121"),
        plot.caption = element_text(size = 7, color = "#707070", hjust = 0.96, margin = margin(t = 10, b = 5)),
        legend.position = "bottom")

ggsave("images/seats_by_party_parliament_chart_2021.png", dpi = 320, scale = 1, width = 5.35, height = 4)
ggsave("images/seats_by_party_parliament_chart_2021.svg", dpi = 320, scale = 1, width = 5.35, height = 4)
