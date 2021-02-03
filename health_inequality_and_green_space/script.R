# Health inequality and green space #

library(tidyverse) ; library(sf)  ; library(osmdata) ; library(leaflet) ; library(htmlwidgets)

# Read data --------------------------------------------------------------------

# Trafford local authority boundary
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-may-2020-boundaries-uk-bgc-1
lad <- st_read("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_May_2020_UK_BGC_V3/FeatureServer/0/query?where=LAD20NM%20%3D%20'TRAFFORD'&outFields=*&outSR=27700&f=geojson") %>% 
  st_buffer(dist = 30) %>% 
  st_transform(4326)

# LSOAs
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/lower-layer-super-output-areas-december-2011-boundaries-full-clipped-bfc-ew-v3
lsoa <- st_read("https://ons-inspire.esriuk.com/arcgis/rest/services/Census_Boundaries/Lower_Super_Output_Areas_December_2011_Boundaries/MapServer/2/query?where=UPPER(lsoa11nm)%20like%20'%25TRAFFORD%25'&outFields=lsoa11cd,lsoa11nm&outSR=27700&f=geojson") %>% 
  select(area_code = lsoa11cd, area_name = lsoa11nm)

# Buildings
# Source: Ordnance Survey Open Map - Local
# URL: https://www.ordnancesurvey.co.uk/business-government/products/open-map-local
buildings <- st_read("OS OpenMap Local (ESRI Shape File) SJ/data/SJ_Building.shp") %>% 
  st_transform(27700)

# Town centres in Trafford
town_centres <- tribble(
  ~name, ~lat, ~lon,
  "Sale", 53.4243665, -2.3182869,
  "Stretford", 53.4452286, -2.3222351,
  "Urmston", 53.4452286, -2.3524475,
  "Altrincham", 53.3838403, -2.3527908,
  "Partington", 53.4212977, -2.4281502,
  "Carrington", 53.433553, -2.384744,
  "Old Trafford", 53.461922, -2.270467,
  "Timperley", 53.3961251, -2.320175)

# Health Deprivation and Disability
# Source: IMD 2019, MHCLG
# URL: https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019
deprivation <- read_csv("https://github.com/traffordDataLab/imd19/raw/master/data/imd.csv") %>% 
  filter(year == "2019",
         index_domain == "Health Deprivation and Disability",
         lsoa11cd %in% pull(lsoa, area_code))

# Green spaces
# Source: OS Open Greenspace
# URL: https://www.ordnancesurvey.co.uk/business-and-government/products/os-open-greenspace.html
greenspace <- st_read("https://github.com/traffordDataLab/climate_emergency/raw/master/data/greenspaces.geojson") %>% 
  # Publicly accessible green space defined by ONS
  # https://www.ons.gov.uk/economy/environmentalaccounts/bulletins/uknaturalcapital/urbanaccounts
  filter(site_type %in% c("Religious Ground and Cemetries",
                          "Playing Field", "Public Park Or Garden"))

# Waterways
# Source: OpenStreetMap
waterways <- opq(bbox = c(-2.457434, 53.361808, -2.268022, 53.474435)) %>%
  add_osm_feature(key = "waterway", value = c("river", "canal")) %>%
  osmdata_sf() %>% 
  magrittr::extract2("osm_lines") %>% 
  st_intersection(lad)

# Tidy data --------------------------------------------------------------------
lsoa_deprivation <- left_join(lsoa, deprivation, by = c("area_code" = "lsoa11cd")) %>% 
  filter(decile %in% c(1:2))

buildings_lsoa <- st_intersection(buildings, st_transform(lsoa_deprivation, 27700)) %>% 
  st_transform(4326)

# Plot data --------------------------------------------------------------------
map <- leaflet(data = greenspace) %>% 
  setView(-2.35533522781156, 53.419025498197, zoom = 12) %>% 
  addTiles(urlTemplate = "",
           attribution = '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> <a href="https://www.ons.gov.uk/methodology/geography/licences">| Contains OS data © Crown copyright and database right (2021)</a>') %>% 
  addPolygons(data = lad, fillColor = "#F2F3F0", fillOpacity = 1, stroke = FALSE) %>% 
  addPolygons(data = st_transform(lsoa_deprivation, 4326),
              fillColor = "#FA8B01", fillOpacity = 0.3, weight = 1, opacity = 1, color = "#bdbdbd", label = ~area_name,
              labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto")) %>%
  addPolylines(data = buildings_lsoa, color = "#FA8B01", weight = 1, opacity = 0.7) %>% 
  addPolylines(data = waterways, color = "#94C1E1", weight = 2, opacity = 1) %>% 
  addPolygons(fillColor = "#BBD897", fillOpacity = 0.7, weight = 1, opacity = 1, color = "#FFFFFF", label = ~site_type,
              highlight = highlightOptions(weight = 1, color = "#000000", fillOpacity = 0.7, bringToFront = FALSE),
              labelOptions = labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "15px", direction = "auto")) %>% 
  addLabelOnlyMarkers(data = town_centres, label = ~as.character(name), 
                      labelOptions = labelOptions(noHide = T, textOnly = T, direction = "bottom",
                                                  style = list(
                                                    "color"="#FFFFFF",
                                                    "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>%
  addControl("
             <p><strong>Areas of highest health inequality and publicly accessible green space</strong></p>
<p>Most deprived 20% of neighbourhoods on Health Deprivation and Disability Index<br/>overlaid with parks, public gardens, playing fields, cemetries and religious grounds</p>
<p><em>Source: Index of Multiple Deprivation 2019; OS Open Greenspace; OpenStreetMap</em></p>
             ",
             position = 'topright') %>% 
  onRender("function(el, t) {var myMap = this;myMap._container.style['background'] = '#ffffff';}")
map

saveWidget(map, file = "index.html", selfcontained = T)
