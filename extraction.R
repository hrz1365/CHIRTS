
# Header ------------------------------------------------------------------

# Purpose: Extracts CHIRTS daily data for India and convert it to points
# Date   : 6/28/2023
# Author : Hamidreza Zoraghein




# Packages ----------------------------------------------------------------

if (!requireNamespace('terra', quietly = T))      install.packages('terra')
if (!requireNamespace('tidyverse', quietly = T))  install.packages('tidyverse')

library(terra)
library(tidyverse)




# Inputs and Paths --------------------------------------------------------

global_daily_chirts_path <- file.path('inputs', 'Tmax_2016.nc')
india_boundary_path      <- file.path('inputs', 'india_wgs84.gpkg')
outputs                  <- 'outputs'




# Main Program ------------------------------------------------------------

# Read the initial global CHIRTS data
# Example: year: 2016, Layers: 366, one per day, format: netcdf
global_chirts_raster <- rast(global_daily_chirts_path)


# Read the boundary file (WGS 1984)
india_boundary <- vect(india_boundary_path)


# Crop and mask the global raster to India boundary
chirts_india_raster <- global_chirts_raster %>%
  crop(india_boundary) %>%
  mask(india_boundary)


# Project the resulting raster to Mollweide with 6000M resolution
chirts_india_proj <- project(chirts_india_raster, "ESRI:54009",
                             method = 'bilinear', res = 6000)


# Convert to points
chirts_india_points <- as.points(chirts_india_proj)


# Write the resulting point dataset to disk
cur_year <- str_extract(str_split_1(global_daily_chirts_path, "_")[2], '[0-9]+')
writeVector(chirts_india_points, file.path(outputs, str_c('india_chirts_daily_', cur_year, '.shp')))
