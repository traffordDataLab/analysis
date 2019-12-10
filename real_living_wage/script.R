# Living Wage Employers in Trafford #

# Source: https://www.livingwage.org.uk
# URL: https://www.livingwage.org.uk/living-wage-map

library(tidyverse) ; library(jsonlite) ; library(sf) ; library(leaflet) ; library(htmltools) ; library(htmlwidgets)

# Retrieve the local authority boundary from ONS Open Geography Portal
bdy <- st_read("https://ons-inspire.esriuk.com/arcgis/rest/services/Administrative_Boundaries/Local_Authority_Districts_April_2019_Boundaries_UK_BGC/MapServer/0/query?where=UPPER(lad19nm)%20like%20'%25TRAFFORD%25'&outFields=lad19nm,lad19cd&outSR=4326&f=geojson") %>% 
  select(area_code = lad19cd, area_name = lad19nm)

# Retrieve Living Wage Employers
sf <- fromJSON("https://living-wage-map.appspot.com/get_markers/53.40790551802543/-2.399383789776608/14879.687935638334/200/NONE") %>% 
  st_as_sf(crs = 4326, coords = c("lng", "lat")) %>% 
  st_intersection(bdy)

popup <- ~paste0(
  "<div class='popupContainer'>",
  "<h3>", sf$name, "</h3>",
  "<table class='popupLayout'>",
  "<tr>",
  "<td>Address</td>",
  "<td>", sf$address, "</td>",
  "</tr>",
  "<td>Type</td>",
  "<td>", sf$orgtype, "</td>",
  "</tr>",
  "</table>",
  "</div>"
)

map <- leaflet(height = "100%", width = "100%") %>% 
  setView(-2.35533522781156, 53.419025498197, zoom = 12) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolylines(data = bdy, stroke = TRUE, weight = 2, color = "#212121", opacity = 1) %>% 
  addMarkers(data = sf, popup = popup) %>% 
  addControl("<strong>Living Wage Employers in Trafford</strong><br /><em>Source: Living Wage Foundation </em>", position = 'topright')

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
