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


world <- ne_download(scale = 50,
                      type = "countries") %>% 
  st_as_sf()

europe_bbox <- st_bbox(c(xmin = -12, xmax = 41, ymax = 71, ymin = 34), crs = st_crs(4326))

europe <- world %>% 
  st_crop(europe_bbox)

europe <- europe %>% 
  filter(REGION_UN == "Europe")


tmap_mode("view")

tm_shape(europe) +
  tm_polygons()

ggplot() +
  geom_sf(data = europe)


rivers <- rivers %>% 
  select(name, featurecla, ne_id)

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


