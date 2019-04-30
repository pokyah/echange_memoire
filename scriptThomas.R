devtools::install_github("joelgombin/spReapportion")

#bureaux_spdf <- readRDS("~/Documents/code/pokyah/echange_memoire/bureaux_spdf.rds")

library(dplyr)
library(spReapportion)
library(sf)

# 1. From https://github.com/joelgombin/spReapportion
data(ParisPollingStations2012)
data(ParisIris)
data(RP_2011_CS8_Paris)

ParisPollingStations2012.sf = st_as_sf(ParisPollingStations2012)
ParisIris.sf = st_as_sf(ParisIris)

CS_ParisPollingStations = spReapportion(
  old_geom = ParisIris,
  new_geom = ParisPollingStations2012,
  data = RP_2011_CS8_Paris,
  old_ID = "DCOMIRIS",
  new_ID = "ID",
  data_ID = "IRIS")

nrow(ParisIris.sf) # old_geom => 992
nrow(ParisPollingStations2012.sf) # new_geom => 867
nrow(RP_2011_CS8_Paris) # data => 992
nrow(CS_ParisPollingStations) # result spReapportion => 867

head(ParisIris.sf$DCOMIRIS) # old_geom
head(ParisPollingStations2012$ID) # new_geom
head(RP_2011_CS8_Paris$IRIS) # data
# [1] "751145620" "751145622" "751041301" "751166306" "751166304" "751166303"

# to see how the codes of the voting bureaux are structured
RP_2011_CS8_Paris$IRIS
summary(as.numeric(RP_2011_CS8_Paris$IRIS))

colnames(ParisIris.sf) # old_geom
colnames(ParisPollingStations2012.sf) # new_geom 
colnames(RP_2011_CS8_Paris) # data
colnames(CS_ParisPollingStations) # result spReapportion


# 2. NEW datasets

# # read excel
# codes = readr::read_delim("./data_raw/correspondances-code-insee-code-postal.csv", ";", escape_double = FALSE, trim_ws = TRUE)
# bureaux = readr::read_delim("./data_raw/secteurs-des-bureaux-de-vote.csv", ";", escape_double = FALSE, trim_ws = TRUE)
# # splitting the geo_point_2d in to columns lon and lat
# bureaux = bureaux %>%
#   tidyr::separate(geo_point_2d, c("lat", "lon"), ",") %>%
#   dplyr::mutate_at(vars(c("lon","lat")), funs(as.numeric)) %>%
#   dplyr::select(-one_of("geo_shape"))
# bureaux = data.frame(bureaux)
# # reading the secteurs of bureaux de vote geojson
# bureaux.sf = sf::st_read("./data_raw/bureaux-de-votes.geojson")

# reading the secteurs of bureaux_clean de vote geojson
bureaux_clean.sf = sf::st_read("./data_raw/bureaux_clean/bureaux_clean_shp_ID.shp")
nrow(bureaux_clean.sf)

# reading the elections results
EP_2017 = data.frame(readr::read_delim("data_raw/R_P_L_2_PI.csv", ",")) %>%
  dplyr::rename("id_bv" = "bureau") # this one looks better
nrow(EP_2017)

# retrieving the IRIS code for bureaux de vote using a spatial join (the two objects must be in the same CRS !)
correspondance.sf = sf::st_join(sf::st_transform(bureaux_clean.sf, 4326), sf::st_transform(ParisIris.sf, 4326)) %>%
  dplyr::select(one_of(c("id_bv", "DCOMIRIS")))
correspondance.df = correspondance.sf
sf::st_geometry(correspondance.df) = NULL
correspondance.df = unique(correspondance.df)
nrow(correspondance.df)

# adding the DCOMIRIS data to Ep_2017
EP_2017_test = EP_2017 %>%
  dplyr::inner_join(correspondance.df, by = "id_bv")

# joining spatial bureaux with bureaux data
bureaux_clean.sf = bureaux_clean.sf %>%
  dplyr::left_join(EP_2017, by = "id_bv")
nrow(bureaux_clean.sf)


CS_ParisPollingStations_new = spReapportion(
  old_geom = as(sf::st_transform(ParisIris.sf, 3812), "Spatial"),
  new_geom = as(sf::st_transform(bureaux_clean.sf, 3812), "Spatial"),
  data = EP_2017,
  old_ID = "DCOMIRIS",
  new_ID = "DCOMIRIS",
  data_ID = "DCOMIRIS")

nrow(ParisIris.sf) # old_geom => 992
nrow(bureaux.sf) # new_geom => 896
nrow(bureaux) # data => 896
nrow(CS_ParisPollingStations_new) # result spReapportion => 896


