dest_file      <- file.path('inputs', 'Tmax_2016.nc')
india_boundary <- file.path('inputs', 'india_wgs84.gpkg')




if (!requireNamespace('terra', quietly = T))      install.packages('terra')
if (!requireNamespace('sf', quietly = T))         install.packages('sf')
if (!requireNamespace('tidyverse', quietly = T))  install.packages('tidyverse')

library(terra)
library(tidyverse)
library(sf)


global_raster <- rast(dest_file)



india_boundary <- read_sf(india_boundary)





cur_CHIRTS <- global_raster[[2]] %>%
  terra::crop(india_boundary) %>%
  terra::mask(india_boundary)
