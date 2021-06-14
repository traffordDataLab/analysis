# Visualisation of local election turnout by ward

# Required packages
library(tidyverse) ; library(ggrepel)

# Load in the data
turnout_df <- read_csv("data/local_election_turnout.csv")

# calculate the max and latest year points
max_turnout <- group_by(turnout_df, ward_code) %>% slice(which.max(turnout))
latest_year <- turnout_df %>% filter(election_year == max(election_year))

# Plot the data
ggplot(turnout_df, aes(x = election_year, y = turnout, label = str_c(sprintf("%0.1f", round(turnout, digits = 1)), "%"))) + 
  facet_wrap(ward_name~., nrow = 7, scales = "fixed") + 
  scale_x_continuous(breaks = c(2016, 2018, 2019, 2021), labels = c("2016", "2018", "2019", "2021")) +
  scale_y_continuous(labels = function(y){ paste0(y, "%") }) +
  geom_line(col = "#dddddd") +
  geom_point(size = 0.5, col = "#999999") +
  geom_point(data = max_turnout, size = 1, col = '#212121') +
  geom_text_repel(data = latest_year, nudge_y = 2, size = 3.5, col = "#555555") +
  geom_text_repel(data = max_turnout, nudge_y = 2, size = 3.5, col = "#212121") +
  labs(x = NULL, y = NULL,
       title = "Ward Turnout in Trafford Local Elections 2016-2021",
       subtitle = "(highest turnout within the date range indicated in bold)", 
       caption = "Source: Trafford Council  |  @traffordDataLab") +
  theme_minimal() + 
  theme(panel.grid = element_blank(),
        axis.title = element_blank(),
        plot.margin = unit(c(0.5, 0.75, 0.5, 0.75), "cm"),
        panel.spacing.x = unit(3, "lines"),
        panel.spacing.y = unit(1, "lines"),
        plot.title = element_text(size = 20, face = "bold"),
        plot.subtitle = element_text(size = 10, face = "italic"),
        plot.title.position = "plot")

ggsave("images/ward_turnout_2016-2021.png", dpi = 320, scale = 1, width = 8.81, height = 8.17)
