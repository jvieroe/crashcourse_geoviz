library(tidyverse)
library(sf)
library(rnaturalearth)


rivers <- ne_download(scale = 10,
                      type = 'rivers_lake_centerlines',
                      category = 'physical') %>% 
  st_as_sf()

ggplot() +
  geom_sf(data = rivers)



urbana <- ne_download(scale = 10,
                      type = 'urban_areas',
                      category = 'cultural') %>% 
  st_as_sf()


ggplot() +
  geom_sf(data = urbana)




st_write(rivers,
         dsn = "data/rivers",
         layer = "rivers",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")

st_write(urbana,
         dsn = "data/urbana",
         layer = "urbana",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")
