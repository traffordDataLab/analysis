# Visualisation of local election turnout by ward

# Required packages
library(tidyverse) ; library(ggrepel) ; library(svglite)


# Load in the data and create a label variable to display the latest and highest turnout percentage
df_turnout <- read_csv("data/local_election_turnout.csv") %>%
  mutate(turnout_label = ifelse(election_year == max(election_year), str_c(sprintf("%0.1f", as.numeric(turnout)), "%"), "")) %>%
  group_by(ward_code) %>%
  mutate(turnout_label = ifelse(turnout == max(turnout), str_c(sprintf("%0.1f", as.numeric(turnout)), "%"), turnout_label),
         max_turnout = ifelse(turnout == max(turnout), TRUE, FALSE))


# Plot the data
ggplot(df_turnout, aes(x = election_year, y = turnout, label = turnout_label)) + 
  facet_wrap(ward_name~., nrow = 7, scales = "fixed") + 
  scale_x_continuous(breaks = c(2016, 2018, 2019, 2021, 2022), labels = c("2016", "2018", "2019", "2021", "2022")) +
  scale_y_continuous(limits = c(0, 60), labels = function(y){ paste0(y, "%") }) +
  geom_line(col = "#dddddd") +
  geom_point(size = if_else(df_turnout$max_turnout == TRUE, 1.5, 0.5),
             col = if_else(df_turnout$max_turnout == TRUE, "#212121", "#999999")) +
  geom_label_repel(size = if_else(df_turnout$max_turnout == TRUE, 2.75, 3),
                   fg = if_else(df_turnout$max_turnout == TRUE, "#ffffff", "#212121"),
                   bg = if_else(df_turnout$max_turnout == TRUE, "#212121", as.character(NA)),
                   label.size = if_else(df_turnout$max_turnout == TRUE, 0.25, 0),
                   label.padding = 0.15,
                   nudge_y = -19,
                   point.size = NA,
                   segment.colour = NA) +
  labs(x = NULL, y = NULL,
       title = "Turnout Percentage by Ward in Trafford Local Elections 2016 - 2022",
       subtitle = "Latest turnout and highest turnout within the date range indicated (highest in bold)", 
       caption = "Source: Trafford Council  |  @traffordDataLab") +
  theme_minimal() + 
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(linetype = "dotted"),
        axis.title = element_blank(),
        axis.ticks.x.bottom = element_line(colour = "#dddddd"),
        plot.margin = unit(c(0.5, 0.75, 0.5, 0.75), "cm"),
        panel.spacing.x = unit(3, "lines"),
        panel.spacing.y = unit(1, "lines"),
        plot.title = element_text(size = 14, face = "bold", color = "#707070"),
        plot.subtitle = element_text(size = 10, face = "italic", color = "#707070"),
        plot.caption = element_text(size = 7.5, hjust = 1.008, color = "#707070"),
        plot.title.position = "plot")


# Save the plot
ggsave("images/ward_turnout_2016-2022.png", dpi = 320, scale = 1, width = 7.81, height = 7.17, bg = "#ffffff")
ggsave("images/ward_turnout_2016-2022.svg", dpi = 320, scale = 1, width = 7.81, height = 7.17)
