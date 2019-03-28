load("~/Downloads/ParisPollingStations2012.rda")
load("~/Downloads/ParisIris.rda")

# convert to sf
ParisIris = sf::st_as_sf(ParisIris)
ParisPollingStations2012 = sf::st_as_sf(ParisPollingStations2012)

# plot the maps
mapview::mapview(ParisIris)
mapview::mapview(ParisPollingStations2012)

# read excel
bureaux <- read_delim("~/Documents/MA2/Mémoire/Memoire_V1/data_raw/secteurs-des-bureaux-de-vote.csv", 
                                           +     ";", escape_double = FALSE, trim_ws = TRUE)

# splitting the geo_point_2d in to columns lon and lat
bureaux = bureaux %>%
  + tidyr::separate(geo_point_2d, c("lat", "lon"), ",") %>%
  + dplyr::mutate_at(vars(c("lon","lat")), funs(as.numeric)) %>%
  + dplyr::select(-one_of("geo_shape"))

# making it a sf 
bureaux_sf = sf::st_as_sf(bureaux_sf, coords = c("lon", "lat"))

# view it on a map
mapview::mapview(bureaux_sf)

# convert to sp

bureaux_sp = as(bureaux_sf, "Spatial")


