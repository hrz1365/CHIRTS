
# Header ------------------------------------------------------------------

# Purpose: Extracts CHIRTS daily data to survey points in India
# Date   : 9/15/2023
# Author : Hamidreza Zoraghein




# Packages ----------------------------------------------------------------

if (!requireNamespace('terra', quietly = T))      install.packages('terra')
if (!requireNamespace('tidyverse', quietly = T))  install.packages('tidyverse')

library(terra)
library(tidyverse)




# Inputs and Paths --------------------------------------------------------

global_daily_chirts_path <- file.path('inputs', 'CHIRTS')
india_survey_points_path <- file.path('inputs', 'VitD_Pts.gpkg')
india_boundary_path      <- file.path('inputs', 'India_boundary.geojson')  
outputs                  <- 'outputs'




# Functions ---------------------------------------------------------------

# Load the raster from the internet and set its crs and res
load_raster <- function(url_address, base_raster){
  
  raster_read <- rast(url_address)
  
  crs(raster_read) <- crs(base_raster)
  ext(raster_read) <- ext(base_raster)
  
  
  return(raster_read)
}



# Extract CHIRTS to India boundary 
read_project <- function(boundary_path, chirts_raster){
  
  # Read the boundary file and project it to Mollweide
  boundary_read <- vect(boundary_path)
  
  
  # Crop and mask the global raster to India boundary
  chirts_india_raster <- chirts_raster %>%
    crop(boundary_read) 
  
  
  # Project the resulting raster to Mollweide with 6000M resolution
  chirts_india_proj <- project(chirts_india_raster, "ESRI:54009",
                               method = 'bilinear', res = 6000)
  
  names(chirts_india_proj) <- str_sub(names(chirts_india_proj), -10, -1)
  
  return(chirts_india_proj)
}



# Change the url address based on the current date
url_upd <- function(base_url_add, date){
  
  mod_date    <- str_replace_all(date, '-', '.')
  upd_url_add <- str_replace(base_url_add, '2016.01.01', mod_date)
  
  return(upd_url_add)
}




# Main Program ------------------------------------------------------------

# Read the previous version of CHIRTS daily
base_chirts <- file.path(global_daily_chirts_path, 'base_raster.tif') %>%
  rast()

base_url_add <- 'https://data.chc.ucsb.edu/experimental/CHIRTS-ERA5/tmax/tifs/daily/2016/CHIRTS-ERA5.daily_Tmax.2016.01.01.tif'



starting_date <- as.Date('2016.01.01', '%Y.%m.%d')
ending_date   <- as.Date('2016.01.04', '%Y.%m.%d')



india_survey_points <- india_survey_points_path %>%
  vect() %>%
  project("ESRI:54009")


# The spatial file to include max temperature per date
extraction_df         <- india_survey_points
values(extraction_df) <- extraction_df[['caseid']]


while(date >= starting_date & date <= ending_date){
  
  url_address  <- url_upd(base_url_add, date)
    
  chirts_new   <- load_raster(url_address, base_chirts)
  
  chirts_india <- read_project(india_boundary_path, chirts_new)
  
  extraction_df <- terra::extract(chirts_india, extraction_df, method = 'simple',
                                  bind = T)
  
  cat(str_c("The execution for ", date, " done"))
  
  date <- date + 1
}










