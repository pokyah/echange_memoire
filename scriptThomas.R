load("./data_raw/ParisPollingStations2012.rda")
load("./data_raw/ParisIris.rda")
load("./data_raw/RP_2011_CS8_Paris.rda")

library(dplyr)

# convert to sf
ParisIris = sf::st_as_sf(ParisIris)
ParisPollingStations2012 = sf::st_as_sf(ParisPollingStations2012)

# plot the maps
mapview::mapview(ParisIris)
mapview::mapview(ParisPollingStations2012)

# read excel
bureaux <- readr::read_delim("./data_raw/secteurs-des-bureaux-de-vote.csv", ";", escape_double = FALSE, trim_ws = TRUE)

# splitting the geo_point_2d in to columns lon and lat
bureaux = bureaux %>%
  tidyr::separate(geo_point_2d, c("lat", "lon"), ",") %>%
  dplyr::mutate_at(vars(c("lon","lat")), funs(as.numeric)) %>%
  dplyr::select(-one_of("geo_shape"))

# making it a sf 
bureaux_sf = sf::st_as_sf(bureaux, coords = c("lon", "lat"))
bureaux_sf = sf::st_set_crs(bureaux_sf, 4326)

# view it on a map
mapview::mapview(bureaux_sf)

# convert to sp
bureaux_sp = as(bureaux_sf, "Spatial")

# loading bureaux de vote geojson into a sf
bureaux_geo_sf = sf::st_read("./data_raw/bureaux-de-votes.geojson.json")

# 
bureaux_sf = bureaux_sf %>%
  dplyr::rename("id_bv" = "Identifiant du bureau de vote") %>%
  sf::st_join(bureaux_geo_sf)


head(bureaux_sf)

head(bureaux_geo_sf)
head(data.frame(bureaux))

temp = 


