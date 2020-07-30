# Isotype pictogram #

library(tidyverse) ; library(waffle) ; library(hrbrthemes)

df <- tibble(
  parts = LETTERS[1:8],
  percent = c(15,26,24,17,7,5,2,3)
)

ggplot(df, aes(label = parts, values = percent)) +
  geom_pictogram(size = 6, n_rows = 10, colour = "#458698",  flip = FALSE, make_proportional = FALSE) +
  scale_label_pictogram(name = NULL, values = rep("home", 8), labels = LETTERS[1:8]) +
  labs(x = NULL, y = NULL,
       title = "Properties by council tax band",
       subtitle = paste0("<span style = 'color:#757575;'>Trafford, percentage built between 2010 and 2019	</span>"),
       caption = "Source: Valuation Office Agency",
       tag = "Each house represents 1%") +
  theme_minimal(base_size = 16) +
  theme(plot.margin = unit(rep(0.5, 4), "cm"),
        panel.spacing = unit(0.1, "lines"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.title.position = "plot",
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_markdown(size = 12, margin = margin(b = 20)),
        plot.caption = element_text(size = 10, colour = "grey60"),
        strip.text = element_text(size = 12, face = "bold", hjust = 0.1),
        plot.tag.position = c(0.02, 0.05),
        plot.tag = element_text(size = 9, colour = "#757575", hjust = 0),
        axis.text = element_blank(),
        legend.position = "none") +
  coord_equal() +
  facet_wrap(~parts, nrow = 1)

ggsave("pictogram.png", scale = 0.6, dpi = 300)
