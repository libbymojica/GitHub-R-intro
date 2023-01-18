# Day 2 Spatial Data
# Video https://www.youtube.com/watch?v=T3M40tbbFwg

source("setup.r")

#import colorado counties with tigris
counties <- counties(state = "CO")

# import roads in Larimer county
# limit what data we call because large amount of data

roads <- roads(state = "CO", county = "Larimer")

#set tmap mode to interactive viewing
tmap_mode("view")

# quick thematic map
qtm(counties)
# can click on polygons on map in viewer to see details

# for more detailed map use tm_shape insteam of qtm
# better method to create customized maps
tm_shape(counties)+ 
  tm_polygons()

# quick thematic map
qtm(counties)+
  qtm(roads)

#look at the class of counties
class(counties)

# sf (simple features) is a package to work with vector data, adds a geometry column
# when we create poudre_points object it has no spatial information (if you look at 
# class(poudre_points) it returns "data.frame")
poudre_points <- data.frame(name = c("Mishawaka", "Rustic", "Blue Lake Trailhead"),
                            long = c(-105.35634, -105.58159, -105.85563),
                            lat = c(40.68752, 40.69687, 40.57960))

# convert to spatial
# coordinate reference system WGS 1984 is crs = 4326
poudre_points_sf <- st_as_sf(poudre_points, coords = c("long", "lat"), crs = 4326)
poudre_points_sf 

# raster data
# elevator package, imports raster dem 
# z specifies the zoom level, or resolution of the raster, z = 7 is 1 km resolution
elevation <- get_elev_raster(counties, z = 7)
elevation
qtm(elevation)

# change elevation display continuous palette for map symbol
# add more informative legend title
# looks more gradual symbols because continuous elevation
tm_shape(elevation)+
  tm_raster(style = "cont", title = "Elevation (m)")

# the terra package
# raster data management package, but only if we convert to a terra raster object
# converts from "RasterLayer" to "SpatRaster"
elevation <- rast(elevation)
elevation
# Now data in terra format as a SpatRaster we can use terra functions

# update the name of the file
names(elevation) <- "Elevation"
elevation

# check projection with st_crs function
# we find this data set in NAD83
st_crs(counties)

# check if two data sets are in same projection
crs(counties) == crs(elevation)
# returns false, so need to reproject one of the datasets

#to reproject elevation layer to match counties
elevation_prj <- terra::project(elevation, counties)
# now that both datasets in same projection we can crop elevation to match the county boundary

# crop elevation to Colorado counties extent
elevation_crop <- crop(elevation, ext(counties))
qtm(elevation_crop)

# read and write spatial data

# save sf or vector data
write_sf(counties, "data/counties.shp")

# save raster data
writeRaster(elevation_crop, "data/elevation.tif")

# save RData files
save(counties, roads, file = "data/spatial_objects.RData")
# test removing and reloading spatial objects saved as RData file
rm(counties, roads)
load("data/spatial_objects.RData")
