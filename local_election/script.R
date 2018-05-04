## 2018 Local Election results in Trafford ##

# source: http://www.trafford.gov.uk/about-your-council/elections/Local-Election-2018-Results.aspx
# credits: https://drsimonj.svbtle.com/ordering-categories-within-ggplot2-facets

# load R packages  ---------------------------
library(tidyverse) ; library(ggplot2)

# load Lab's ggplot2 theme  ---------------------------
source("https://github.com/traffordDataLab/assets/raw/master/theme/ggplot2/theme_lab.R")

# load data  ---------------------------
df <- read_csv("local_election_results_2018.csv") %>% 
  select(ward, party, votes)

# manipulate data ---------------------------
altrincham <- filter(df, ward == "Altrincham") %>% 
  mutate(party = str_replace(party, "Lberal Democrats", "Liberal Democrat"),
         party = str_replace(party, "Liberal Democrats", "Liberal Democrat")) %>% 
  group_by(ward, party) %>% 
  summarise(votes = sum(votes))

results <- 
  filter(df, ward != "Altrincham") %>% 
  mutate(party = str_replace(party, "Conservatives", "Conservative"),
         party = str_replace(party, "Liberal Democrats", "Liberal Democrat"),
         party = factor(party)) %>% 
  bind_rows(., altrincham) %>% 
  group_by(ward) %>% 
  mutate(total = sum(votes),
         percent = votes * 100 / total) %>% 
  ungroup() %>% 
  arrange(ward, percent) %>%
  mutate(order = row_number())

# create plot ---------------------------
pal <- c("Conservative" = "#0486DD", 
         "Green Party" = "#69B024", 
         "Independent" = "#778799",
         "Labour" = "#DC2520", 
         "Liberal Democrat" = "#FDBC30", 
         "The Liberal Party" =  "#778799",
         "UKIP" = "#6F1579")

#p <- 
  ggplot(data = results, aes(x = order, y = percent, fill = party)) + 
  geom_col(alpha = 0.8) + 
# geom_text(aes(label = scales::comma(votes)), colour = "#212121", size = 2, nudge_y = 3) +
  scale_x_continuous(breaks = results$order, labels = results$party, expand = c(0,0)) +
  scale_y_continuous(breaks = c(0, 25, 50, 75, 100), labels = function(y){ paste0(y, "%") }, expand = c(0, 0)) +
  scale_fill_manual(values = pal) +
  coord_flip() +
  facet_wrap(~ward, nrow = 7, scales = "free_y") +
  labs(x = NULL, y = "\nProportion of those who voted for a candidate",
       title = "Results of the 2018 Local Elections in Trafford",
       subtitle = "* 2 seats were contested in Altrincham ward\n and both were won by Green candidates", 
       caption = "Source: Trafford Council  |  @traffordDataLab") +
  theme_lab() +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        panel.spacing = unit(1.5, "lines"),
        panel.grid.major.y = element_blank(),
        plot.title = element_text(size = 20, face = "bold", vjust = 13, hjust = 0.5),
        plot.subtitle = element_text(size = 10),
        strip.text.x = element_text(size = 12, face = "bold", angle = 0, hjust = 0, vjust = 1),
        legend.position = "none")

# save plot ---------------------------
ggsave(p, file = "local_elections_2018.png", height = 10, width = 14, dpi = 400)
