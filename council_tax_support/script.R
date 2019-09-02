# Council tax support in Trafford #

library(tidyverse) ; library(readxl) ; library(sf) ; library(leaflet) ; library(leaflet.minicharts) ; library(htmltools) ; library(htmlwidgets)

wards <- st_read("https://www.trafforddatalab.io/spatial_data/ward/2017/trafford_ward_full_resolution.geojson")
postcodes <- read_csv("https://github.com/traffordDataLab/spatial_data/raw/master/postcodes/trafford_postcodes.csv") %>% 
  select(postcode, area_code)

df <- read_xlsx("CTS Full or partial with postcode and ward.xlsx") %>% 
  rename(postcode = `Post Code`) %>% 
  left_join(., postcodes, by = "postcode") %>% 
  group_by(`Full CTS`, area_code) %>% 
  tally() %>% 
  spread(`Full CTS`, n) %>% 
  drop_na()

sf <- left_join(wards, df, by = "area_code")

tag.map.title <- tags$style(HTML("
  .leaflet-control.map-title { 
    transform: translate(-50%,20%);
    position: fixed !important;
    left: 50%;
    text-align: center;
    padding-left: 10px; 
    padding-right: 10px; 
    background: rgba(255,255,255,0.75);
    font-weight: bold;
    font-size: 20px;
  }
"))

title <- tags$div(
  tag.map.title, HTML("Council tax support claims, (2019/20)")
)  

map <- leaflet() %>% 
  setView(lng = -2.330256, lat= 53.421829, zoom = 12) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolygons(data = sf, fillColor = "#757575", weight = 1.5, color = "#212121", fillOpacity = 0.3) %>% 
  addLabelOnlyMarkers(data = sf, lng = ~lon, lat = ~lat, label = ~as.character(area_name),
                      labelOptions = labelOptions(
                        noHide = TRUE, textOnly = TRUE, textsize = "12px",
                        direction = "bottom", offset = c(0,-10),
                        style = list(
                          "color"="white",
                          "text-shadow" = "-1px -1px 10px #757575, 1px -1px 10px #757575, 1px 1px 10px #757575, -1px 1px 10px #757575"))) %>% 
  addMinicharts(sf$lon, sf$lat, type = "bar", 
                chartdata = st_set_geometry(sf,NULL)[, c("Full", "Partial")], 
                colorPalette = c("#FA8C00", "#47C67B"),
                width = 45, height = 45,
                legendPosition = "bottomleft") %>% 
  addControl(title, position = "topleft", className = "map-title")
map   

saveWidget(map, file = "index.html", selfcontained = T)
