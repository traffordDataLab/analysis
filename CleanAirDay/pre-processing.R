# Licensed vehicles #

# Source: Department for Transport and Driver and Vehicle Licensing Agency 
# URL: https://www.gov.uk/government/statistical-data-sets/all-vehicles-veh01
# Licence: Open Government Licence v3.0

library(tidyverse) ; library(httr);  library(readODS)

# Diesel cars
tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/794433/veh0105.ods",
    write_disk(tmp))

sheets <- tmp %>%
  ods_sheets() %>%
  set_names() %>% 
  map_df(~ read_ods(path = tmp, sheet = .x, 
                    col_names = TRUE, col_types = NA, skip = 7), .id = "sheet")

diesel <- sheets %>% 
  filter(`Region/Local Authority` %in% c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")) %>% 
  mutate(period = as.Date(paste(sheet, 1, 1, sep = "-")),
         n = as.numeric(`Diesel Cars`)*1000,
         total_cars =  as.numeric(Cars)*1000,
         group = "Diesel cars") %>% 
  select(area_code = `ONS LA Code`, 
         area_name = `Region/Local Authority`, 
         period, n, total_cars, group)

write_csv(diesel, "data/diesel_cars.csv")

# Electric vehicles
tmp <- tempfile(fileext = ".ods")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/794447/veh0131.ods",
    write_disk(tmp))

ev <- read_ods(tmp, skip = 6)  %>%  
  filter(`Region/Local Authority` %in% c("Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan")) %>% 
  rename(area_code = `ONS LA Code`, area_name = `Region/Local Authority`) %>% 
  gather(period, n, -area_code, -area_name) %>% 
  mutate(quarter = 
           case_when(
             str_detect(period, "Q1") ~ "01-01",
             str_detect(period, "Q2") ~ "04-01",
             str_detect(period, "Q3") ~ "07-01",
             str_detect(period, "Q4") ~ "10-01"),
         period = parse_number(period),
         n = as.numeric(na_if(n, "c")),
         group = "Electric vehicles") %>% 
  unite(period, c("period", "quarter"), sep = "-") %>% 
  mutate(period = as.Date(period, format = "%Y-%m-%d"))

write_csv(ev, "data/electric_vehicles.csv")

