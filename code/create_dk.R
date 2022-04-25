library(tidyverse)
library(sf)
library(janitor)


dk <- st_read(dsn = "data/regioner",
              layer = "regioner")


dk <- dk %>% 
  st_union()

ggplot() +
  geom_sf(data = dk)

st_write(dk,
         dsn = "data/dk",
         layer = "dk",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")
