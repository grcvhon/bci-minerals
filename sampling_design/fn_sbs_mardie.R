###############################################################################
#               Generate spatially balanced sampling design
###############################################################################
#                  *** Modified for Mardie project ***  
#
#    Install the package `dssduoa`, a modified version
#    of the package `dssd` (Marshall 2023)
#    devtools::install_github(repo = "https://github.com/grcvhon/dssduoa.git")
#
###############################################################################

# sbs_mardie function

sbs_mardie <- function(
    # args to generate sampling sites
    seed, # set for reproducibility
    n_block, # number of blocks to generate
    block_size, # area size (usually set to 1000 for 1 sq km block)
    n_trns, # number of transects (usually 3 transects in a 1 sq km block drawn in zigzag manner) 
    angle = 0, # default
    
    # args for setting map extent (specific here: to crop nw_shelf shapefile to Mardie region)
    # values here were used during initial testing. change accordingly
    xmin, # 115.23989
    xmax, # 116.18
    ymin, # -21.61159
    ymax  # -20.98266
    ){
  
  unloadNamespace("dssd")
  
  # required packages
  require(dssduoa)
  require(sf)
  require(tidyverse)
  require(spsurvey)
  require(mapview)
  require(leaflet)
  require(leaflet.minicharts)
  require(leaflet.extras)
  require(raster)
  require(utils)
  
  # set workdir
  setwd("C:/Users/a1235304/Dropbox/BCI-minerals/sampling_design")
  
  # load nwshelf shape
  nw_shape <- st_read("./nw-shelf/NWShelf.shp", quiet = TRUE)
  
  # crop to area of interest (modify values if too large of a region)
  nw_shape_crop <- st_crop(nw_shape, 
                           xmin = xmin, 
                           xmax = xmax, 
                           ymin = ymin, 
                           ymax = ymax)
  
  #print(mapview(nw_shape_crop))
  
  #print(quote = FALSE, "Check map...")
  
  # Check map and answer question.
  # Ask the user a yes/no question
  #user_response <- askYesNo("Are you happy with the map extent? (see Viewer tab in R)")
  
  # Check the user's response and proceed accordingly
  #if (isTRUE(user_response)) {
  #  print(quote = FALSE, "User chose 'Yes'. Executing the next part of the script...")
  #  # Place the code to execute if the user answers "yes" here
  #} else if (isFALSE(user_response)) {
  #  print(quote = FALSE, "User chose 'No'. Modify map extent.")
  #  # Place the code to execute if the user answers "no" here, or use `q()` to quit
  #  # q(save = "no") # Uncomment to quit the R session
  #} else {
  #  print(quote = FALSE, "Cancelled by user.")
  #  # Handle cases where the user might cancel or provide an invalid input
  #}
  
  nw_crop_utm <- st_transform(nw_shape_crop, crs = 32750)
  region_nwsh <- make.region(shape = nw_crop_utm)
  
  # Create grid of points - here using 1000 m x 1000 m cell size (can change this as you need)
  grid_points <- st_as_sfc(st_bbox(nw_crop_utm)) |>
    st_make_grid(cellsize = block_size) |>
    st_as_sf()
  
  # Find grid points within the polygon using st_intersects
  grid_points_inPoly <- st_intersection(grid_points, nw_crop_utm)
  
  # Convert the grid points to polygons
  grid_polygons <- st_as_sf(grid_points_inPoly)
  grid_polygons$gridArea <- as.numeric(st_area(grid_polygons))
  grid_polygons <- filter(grid_polygons, gridArea == block_size^2)
  
  set.seed(seed)
  
  # grts - select a spatially balanced sample - without weighting to any particular site
  sbs_points <- grts(st_intersection(nw_crop_utm[1], st_union(grid_polygons)), n_base = n_block)
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
  #ggplot() + geom_sf(data = nw_crop_utm) + geom_sf(data = st_as_sf(st_geometry(grid_polygons[grids_with_sbs_points_prefSite, ]))) + geom_sf(data = prefSite_sf_utm, col = 'blue', pch = '+', size = 4)
  
  
  
  # Save selected design of grid/blocks as a shapefile ----
  # Make the selected grid a shapefile
  selected_grid_cells_sf <- grid_polygons[grids_with_sbs_points_prefSite, ]
  
  #fd <- paste0("./output/seed",seed,"_",block_size,"m_",n_block,"blocks_",n_trns,"samplers/")
  #if (dir.exists(fd)) {
  #  #Delete file if it exists
  #  print(paste0("Deleting existing directory... seed",seed,"_",block_size,"m_",n_block,"blocks_",n_trns,"samplers/"))
  #  unlink(fd)
  #}
  
  dir <- paste0("./output/seed",seed,"_",block_size,"m_",n_block,"blocks_",n_trns,"samplers/")
  dir.create(dir)
  
  st_write(selected_grid_cells_sf, dsn = paste0(dir, "seed", seed, "_", block_size, "m_block.shp"), append = FALSE)
  
  # Generate transects in dssd package with selected design ----
  # Let us now generate transects inside the blocks we just designed
  block_shape <- st_read(dsn = paste0(dir, "seed", seed, "_", block_size, "m_block.shp"), quiet = TRUE)
  
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
                              samplers = n_trns,
                              design.angle = 0,
                              bounding.shape = c("convex.hull"),
                              edge.protocol = "minus",
                              truncation = 0.02)
  
  block_transects <- generate.transects(block_design)
  
  plot(sampling_block, block_transects, main="Transects within 1 km x 1 km sampling blocks")
  
  # save these map layers as files
  # exporting transects as shapefile
  
  fn <- paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.shp")
  if (file.exists(fn)) {
    #Delete file if it exists
    print(paste0("Deleting existing transect shapefile...", "seed", seed, "_", block_size, "m_sbs_transects.shp"))
    file.remove(fn)
  }
  
  write.transects(block_transects, dsn = paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.shp"))
  
  # exporting transects as csv
  # This will provide you the start and end coordinates of the generated transects
  # Can be nice to have them handy/written down somewhere as backup
  
  fm <- paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.csv")
  if (file.exists(fm)) {
    #Delete file if it exists
    print(paste0("Deleting existing coordinates file...", "seed", seed, "_", block_size, "m_sbs_transects.csv"))
    file.remove(fm)
  }
  
  write.transects(block_transects, dsn = paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.csv"), proj4string = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
  
  fx <- paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.gpx")
  if (file.exists(fx)) {
    #Delete file if it exists
    print(paste0("Deleting existing coordinates file...", "seed", seed, "_", block_size, "m_sbs_transects.gpx"))
    file.remove(fx)
  }
  
  write.transects(block_transects, dsn = paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.gpx"), proj4string = '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
  
  # write provided arguments to text
  file_conn <- file(paste0(dir, "README_seed", seed, "_", block_size, "m_sbs_transects.txt"))
  txt <- 
    paste0("Arguments used: ",
           "seed = ", seed , 
           ", n_block = ", n_block , 
           ", block_size = ", block_size , 
           ", n_trns = ", n_trns , 
           ", xmin = ", xmin , 
           ", xmax = ", xmax , 
           ", ymin = ", ymin , 
           ", ymax = ", ymax)
  writeLines(txt, file_conn)
  close(file_conn)
  
  print(quote = FALSE, "Generating leaflet map...")
  
  # leaflet map interactive
  
  # load sampling block shapefile (blocks)
  sampling_block_shape <- st_read(dsn = paste0(dir, "seed", seed, "_", block_size, "m_block.shp"), quiet = TRUE)
  
  # load transects shapefile (transects)
  block_transect_shape <- st_read(dsn = paste0(dir, "seed", seed, "_", block_size, "m_sbs_transects.shp"), quiet = TRUE)
  
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
  
  ### code for impact
  
  dredge_trn <- read.csv("./impact/dredge_transects.csv")
  dredge_trn$x <- dredge_trn$x - 0.0030
  dredge_trn$y <- dredge_trn$y + 0.0135
  north_dredge_trn_sf <- sf::st_as_sf(dredge_trn, coords = c("x", "y"), crs = 4326)
  
  ndredge_trn_lnstrng <- north_dredge_trn_sf %>%
    group_by(group) %>%
    summarise(do_union = FALSE)
  
  north_dredge_transect_lines <- ndredge_trn_lnstrng %>%
    st_cast("LINESTRING")
  
  
  dredge_trn <- read.csv("./impact/dredge_transects.csv")
  dredge_trn$x <- dredge_trn$x - 0.0065
  dredge_trn$y <- dredge_trn$y - 0.0250
  south_dredge_trn_sf <- sf::st_as_sf(dredge_trn, coords = c("x", "y"), crs = 4326)
  
  sdredge_trn_lnstrng <- south_dredge_trn_sf %>%
    group_by(group) %>%
    summarise(do_union = FALSE)
  
  south_dredge_transect_lines <- sdredge_trn_lnstrng %>%
    st_cast("LINESTRING")
  
  spoil_transect_lines <- spoil_trn_lnstrng %>%
    st_cast("LINESTRING")
  mapview(spoil_transect_lines) + mapview(spoil_area)
  
  
  spoil_trn <- read.csv("./impact/spoil_transects.csv")
  spoil_trn$x <- spoil_trn$x - 0.0045
  spoil_trn$y <- spoil_trn$y - 0.0045
  spoil_trn_sf <- sf::st_as_sf(spoil_trn, coords = c("x", "y"), crs = 4326)
  mapview(spoil_trn_sf) + mapview(spoil_area)
  
  spoil_trn_lnstrng <- spoil_trn_sf %>%
    group_by(group) %>%
    summarise(do_union = FALSE)
  
  spoil_transect_lines <- spoil_trn_lnstrng %>%
    st_cast("LINESTRING")
  
  
  
  # generate a leaflet map
  interactive <- leaflet() %>% 
    addProviderTiles("Esri.WorldImagery") %>%
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
                weight = 1) %>% 
    addPolygons(data = north_dredge_transect_lines,
                fillOpacity = 0,
                color = "cyan",
                opacity = 100,
                weight = 1) %>% 
    addPolygons(data = south_dredge_transect_lines,
                fillOpacity = 0,
                color = "cyan",
                opacity = 100,
                weight = 1) %>% 
    addPolygons(data = spoil_transect_lines,
                fillOpacity = 0,
                color = "cyan",
                opacity = 100,
                weight = 1)
  
  library(htmlwidgets)
  
  # save output as interactive html
  fi <- paste0(dir, "seed", seed, "_", block_size, "m_sbs_interactive.html")
  if (file.exists(fi)) {
    #Delete file if it exists
    print(paste0("Deleting existing HTML file...", "seed", seed, "_", block_size, "m_sbs_interactive.html"))
    file.remove(fi)
  }
  
  saveWidget(interactive, file = paste0(dir, "seed", seed, "_", block_size, "m_sbs_interactive.html"))
}
  
sbs_mardie(seed = 909, 
           n_block = 20, 
           block_size = 1000, 
           n_trns = 60, 
           xmin = 115.61768, 
           xmax = 116.12871, 
           ymin = -21.35492, 
           ymax = -20.81760)

# Approximate extent from provided map
# xmin = 115.61768, xmax = 116.12871, ymin = -21.35492, ymax = -20.71698
# new ymax = -20.81760



