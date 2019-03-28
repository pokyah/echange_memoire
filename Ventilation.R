# PACKAGES NEEDED

# install.packages ("readxl")
# install.packages ("sf")
# install.packages ("raster")
# install.packages("spData")
# install.packages ("devtools")
# devtools::install_github("Nowosad/spDataLarge")


library ("readxl")
library ("sf")
library ("sp")
library ("spData")
library ("raster")

Bureaux <- read.csv( "./data_raw/bureaux.csv" , header = TRUE , sep = ";" )

# librairie pour spReapportion
library(spReapportion)

#les données utilisées
data(ParisPollingStations2012)
data(ParisIris)
data(RP_2011_CS8_Paris)

# La ventilation
CS_ParisPollingStations <- spReapportion(ParisIris, ParisPollingStations2012, RP_2011_CS8_Paris, "DCOMIRIS", "ID", "IRIS")


#################################################### Pour vérifier 1 ###################################################


# librairies pour pouvoir vérifier que la ventilation a bien fonctionnée
library(tmap)
library(tmaptools)
library(dplyr)

# Transforme les données en pourcentage pour ploter après
RP_2011_CS8_Paris <- RP_2011_CS8_Paris %>%
  mutate_at(vars(C11_POP15P_CS1:C11_POP15P_CS8), funs(. / C11_POP15P * 100))

# ajoute les données dans un spdf
RP_2011_CS8_Paris <- RP_2011_CS8_Paris %>%
  +     mutate_at(vars(C11_POP15P_CS1:C11_POP15P_CS8), funs(. / C11_POP15P * 100))

# vérifier que les clefs correspondent
ParisIris <- append_data(ParisIris, RP_2011_CS8_Paris, key.shp = "DCOMIRIS", key.data = "IRIS")

# afficher une carte test
tm_shape(ParisIris) +
  +     tm_fill(col = "C11_POP15P_CS3", palette = "Blues", style = "quantile", n = 6, title = "Independent workers") +
  +     tm_borders()

#################################################### Pour vérifier 1 ###################################################



#################################################### ventilation Résultats ###################################################
#################################################### ventilation Résultats ###################################################
#################################################### ventilation Résultats ###################################################

# Introduire les données des résultats des élections 2017 par bureaux de vote
EP2017 <- read_delim("~/Documents/MA2/Mémoire/Memoire_V1/data_raw/EP2017.csv", 
                     +     ";", escape_double = FALSE, col_types = cols(`Code Insee` = col_character(), 
                                                                        +         X1 = col_skip()), trim_ws = TRUE)

# spReaportion sur les résultats des élections 2017
EP_ParisPollingStations <- spReapportion(ParisIris, ParisPollingStations2012, EP2017, "DCOMIRIS", "ID", "Code Insee")

#################################################### Pour vérifier 2 ###################################################


