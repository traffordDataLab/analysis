## Food providers in Trafford ##

# Source: GM Poverty Action
# Publisher URL: http://www.gmpovertyaction.org/maps/
# Licence: https://twitter.com/GMPovertyAction/status/931462172206620672

library(sf) ; library(tidyverse) ; library(leaflet) ; library(htmltools)

# Read and tidy data --------------------------------------------

tmp <- "http://www.google.com/maps/d/kml?forcekml=1&mid=1d57arj_ukZpZudaEHERZV72QKxc"
download.file(tmp, "GM Poverty Action Food Providers map.kml")
st_layers("GM Poverty Action Food Providers map.kml")
# kml <- read_sf("GM Poverty Action Food Providers map.kml", layer = "Meal providers")

# Could not retrieve 'ExtendedData' so used mygeodata.cloud/converter/kml-to-csv
food_banks <- read_csv("Food_Banks.csv") %>% mutate(type = "Food Banks")
meal_providers <- read_csv("Meal_providers.csv") %>% mutate(type = "Meal providers")
food_clubs <- read_csv("Pantries_and_food_clubs.csv") %>% mutate(type = "Pantries and food clubs")

df <- bind_rows(food_banks, meal_providers, food_clubs) %>% 
  select(name = Name, 
         type,
         address = Address,
         postcode = Post_Code,
         contact = Contact_Details,
         website = Website)

# Retrieve postcodes with coordinates
postcodes <- read_csv("https://www.traffordDataLab.io/spatial_data/postcodes/gm_postcodes.csv")

# Join postcode coordinates and convert to sf
sf <- left_join(df, postcodes, by = "postcode") %>% 
  filter(area_name == "Trafford") %>% 
  st_as_sf(coords = c("lon", "lat")) %>%
  st_set_crs(4326)

# Write results as csv
write_csv(st_set_geometry(sf, NULL), "food_providers.csv")

# Plot results --------------------------------------------

# Retrieve the local authority boundary from ONS Open Geography Portal
bdy <- st_read("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_April_2019_Boundaries_UK_BGC/MapServer/0/query?where=UPPER(lad19nm)%20like%20'%25TRAFFORD%25'&outFields=lad19nm,lad19cd&outSR=4326&f=geojson") %>% 
  select(area_code = lad19cd, area_name = lad19nm)

popup <- ~paste0(
  "<div class='popupContainer'>",
  "<h3>", sf$name, "</h3>",
  "<table class='popupLayout'>",
  "<tr>",
  "<td>Type</td>",
  "<td>", sf$type, "</td>",
  "</tr>",
  "<td>Address</td>",
  "<td>", sf$address, "</td>",
  "</tr>",
  "<td>Postcode</td>",
  "<td>", sf$postcode, "</td>",
  "</tr>",
  "<td>Email/telephone</td>",
  "<td>", sf$contact, "</td>",
  "</tr>",
  "<td>Website</td>",
  "<td>", sf$website, "</td>",
  "</tr>",
  "</table>",
  "</div>"
)

map <- leaflet(height = "100%", width = "100%") %>% 
  setView(-2.35533522781156, 53.419025498197, zoom = 12) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolylines(data = bdy, stroke = TRUE, weight = 2, color = "#212121", opacity = 1) %>% 
  addMarkers(data = sf, popup = popup) %>% 
  addControl("<strong>Food providers in Trafford</strong><br /><em>Source: GM Poverty Action</em>", position = 'topright')

browsable(
  tagList(list(
    tags$head(
      tags$style("
                 html, body {height: 100%;margin: 0;}
                 .leaflet-control-layers-toggle {height: 44; width: 44;}
                 .leaflet-bar a, .leaflet-bar a:hover, .leaflet-touch .leaflet-bar a, .leaflet-touch .leaflet-bar a:hover {height: 34px; width: 34px; line-height: 34px;}
                 .info {width: 300px;}
                 .popupContainer{overflow: scroll;}
                 .popupLayout{width: 100%;}
                 .popupLayout td{vertical-align: top; border-bottom: 1px dotted #ccc; padding: 3px;}
                 .popupLayout td:nth-child(1){width: 1%; font-weight: bold; white-space: nowrap;}
                 ")
    ),
    map
  ))
)

