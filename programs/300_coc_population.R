################################################################################
# PROGRAM NAME:    300_coc_population
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.ed)
# PROGRAM PURPOSE: To calculate total population and total population in povery
#                  in HUD CoCs
################################################################################

library(dplyr)
library(tidyr)

# Set name of file to be output at end of script

coc_pop_output <- "./output/coc_population.csv"

################################################################################
#  Step 1: Read in necessary data
################################################################################

# 1) Previously created tract-CoC match

tract_coc <- read.csv("./output/tract_coc_match.csv", stringsAsFactors =  FALSE)

################################################################################
#  Step 2: Sum population by CoC
################################################################################

# Set places with 0 people to missing as pop data were not available for those
# CoCs because they did not match to tracts either because they were not in
# HUD shapefile, or were from places (e.g. Virgin Islands) that weren't in 
# tract shapefile 
# Drop row that is for tracts that didn't match to a CoC and thuhs having
# a missing value for coc number

coc_population <- tract_coc %>%
  group_by(coc_number) %>%
  summarize(total_population = sum(total_population, na.rm = T),
            total_pop_in_poverty = sum(total_pop_in_poverty, na.rm = T)) %>%
  mutate(total_population = ifelse(total_population == 0, NA, total_population),
         total_pop_in_poverty = ifelse(total_pop_in_poverty == 0, NA, total_pop_in_poverty)) %>%
  filter(!(is.na(coc_number)))

################################################################################
#  Step 2: Output file
################################################################################
write.csv(coc_population, file = coc_pop_output, row.names = FALSE)

# remove all files
rm(list = ls())
