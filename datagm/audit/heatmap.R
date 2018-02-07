## Querying DataGM

# load necessary R packages and Lab's ggplot2 theme ---------------------------
library(ckanr) ; library(tidyverse) ; library(stringr) ; library(zoo) ; library(ggplot2) ; library(viridis)
source("https://trafforddatalab.github.io/assets/theme/ggplot2/theme_lab.R")

# set the URL of the CKAN instance ---------------------------
ckanr_setup(url = "https://www.datagm.org.uk/")

# list organisations and their package count (descending order) ---------------------------
organization_list(as = "table") %>%
  select(title, package_count) %>% 
  arrange(desc(package_count))

# list packages (containing resources aka datasets) ---------------------------
p <- package_search(q = '*:*',  rows = 1000,  as = 'table')$results

# tidy the dataframe ---------------------------
df <- data.frame(
  name = p$title,
  id = p$id,
  type = p$type,
  organisation = factor(p$organization$title),
  author = p$author,
  author_email = p$author_email,
  maintainer = p$maintainer,
  maintainer_email = p$maintainer_email,
  notes = p$notes,
  updated = as.Date(str_sub(p$metadata_modified, 1, 10), format = "%Y-%m-%d"),
  stringsAsFactors = FALSE
)
write_csv(df, "resources.csv")

# monthly activity by organisation ---------------------------
activity <- df %>% 
  filter(!is.na(organisation)) %>% # filter NAs
  select(name, organisation, updated) %>% 
  mutate(month_year = as.Date(as.yearmon(updated, "%m/%Y"))) %>% 
  group_by(month_year, organisation) %>% 
  summarise(n = n()) %>% 
  spread(organisation, n)

# create a sequence of months ---------------------------
periods <- data_frame(month_year = seq(as.Date('2013-01-01'), as.Date('2018-01-01'), by = "1 month"))

# merge actvity log with periods ---------------------------
activity_log <- left_join(periods, activity, by = "month_year") %>% 
  gather(organisation, n, -month_year) 

## plot a heatmap ---------------------------
ggplot(activity_log, aes(x = month_year, y = organisation, fill = n)) + 
  geom_tile(color = "white", size = 0.4) + 
  scale_fill_viridis_c(name = "Update frequency", 
                       direction = -1, 
                       na.value = "grey93", 
                       limits = c(0, max(activity_periods$n)),
                       guide = guide_legend(keyheight = unit(3, units = "mm"), 
                                            keywidth=unit(12, units = "mm"), 
                                            label.position = "bottom", 
                                            title.position = 'top', 
                                            nrow=1)) +
  labs(x = "", y = "", fill = "",
       title = "Activity on DataGM, 2013-2018",
       subtitle = "Metadata updates by month") +
  facet_grid(organisation ~ ., scales = "free") +
  scale_x_date(date_labels = "'%y", date_breaks = "1 year", expand = c(0,0)) +
  theme_lab() +
  theme(panel.grid = element_blank(), 
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9),
        legend.position = c(0.25, -0.12),
        strip.text = element_blank(),
        plot.title = element_text(face = "bold"),
        plot.margin = unit(c(1,1,3,1), "cm"))

# save plot ---------------------------
ggsave(file = "activity_log.svg", width = 10, height = 8)
ggsave(file = "activity_log.png", width = 10, height = 8)
