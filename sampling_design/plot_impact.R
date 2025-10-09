setwd("C:/Users/a1235304/Dropbox/BCI-minerals/sampling_design")

library(sf)
library(ggplot2)
library(mapview)
library(leaflet)

# Generate polygon for spoil and dredge areas

### *** SPOIL *** ###

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



### *** DREDGE *** ###

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

### *** APPROXIMATE EXTENT *** ###

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




multi_leaf <- leaflet() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(data = nw_shape_crop, color = "darkblue", group = "NW Crop", fill = NA) %>%
  addPolygons(data = spoil_area, color = "yellow", group = "Spoil Area") %>%
  addPolygons(data = dredge_area, color = "orangered", group = "Dredge Area") %>%
  addScaleBar(position = "bottomleft", options = scaleBarOptions(imperial = FALSE)) %>%
  addLayersControl(
    overlayGroups = c("NW Crop", "Spoil Area", "Dredge Area"),
    options = layersControlOptions(collapsed = FALSE)
  )
multi_leaf
mapview::mapshot2(multi_leaf, file = "multi_leaf.png")

ggplot() + 
  geom_sf(data = spoil_area) +
  geom_sf(data = nw_shape_crop, fill = NA) +
  coord_sf(xlim = c(xmin,xmax), ylim = c(ymin,ymax), expand = FALSE)
  

library(tmap)

tmap_mode("plot")  # for static maps

# Reproject to Web Mercator (EPSG:3857)
nw_shape_crop_proj <- sf::st_transform(nw_shape_crop, 4326)
spoil_area_proj <- sf::st_transform(spoil_area, 4326)
dredge_area_proj <- sf::st_transform(dredge_area, 4326)

tm_shape(nw_shape_crop_proj) +
  tm_borders(col = "blue") +
  tm_shape(spoil_area_proj) +
  tm_borders() +
  tm_shape(dredge_area_proj) +
  tm_borders(col = "orangered") +
  tm_scale_bar(position = c("right", "bottom")) +
  tm_layout(legend.outside = TRUE)


