# Transects for Mardie
# *** Adopted from the Dampier spatially balanced (transect) design ***

setwd("C:/Users/a1235304/Dropbox/BCI-minerals/sampling_design")

require(dssduoa)
require(sf)
require(tidyverse)
require(spsurvey)
require(mapview)
require(leaflet)
require(leaflet.minicharts)
require(leaflet.extras)
require(raster)

# load nwshelf shape
nw_shape <- st_read("./nw-shelf/NWShelf.shp", quiet = TRUE)

# crop to area of interest (modify values if too large of a region)
nw_shape_crop <- st_crop(nw_shape, xmin = 115.61768, xmax = 116.12871, ymin = -21.35492, ymax = -20.71698)

mapview(nw_shape_crop)

nw_crop_utm <- st_transform(nw_shape_crop, crs = 32750)
region_nwsh <- make.region(shape = nw_crop_utm)
  
# Create grid of points - here using 1000 m x 1000 m cell size (can change this as you need)
grid_points <- st_as_sfc(st_bbox(nw_crop_utm)) |>
  st_make_grid(cellsize = 1000) |>
  st_as_sf()

# Find grid points within the polygon using st_intersects
grid_points_inPoly <- st_intersection(grid_points, nw_crop_utm)

# Convert the grid points to polygons
grid_polygons <- st_as_sf(grid_points_inPoly)
grid_polygons$gridArea <- as.numeric(st_area(grid_polygons))
grid_polygons <- filter(grid_polygons, gridArea == 1000^2)

# grts - select a spatially balanced sample - without weighting to any particular site
# *** the first application of this is with the SBS design for Dampier transects ***
sbs_points <- grts(st_intersection(nw_crop_utm[1], st_union(grid_polygons)), n_base = 20)
plot(sbs_points)

sbs_points_sf <- st_as_sf(sbs_points$sites_base)

# Plot the results
ggplot() + geom_sf(data = grid_polygons) + geom_sf(data = sbs_points_sf)

# Extract only the SBS selected grid cells
grids_with_sbs_points <- st_intersects(sbs_points_sf, grid_polygons, sparse = T) %>% as.numeric()

# Plot the results
ggplot() + 
  geom_sf(data = nw_crop_utm) + 
  geom_sf(data = st_as_sf(st_geometry(grid_polygons[grids_with_sbs_points, ])))

# Adjust inclusion probability by preferred survey site - import preferred site approximate coordinates
prefSite <- read_csv("./mardie_sites.csv", show_col_types = FALSE)

# Convert to sf object
prefSite_sf <- st_as_sf(prefSite, coords = c('longitude_dd', 'latitude_dd'), crs = 4326)
prefSite_sf_utm <- st_transform(prefSite_sf, crs = 32750)

# Plot
ggplot() + geom_sf(data = nw_crop_utm) + geom_sf(data = st_as_sf(st_geometry(grid_polygons[grids_with_sbs_points, ]))) + geom_sf(data = prefSite_sf_utm)

# Here weighting preferred sites to be 10-fold higher for inclusion than non-preferred site cells
grid_polygons$nprefSite <- (10*(lengths(st_intersects(grid_polygons, prefSite_sf_utm))>0))+1

# Now can re-do spatially balanced sampling with increased inclusion probability if cell has preferred site
sbs_points_prefSite <- grts(grid_polygons, n_base = 20, aux_var = "nprefSite")

sbs_points_prefSite_sf <- st_as_sf(sbs_points_prefSite$sites_base)

# Extract only the SBS selected grid cells
grids_with_sbs_points_prefSite <- st_intersects(sbs_points_prefSite_sf, grid_polygons, sparse = T) %>% as.numeric()

# Plot the results
ggplot() + geom_sf(data = nw_crop_utm) + geom_sf(data = st_as_sf(st_geometry(grid_polygons[grids_with_sbs_points_prefSite, ]))) + geom_sf(data = prefSite_sf_utm, col = 'blue', pch = '+', size = 4)



# Save selected design of grid/blocks as a shapefile ----
# Make the selected grid a shapefile
selected_grid_cells_sf <- grid_polygons[grids_with_sbs_points, ]

#dir <- paste0("./output/seed",seed,"_",block_size,"m_",sum(npz_nBlock,hpz_nBlock,muz_nBlock),"blocks_",dssd_samplers,"samplers/")
#dir.create(dir)

st_write(selected_grid_cells_sf, dsn = paste0("./output/test_block.shp"), append = FALSE)

