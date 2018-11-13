################################################################################
# PROGRAM NAME:    400_county_coc_match
# PROGRAM AUTHOR:  Tom Byrne (tbyrne@bu.edu)
# PROGRAM PURPOSE: To conduct match of U.S. counties and 2017 HUD 
#                  Continuums of Care (CoCs) based on tract-CoC match
################################################################################

library(dplyr)
library(tidyr)
library(stringr)

# Set name of file to be output at end of script

county_coc_output <- "./output/county_coc_match.csv"

################################################################################
#  Step 1: Read in necessary data
################################################################################

# 1) Previously created tract-CoC match

tract_coc_final <- read.csv("./output/tract_coc_match.csv", stringsAsFactors =  FALSE)


# Add leading zeroes to tract fips

tract_coc_final$tract_fips <- str_pad(tract_coc_final$tract_fips, 11, pad = "0")

# Extract county fips code from tract id
tract_coc_final$county_fips <- substr(tract_coc_final$tract_fips, 1, 5)

# Create file of distinct counties for later use 

counties <- distinct(tract_coc_final, county_fips)

################################################################################
#  Step 2: Create county-CoC matches
################################################################################

# To create county-CoC match, we will first create dataframe that
# keeps all distinct county-CoC matches. 

county_coc <- tract_coc_final %>%
  # Filter out tracts that didn't match to a CoC
  filter(!(is.na(coc_number))) %>%
  distinct(coc_number, county_fips, .keep_all = TRUE) %>%
  dplyr::select(county_fips,
                coc_number,
                coc_name, 
                coc_name_PIT, 
                in_2017_shapefile,
                in_2017_PIT, 
                coc_name_PIT)


coc_pop <- tract_coc_final %>%
  group_by(coc_number, county_fips) %>%
  summarize(p1 = sum(total_population, na.rm = T))

county_pop <- tract_coc_final %>%
  group_by(county_fips) %>%
  summarize(county_pop = sum(total_population, na.rm = T))


# Next, we will collapse the distinct county-CoC combinations to identify
# the number of counties that are in (either partially or totally) each CoC

one_coc_mult_counties <- county_coc %>%
  group_by(coc_number) %>%
  summarize(n_counties_in_coc = n()) 

# Now, we will collapse counties to identify counties that match to mutliple 
# Cocs

one_county_mult_cocs <- county_coc %>%
  group_by(county_fips)  %>%
  summarize(n_cocs_in_county = n())

################################################################################
#  Step 3: Calculate % of county pop in each CoC 
################################################################################
county_coc_pop <- tract_coc_final %>%
  group_by(county_fips, coc_number) %>%
  summarize(t_pop = sum(total_population, na.rm = T),
            pov_pop = sum(total_pop_in_poverty, na.rm = T)) %>%
  group_by(county_fips) %>%
  mutate(pct_cnty_pop_coc = t_pop / sum(t_pop, na.rm = T) * 100,
         pct_cnty_pov_coc = pov_pop / sum(pov_pop, na.rm  =T) * 100) %>%
  dplyr::select(county_fips, coc_number, pct_cnty_pop_coc, pct_cnty_pov_coc)



################################################################################
#  Step 4: Join all datasets together and output file
################################################################################

county_coc_final <- county_coc %>%
  left_join(one_county_mult_cocs, by = "county_fips") %>%
  left_join(one_coc_mult_counties, by = 'coc_number') %>%
  mutate(mult_county_mult_coc = ifelse(n_cocs_in_county > 1 & n_counties_in_coc > 1, 1, 0)) %>%
  mutate(rel_type = ifelse(n_cocs_in_county == 1 & n_counties_in_coc ==1, 1,
                           ifelse(n_counties_in_coc > 1 & n_cocs_in_county == 1, 2,
                                  ifelse(n_cocs_in_county > 1 & n_counties_in_coc == 1, 3,4)))) %>%
  # join in distinct counties to flag counties that don't match to a CoC
  left_join(counties, ., by = "county_fips") %>%
  left_join(., county_coc_pop, by = c("county_fips", "coc_number"))


write.csv(county_coc_final, county_coc_output, row.names = FALSE)

# remove all files
rm(list = ls())



            

