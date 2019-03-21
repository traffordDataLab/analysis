# Long term vacant dwellings #
# Source: https://www.gov.uk/government/statistical-data-sets/live-tables-on-dwelling-stock-including-vacants

library(tidyverse) ; library(httr) ; library(readxl) ; library(ggplot2)
source("https://github.com/traffordDataLab/assets/raw/master/theme/ggplot2/theme_lab.R")

# vacant dwellings by local authority district
tmp <- tempfile(fileext = ".xls")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/784593/LT_615.xls",
          write_disk(tmp))
vacant <- read_xls(tmp, sheet = 3, range = "F381:U390", col_names = c("area_name", seq(2004, 2018, 1))) %>% 
  gather(year, vacant, -area_name) %>% 
  mutate(year = as.Date(paste(year, "-01-01", sep = "", format = '%Y-%b-%d'))) %>% 
  filter(year > "2004-01-01" , year < "2018-01-01") 
      
# dwellings by local authority district
tmp <- tempfile(fileext = ".xls")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/710193/LT_125.xls",
          write_disk(tmp))
dwellings <- read_excel(tmp, sheet = 1, range = "D70:U79", col_names = c("area_name", seq(2001, 2017, 1))) %>% 
  gather(year, dwellings, -area_name) %>% 
  mutate(year = as.Date(paste(year, "-01-01", sep = "", format = '%Y-%b-%d'))) %>% 
  filter(year > "2004-01-01") 

# match data
df <- left_join(dwellings, vacant, by = c("area_name", "year")) %>% 
  mutate(percent = vacant / dwellings) 

ggplot(df, aes(x = year, y = percent)) +
  geom_line(colour = "#fc6721", size = 0.5) +
  geom_point(colour = "#fc6721", size = 1) +
  scale_x_date(date_labels = "%Y") +
  scale_y_continuous(limits = c(0, max(df$percent)), labels = scales::percent_format(accuracy = 1)) +
  labs(title = "Long-term vacant homes in Greater Manchester",
       subtitle = "Proportion of all dwellings that have been empty for at least six months",
       caption = "Source: Ministry of Housing, Communities and Local Government  |  @traffordDataLab",
       x = NULL, y = NULL) +
  facet_wrap(~area_name, nrow = 2) +
  theme_lab() +
  theme(panel.grid.major.x = element_blank())
