################################################################################
# PROGRAM NAME:    100_tract_population
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To pull tract total population and population in poverty 
#                  estimates from American Community Survey 5-year estimates
################################################################################

library(tidycensus)
library(tidyr)
library(dplyr)
library(purrr)

# Set name of file to be output at the end of the script
tract_pop_file <- "./output/tract_population.csv"


################################################################################
#  Step 1: Set input parameters
################################################################################

# Need to add your own Census API key below
census_api_key("22c3b2e2538dd22d66c03c745f011d4fa1bc5bcf")
us <- unique(fips_codes$state)[1:51]
years <- 2016

################################################################################
#  Step 2: Pull ACS data
################################################################################

# This is a function that has a nested function within it. The nested function 
# that starts with map_df basically says to get all ACS data for all counties 
# in the states included in the "us" vector. We can then use lapply to apply 
# the main function (get_all_acs) to all years for which we want ACS data (i.e.
# all years in the "years" vector)

get_all_acs <- function(y) { 
  map_df(us, function(x) {
    get_acs(geography = "tract", 
            year = y, 
            variables = c(total_population = "B01003_001",
                          total_pop_in_poverty = "B17001_002"),
            survey = "acs5", 
            state = x)
  })
}

# Use lapply to apply the function to all years  This will return a list and 
# so we will need to turn it into a data frame below
all_acs <- lapply(years, get_all_acs)

all_acs_final <- map_df(all_acs, ~as.data.frame(.x)) %>%
  dplyr::select(-c(moe, NAME)) %>%
  spread(variable, estimate)

################################################################################
#  Step 3: Output file
################################################################################

# Output files 

write.csv(all_acs_final, file = tract_pop_file, row.names = FALSE)

# remove all files
rm(list = ls())
