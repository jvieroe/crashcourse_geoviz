library(tidyverse)
library(janitor)
library(sf)

map_df <- read_sf("https://api.dataforsyningen.dk/kommuner?format=geojson") %>% 
  filter(navn != "Christiansø")

vs <- readxl::read_xlsx("data/valgdata.xlsx") %>% 
  clean_names()

geo <- read_delim("https://raw.githubusercontent.com/jvieroe/dataviz/main/2021/kv2021/data/Geografiske_stamdata.csv", locale = locale(encoding = "windows-1252")) %>% 
  tibble() %>% 
  clean_names() %>% 
  mutate(kommune_navn = ifelse(kommune_navn == "Lyngby-Tårbæk",
                               "Lyngby-Taarbæk",
                               kommune_navn)) %>% 
  mutate(kommune_navn = ifelse(kommune_navn == "Frederiksværk-Hundested",
                               "Halsnæs",
                               kommune_navn)) %>% 
  mutate(kommune_navn = ifelse(kommune_navn == "Bornholms Region",
                               "Bornholm",
                               kommune_navn)) %>% 
  mutate(kommune_navn = ifelse(kommune_navn == "Århus",
                               "Aarhus",
                               kommune_navn)) %>% 
  mutate(kommune_navn = ifelse(kommune_navn == "Brønderslev-Dronninglund",
                               "Brønderslev",
                               kommune_navn)) %>% 
  select(valgsted_id,
         kommune_navn,
         kommune_nr)


vs <- vs %>% 
  tidylog::left_join(.,
                     geo,
                     by = c("valgsted_id"))

vs <- vs %>% 
  rename(stemmeberettigede = kv2017_stemmeberettigede,
         afgivne = kv2017_afgivne_stemmer,
         blanke = kv2017_blanke_stemmer,
         andre_ugyldige = kv2017_andre_ugyldige_stemmer,
         gyldige = kv2017_gyldige_stemmer)

vs <- vs %>% 
  mutate(across(all_of(starts_with("kv2017")),
                ~ as.numeric(.x)))



plot_df <- vs %>% 
  group_by(kommune_navn, kommune_nr) %>% 
  summarize(party = sum(kv2017_v, na.rm = TRUE),
            total = sum(gyldige)) %>% 
  ungroup() %>% 
  mutate(share = party / total) %>% 
  arrange(desc(share))


vs <- vs %>% 
  group_by(valgsted_id) %>% 
  summarize(party = sum(kv2017_v, na.rm = TRUE),
            total = sum(gyldige)) %>% 
  ungroup() %>% 
  mutate(share = party / total) %>% 
  arrange(desc(share))


map_df <- map_df %>% 
  tidylog::left_join(.,
                     plot_df,
                     by = c("navn" = "kommune_navn"))


saveRDS(plot_df,
        "data/plot_df.rds")

saveRDS(vs,
        "data/vs.rds")

saveRDS(geo,
        "data/geo.rds")


map_df <- map_df %>% 
  select(dagi_id,
         navn,
         kommune_nr,
         party, total, share)

st_write(map_df,
         dsn = "data/kommuner_98",
         layer = "kommuner_98",
         encoding = "UTF-8",
         delete_layer = TRUE,
         factorsAsCharacter = TRUE,
         driver = "ESRI Shapefile")



