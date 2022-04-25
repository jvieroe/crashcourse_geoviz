library(tidyverse)
library(sf)
library(janitor)
library(osmdata)
library(tmap)

tmap_mode("view")

dk <- st_read(dsn = "data/dk",
              layer = "dk")




osm <- dk %>% 
  st_bbox() %>% 
  opq()

farms <- osm %>% 
  add_osm_feature(key = 'building',
                  value = 'barn') %>% 
  osmdata_sf()

farms_pts <- farms$osm_points

farms_pts <- farms_pts %>% 
  st_intersection(.,
                  dk)

tm_shape(farms_pts) +
  tm_dots()

farms_pts <- farms_pts %>% 
  select(osm_id)

st_write(farms_pts,
         dsn = "data/barns",
         layer = "barns",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")


rm(dk, farms, farms_pts, osm)