# Generate transects in dssd package with selected design ----
# Let us now generate transects inside the blocks we just designed
block_shape <- st_read("./output/test_block.shp", quiet = TRUE)

#Check the initial CRS of the shapefile
st_crs(block_shape)

#Assign projected coordinate system
block_shape_utm <- st_transform(block_shape, crs = 32750)

# Check the CRS after transformation
st_crs(block_shape_utm)

# Plot the sampling blocks
sampling_block <- make.region(shape = block_shape_utm)

# Use `make.design` function from dssd package to generate transects within blocks
block_design <- make.design(region = sampling_block,
                            transect.type = "line",
                            design = "eszigzag",
                            samplers = 60,
                            design.angle = 0,
                            bounding.shape = c("convex.hull"),
                            edge.protocol = "minus",
                            truncation = 0.02)

block_transects <- generate.transects(block_design)

plot(sampling_block, block_transects, main="Transects within 1 km x 1 km sampling blocks")

# save these map layers as files
# exporting transects as shapefile

#fn <- paste0("dir, "seed", seed, "_", block_size, "m_sbs_transects".shp")
#if (file.exists(fn)) {
#  #Delete file if it exists
#  print(paste0("Deleting existing transect shapefile...", "seed", seed, "_", block_size, "m_sbs_transects.shp"))
#  file.remove(fn)
#}

write.transects(block_transects, dsn = "./output/test_sbs_transects.shp")

# exporting transects as csv
# This will provide you the start and end coordinates of the generated transects
# Can be nice to have them handy/written down somewhere as backup

#fm <- paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.csv")
#if (file.exists(fm)) {
#  #Delete file if it exists
#  print(paste0("Deleting existing coordinates file...", "seed", seed, "_", block_size, "m_sbs_transects.csv"))
#  file.remove(fm)
#}

write.transects(block_transects, dsn = "./output/test_sbs_transects.csv", proj4string = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')

#fx <- paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.gpx")
#if (file.exists(fx)) {
#  #Delete file if it exists
#  print(paste0("Deleting existing coordinates file...", "seed", seed, "_", block_size, "m_sbs_transects.gpx"))
#  file.remove(fx)
#}

write.transects(block_transects, dsn = "./output/test_sbs_transects.gpx", proj4string = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')



# leaflet map interactive

# load sampling block shapefile (blocks)
sampling_block_shape <- st_read("./output/test/test_block.shp", quiet = TRUE)

# load transects shapefile (transects)
block_transect_shape <- st_read(dsn = "./output/test/test_sbs_transects.shp", quiet = TRUE)

# ensuring all layers are in GDA94 (works using this projection...somehow)
sampling_block_shape_GDA94 <- st_transform(x = sampling_block_shape, crs = st_crs(nw_shape_crop))
#sampling_block_shape_GDA94$Block <- 
#  paste0(LETTERS[seq_len(nrow(sampling_block_shape_GDA94))],
#         "-",gsub("[^A-Z]","", sampling_block_shape_GDA94$ZoneName),
#         "-",seq_len(nrow(sampling_block_shape_GDA94)))
block_transect_shape_GDA94 <- st_transform(x = block_transect_shape, crs = st_crs(nw_shape_crop))

crop <- st_transform(nw_shape_crop, crs = 4326)
blok <- st_transform(sampling_block_shape_GDA94, crs = 4326)
trns <- st_transform(block_transect_shape_GDA94, crs = 4326)

# generate a leaflet map
int_map <- 
  leaflet() %>% 
  addTiles() %>%
  addFullscreenControl() %>% 
  addMeasurePathToolbar() %>%
  addFullscreenControl() %>% 
  addScaleBar(position = "bottomleft") %>%
  addMeasure(primaryLengthUnit = "meters", 
             position = "bottomleft",
             primaryAreaUnit = "sqmeters") %>% 
  addPolygons(data = crop,
              fillOpacity = 0,
              color = "blue",
              opacity = 100,
              weight = 3) %>% 
  addPolygons(data = blok,
              fillOpacity = 0,
              color = "gold",
              opacity = 100,
              weight = 1,
              label = blok$Block,
              labelOptions = labelOptions(noHide = TRUE,
                                          opacity = 75, 
                                          direction = "bottom")) %>% 
  addPolygons(data = trns,
              fillOpacity = 0,
              color = "orangered",
              opacity = 100,
              weight = 1)

library(htmlwidgets)
saveWidget(int_map, file = "./int_map.html")

