### Plot impact area
# This script takes the available information from
# https://www.epa.wa.gov.au/sites/default/files/Referral_Documentation/Att3_DSDMP%20%28O2%20Marine%2C%202025%29.pdf
# regarding the dredge and spoil areas of the BCI Minerals Mardie Project

# set working directory
setwd("C:/Users/a1235304/Dropbox/BCI-minerals/sampling_design")

# load packages
library(sf)
library(ggplot2)
library(mapview)
library(leaflet)

# Generate polygon for dredge and spoil areas

#### *** DREDGE *** ####

# 1. Read and convert to sf points
dredge <- read.csv("./impact/dredge.csv")
dredge_points <- sf::st_as_sf(dredge, coords = c("x", "y"), crs = 4326)

# 2. Extract coordinates and ensure polygon is closed (first point == last point)
dredge_coords <- sf::st_coordinates(dredge_points)

# If not already closed, add the first point to the end
if (!all(dredge_coords[1, ] == dredge_coords[nrow(dredge_coords), ])) {
  dredge_coords <- rbind(dredge_coords, dredge_coords[1, ])
}

# 3. Create polygon geometry
dredge_poly_geom <- sf::st_polygon(list(dredge_coords))

# 4. Wrap in an sf object with same CRS
dredge_area <- sf::st_sfc(dredge_poly_geom, crs = sf::st_crs(dredge_points))

# 5. Convert to sf data frame
dredge_area <- sf::st_sf(geometry = dredge_area)
plot(dredge_area)

mapview::mapview(spoil_area) + mapview::mapview(dredge_area)

#### *** SPOIL *** ####

# 1. Read and convert to sf points
spoil <- read.csv("./impact/spoil.csv")
spoil_points <- sf::st_as_sf(spoil, coords = c("x", "y"), crs = 4326)

# 2. Extract coordinates and ensure polygon is closed (first point == last point)
spoil_coords <- sf::st_coordinates(spoil_points)

# If not already closed, add the first point to the end
if (!all(spoil_coords[1, ] == spoil_coords[nrow(spoil_coords), ])) {
  spoil_coords <- rbind(spoil_coords, spoil_coords[1, ])
}

# 3. Create polygon geometry
spoil_poly_geom <- sf::st_polygon(list(spoil_coords))

# 4. Wrap in an sf object with same CRS
spoil_area <- sf::st_sfc(spoil_poly_geom, crs = sf::st_crs(spoil_points))

# 5. Convert to sf data frame
spoil_area <- sf::st_sf(geometry = spoil_area)
plot(spoil_area)

multi_leaf <- leaflet() %>%
  addProviderTiles("CyclOSM") %>%
  addPolygons(data = dredge_area, color = "red", group = "Dredge Area", 
              weight = 2, fillOpacity = 50, fillColor = "pink") %>%
  addPolygons(data = spoil_area, color = "red", group = "Spoil Area", 
              weight = 2, fillOpacity = 50, fillColor  = "pink") %>%
  addScaleBar(position = "bottomleft", options = scaleBarOptions(imperial = FALSE))

multi_leaf

st_area(dredge_area) # 0.59 km^2
st_area(spoil_area) # 0.30 km^2


#### *** APPROXIMATE EXTENT *** ####

# Approximate extent
xmin  <- 115.61768 
xmax  <- 116.12871 
ymin  <- -21.35492
ymax  <- -20.71698

nw_shape <- sf::st_read("sampling_design/nw-shelf/NWShelf.shp", quiet = TRUE)
nw_shape_crop <- sf::st_crop(nw_shape, 
                             xmin = xmin, 
                             xmax = xmax, 
                             ymin = ymin, 
                             ymax = ymax)
nw_shape_crop <- st_transform(nw_shape_crop, crs = 4326)

nw_shp_crop_leaf <- leaflet() %>% 
  addProviderTiles("OpenStreetMap") %>% 
  addPolygons(data = nw_shape_crop, color = "blue", 
              fillOpacity = 0, weight = 2) %>% 
  addPolygons(data = dredge_area, color = "red", group = "Dredge Area", 
              weight = 2, fillOpacity = 50, fillColor = "pink") %>%
  addPolygons(data = spoil_area, color = "red", group = "Spoil Area", 
              weight = 2, fillOpacity = 50, fillColor  = "pink") %>%
  addScaleBar(position = "bottomleft", options = scaleBarOptions(imperial = FALSE))
nw_shp_crop_leaf






