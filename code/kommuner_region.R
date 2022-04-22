# ---------------------------------------------------------------------------
# 
# LAV DOT-KORT
#
# ---------------------------------------------------------------------------

library(tidyverse)
library(sf)


# -------------------- 1.0 Load data --------------------

# ----- 1.1 Regioner
url <- "https://api.dataforsyningen.dk/regioner?format=geojson"
dk <- read_sf(url)
table(st_is_valid(dk))
table(st_is_empty(dk))

temp <- dk %>% 
  st_drop_geometry()


# ----- 1.2 Kommuner
url <- "https://api.dataforsyningen.dk/kommuner?format=geojson"
kommu <- read_sf(url)
table(st_is_valid(kommu))
table(st_is_empty(kommu))

# Fjern Christiansø (ikke en rigtig kommune)
kommu <- kommu %>% 
  filter(navn != "Christiansø")

dk <- dk %>% 
  select(navn, dagi_id)


st_write(dk,
         dsn = "data/regioner",
         layer = "regioner",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")

kommu <- kommu %>% 
  select(navn, dagi_id,
         region = regionsnavn)


st_write(kommu,
         dsn = "data/kommuner",
         layer = "kommuner",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")



# -------------------- 2.0 Definer DOT-omraader --------------------

# ----- 2.1 Match kommuner med regioner
dot <- kommu %>% 
  st_join(dk,
          join = st_overlaps) %>% 
  st_drop_geometry()


dot <- dot %>% 
  mutate(dot = ifelse(regionsnavn %in% c("Region Hovedstaden", "Region Sjælland") & navn.x != "Bornholm",
                      "DOT",
                      "Ikke DOT"))

dot <- dot %>% 
  select(kommune = navn.x,
         region = regionsnavn,
         dot)

dot <- dot %>% 
  arrange(kommune)




# -------------------- 3.0 Eksporter data --------------------

saveRDS(dot,
        file = "data/dot.rds")

rm(dot,
   dk,
   kommu,
   temp,
   url)
