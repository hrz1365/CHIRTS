# Objective
This is a short script that extracts [global CHIRTS daily](https://www.chc.ucsb.edu/data/chirtsdaily) to the boundary of India and then convert the resulting raster to points.

# Dependencies
The script is written in R, with the requirement for these packages in the environment:
- terra: For processing of both the initial netcdf file and also further geospatial processes
- tidyverse: for the usual data wrangling

# Folder structure
- inputs (not included here)
  - The boundary for India in WGS84
  - The initial global netcdf raster in WGS84
- outputs (not included here)
  - The resulting point dataset 
