library(tidyverse) ; library(sf) ; library(httr) ; library(jsonlite) ; library(lubridate) ; library(readxl)

# Enter a local authority name
district <- "South Kesteven"

# Electoral ward vector boundaries ----------------------------
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/census-merged-wards-december-2011-generalised-clipped-boundaries-in-england-and-wales
# Licence: Open Government Licence v.3.0

codes <- fromJSON(paste0("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD18_LAD18_UK_LU/FeatureServer/0/query?where=LAD18NM%20like%20'%25", URLencode(toupper(district), reserved = TRUE), "%25'&outFields=WD18CD,LAD18NM&outSR=4326&f=json"), flatten = TRUE) %>% 
  pluck("features") %>% 
  as_tibble() %>% 
  distinct(attributes.WD18CD) %>% 
  pull(attributes.WD18CD)

wards <- st_read(paste0("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Wards_December_2018_Boundaries_V3/MapServer/2/query?where=", 
                        URLencode(paste0("wd18cd IN (", paste(shQuote(codes), collapse = ", "), ")")), 
                        "&outFields=wd18cd,wd18nm&outSR=4326&f=geojson")) %>% 
  mutate(district_name = district) %>% 
  select(ward_code = wd18cd, ward_name = wd18nm, district_name)

# Latest police recorded crimes ----------------------------
# Source: Home Office
# URL: https://data.police.uk/data/
# Licence: Open Government Licence v.3.0

coords <- st_as_sfc(st_bbox(wards)) %>% 
  st_coordinates() %>% 
  as_tibble() %>%
  select(X, Y) %>%
  unite(coords, Y, X, sep = ',') %>% 
  mutate(coords = sub("$", ":", coords)) %>% 
  .[["coords"]] %>% 
  paste(collapse = "") %>% 
  str_sub(., 1, str_length(.)-1)

request <- POST(url = "https://data.police.uk/api/crimes-street/all-crime",
            query = list(poly = c(coords)))

response <- content(request, as = "text", encoding = "UTF-8") %>% 
  fromJSON(flatten = TRUE) %>% 
  as_tibble()

crimes <- tibble(
  period = response$month,
  category = response$category,
  long = as.numeric(as.character(response$location.longitude)),
  lat = as.numeric(as.character(response$location.latitude))
) %>% 
  mutate(period = ymd(str_c(period, "-01", sep = "-")))

# Ward level mid-2018 population estimates ----------------------------
# Source: ONS
# URL: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/wardlevelmidyearpopulationestimatesexperimental
# Licence: Open Government Licence v.3.0

url <- "https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2fwardlevelmidyearpopulationestimatesexperimental%2fmid2018sape21dt8a/sape21dt8amid2018ward20182019lasyoaestunformatted.zip"
download.file(url, dest = "sape21dt8amid2018ward20182019lasyoaestunformatted.zip")
unzip("sape21dt8amid2018ward20182019lasyoaestunformatted.zip", exdir = ".")
file.remove("sape21dt8amid2018ward20182019lasyoaestunformatted.zip")

population <- read_excel("SAPE21DT8a-mid-2018-ward-2018-on-2019-LA-syoa-estimates-unformatted.xlsx", sheet = 4, skip = 3) %>%
  filter(`Ward Code 1` %in% codes) %>%
  select(ward_code = `Ward Code 1`, population = `All Ages`)

# Point in polygon ----------------------------
vap <- crimes %>% 
  filter(category == "violent-crime") %>% # filter VAP offences
  st_as_sf(crs = 4326, coords = c("long", "lat")) %>% # convert to spatial dataframe
  st_intersection(wards) %>% # run point in polygon operation
  st_set_geometry(value = NULL) %>% # drop spatial geometry
  group_by(period, category, ward_code) %>% # group by ward
  summarise(crimes = n()) # count crimes per ward

# Join crimes to ward vector boundaries and calculate rate ----------------------------
left_join(wards, vap, by = "ward_code") %>% # join crime count
  left_join(population, by = "ward_code") %>%  # join ward population estimates
  mutate(rate = round(crimes/population*1000,1)) %>% # calculate a rate of crime per 1000 residents
  select(ward_code, ward_name, district_name, period, category, crimes, population, rate) %>% # drop unwanted variables
  st_write("crime_rate_by_ward.geojson")
