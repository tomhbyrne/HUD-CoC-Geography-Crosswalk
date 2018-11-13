################################################################################
# PROGRAM NAME:    200_tract_coc_match
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.ed)
# PROGRAM PURPOSE: To conduct geospatial match of Census tracts and 2017 HUD 
#                  Continuums of Care (CoCs) based on tract centroid points
################################################################################

library(data.table)
library(tigris)
library(stringr)
library(tidycensus)
library(sp)
library(rgdal)
library(dplyr)
library(tidyr)
library(maptools)
library(PBSmapping)
library(stringr)
library(sf)
library(rgeos)
library(car)
library(raster)
library(sf)
library(nngeo)

# Set name of file to be output at end of script

tract_coc_output <- "./output/tract_coc_match.csv"

################################################################################
#  Step 1: Read in necessary data
################################################################################

#     1) Tract shapefile
#     2) CoC shapefile
#     3) 2017 PIT data
#     4) Tract population 


# 1) Tigerline tract shapefile from Census (clipped to CoC boundaries)


tract <- readOGR(dsn = "./output", layer = "clipped_tract")

# also read in non-clipped file to add clipped tracts (i.e. those tracts that
# are not part of a CoC later)

tract_no_clip <-  readOGR("./data/tlgdb_2017_a_us_substategeo.gdb/tlgdb_2017_a_us_substategeo.gdb", 
                          "Census_Tract")

tract_no_clip_df <- tract_no_clip@data[c("GEOID", "NAMELSAD", "ALAND", "AWATER")] 

# 2)  CoC shapefile from HUD

cocs <- readOGR("./data/CoC_GIS_NatlTerrDC_Shapefile_2017/FY17_CoC_National_Bnd.gdb", 
                "FY17_CoC_National_Bnd")

# 3) 2017 PIT data from HUD
#    Change variiable names as needed to match shapefile.
#    Create flag for CoCs being in PIT. Also recode names
#    of 1 CoCs in 2017 PIT file to match how it is named
#    in shapefile 

pit_2017 <- read.csv("./data/2017_pit.csv", stringsAsFactors = FALSE) %>%
  mutate(COCNUM = CoC.Number,
         CoC_Name_PIT = CoC.Name,
         in_2017_PIT = "Yes",
          COCNUM = ifelse(COCNUM == "MO-604a", "MO-604", COCNUM)) %>%
  dplyr::select(COCNUM,
         CoC_Name_PIT,
         in_2017_PIT)


# 4) Tract population
#    File previously created by program 100_tract_population.R

tract_population <- read.csv("./output/tract_population.csv", stringsAsFactors =  FALSE)

# Add leading zero to GEOID on tract file 

tract_population$GEOID <- str_pad(tract_population$GEOID, 11, pad = "0")

################################################################################
#  Step 2:Convert tract shapefile to points for matching with CoCs 
################################################################################

# We will use a handy function (gCentroidWithin) for extracting polygon centroid 
# points accouting for when centroid falls outside of polygon (e.g. if polygon is 
# moon shaped)  The function is taken from a Stackoverflowpost: 
# https://stackoverflow.com/questions/44327994/calculate-centroid-within-inside-a-spatialpolygon

set.seed(3456)
gCentroidWithin <- function(pol) {
  require(rgeos)

  pol$.tmpID <- 1:length(pol)
  # initially create centroid points with gCentroid
  initialCents <- gCentroid(pol, byid = T)
  
  # add data of the polygons to the centroids
  centsDF <- SpatialPointsDataFrame(initialCents, pol@data)
  centsDF$isCentroid <- TRUE
  
  # check whether the centroids are actually INSIDE their polygon
  centsInOwnPoly <- sapply(1:length(pol), function(x) {
    gIntersects(pol[x,], centsDF[x, ])
  })
  # substitue outside centroids with points INSIDE the polygon
  newPoints <- SpatialPointsDataFrame(gPointOnSurface(pol[!centsInOwnPoly, ], 
                                                      byid = T), 
                                      pol@data[!centsInOwnPoly,])
  newPoints$isCentroid <- FALSE
  centsDF <- rbind(centsDF[centsInOwnPoly,], newPoints)
  
  # order the points like their polygon counterpart based on `.tmpID`
  centsDF <- centsDF[order(centsDF$.tmpID),]
  
  # remove `.tmpID` column
  centsDF@data <- centsDF@data[, - which(names(centsDF@data) == ".tmpID")]
  
  cat(paste(length(pol), "polygons;", sum(centsInOwnPoly), "actual centroids;", 
            sum(!centsInOwnPoly), "Points corrected \n"))
  
  return(centsDF)
}


tract_centroids <- gCentroidWithin(tract)

# Convert to dataframe
tract_centroids_final <- as.data.frame(tract_centroids)

coordinates(tract_centroids_final) <- c("x", "y")

# Assign coordinate reference system (CRS) to shapefile to match CoC CRS 

proj4string(tract_centroids_final) <- CRS("+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs")

################################################################################
#  Step 3:  Match tract centroids to Cocs in which they are located
################################################################################
tr_coc <- over(tract_centroids_final, cocs)

# Extract data frame from points polygon
tract_df <- data.frame(tract_centroids_final@data)

# Add tract IDS to CoC-tract dataset and get rid of unnecessary colums
# Create a flag for CoCs that are in the HUD shapelie
tract_coc_join <- cbind(tr_coc, tract_df) %>%
  dplyr::select(-c(Shape_Length, isCentroid, INTPTLON, INTPTLAT,  ALAND, AWATER)) %>%
  mutate(in_shapefile = "Yes")

################################################################################
#  Step 4:  Merge in 2017 PIT data to identify CoCs that are not in PIT, 
#   but not shapefile, and vice versa.  
#   Also, add in tracts that were clipped out when clipping tracts to CoC 
#   boundaries and add in tract population and pop.
#   in poverty from American Community Survey
################################################################################

non_clipped_tracts <- data.frame(GEOID = tract_no_clip@data$GEOID)

all_tracts <- full_join(tract_coc_join, non_clipped_tracts, by = "GEOID")


tract_coc_final <- full_join(all_tracts, pit_2017, by = "COCNUM") %>%
  mutate(in_shapefile = ifelse(is.na(in_shapefile), "No", in_shapefile),
         in_shapefile = ifelse(is.na(COCNUM), NA, in_shapefile),
         in_2017_PIT  = ifelse(is.na(in_2017_PIT), "No", in_2017_PIT),
         in_2017_PIT  = ifelse(is.na(COCNUM), NA, in_2017_PIT)) %>%
  left_join(., tract_population, by = "GEOID") %>%
  dplyr::select(COCNUM, COCNAME, CoC_Name_PIT, GEOID, in_shapefile, in_2017_PIT, 
         total_population, total_pop_in_poverty)

# Rename columns
names(tract_coc_final) <- c("coc_number", 
                            "coc_name", 
                            "coc_name_PIT", 
                            "tract_fips", 
                            "in_2017_shapefile", 
                            "in_2017_PIT", 
                            "total_population", 
                            "total_pop_in_poverty")

################################################################################
#  Step 5:  Output file 
################################################################################
write.csv(tract_coc_final, file = tract_coc_output, row.names = FALSE)

# remove all files
rm(list = ls())
