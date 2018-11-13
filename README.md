# HUD-CoC-Geography-Crosswalk

This project creates a geographic crosswalk between 2017 U.S. Department of Housing and Urban Development (HUD) Continuum of Care (CoC) boundaries and 2017 U.S. Census Bureau geographies (Census tracts and counties).

If using any of the files from this project for published work, please cite this Github repository as their source.  

In describing the methodology used to match counties and CoCs, please also cite [the original paper](https://www.tandfonline.com/doi/abs/10.1111/j.1467-9906.2012.00643.x) that describes the basic methodology used in conducting the county-CoC geographic crosswalk. 


Please bring any errors/questions/suggestions to the attention of this project's creator, Tom Byrne, at [tbyrne@bu.edu](tbyrne@bu.edu) 

## Project description 

Below we describe the main __outputs__ of this project, as well as its __data__ inputs and __programs__ used to create the __outputs__. 

## Outputs 
There are three main output files from this project: 
 
1. __tract_coc_match.csv__: This is a geographic crosswalk that matches each Census tract to a CoC. There is one row for each Census tract.  Note that not all Census tracts match to a CoC.

2. __county_coc_match.csv__: This is a geographic crosswalk that matches counties to CoCs.  CoCs can match to multiple counties, and a single county can match to each CoC.  Thus, the file has one row for each unique county-CoC combination. Note that not all counties match to a CoC. 

3. __coc_population.csv__:  This is a file that includes the total population and total population in poverty for each CoC.  These files are based on tract level total population and total population in poverty estimates from the U.S. Census Bureau's American Community Survey 2011-2016 5-Year Estimates

There are also two intermediary output files:

1. __clipped_tract.shp__: This is a version of the U.S. Census Bureau TIGER/Line census tract boundary shapefile that is clipped to the HUD CoC boundary shapefile.  The reason for doing this is that the CoC shapefile is clipped to the shoreline, while the tract boundary file is not. As such, our approach for matching tracts to CoCs will incorrectly omit Census tracts if we do not first clip the tract boundaries.

2. __tract_population.csv__: This file includes Census tract estimates of the total population and total population in poverty from the U.S. Census Bureau's American Community Survey 2011-2016 5-Year Estimates. 

## Data
The above described outputs are created using the following inputs:

1. __CoC_GIS_NatlTerrDC_Shapefile_2017.gdb__: A shapefile of the 2017 HUD CoC boundaries.  This file was obtained from [this HUD website](https://www.hudexchange.info/programs/coc/gis-tools/)  

2. __tlgdb_2017_a_us_substategeo.gdb__: The 2017 TIGER/Line Census tract shapefile.  This file was obtained from [this Census Bureau website](https://www.census.gov/cgi-bin/geo/shapefiles/index.php)

3. __2017_pit.csv__: The 2017 HUD Point-in-Time (PIT) count data.  This file was obtained from [this HUD website](https://www.hudexchange.info/resource/3031/pit-and-hic-data-since-2007/)

## Programs 

The outputs described above were created using data described above via the following programs:

1. __000_clip_tract_shapefile__: This program clips the TIGER/Line tract shapefile to the CoC boundary shapefile.  It produces the __clipped_tract.shp__ file.

2. __100_tract_population__: This program uses the tidycensus package to pull Census tract population and population and poverty estimates directly from the U.S. Census Bureau's API. It produces the __tract_population.csv__ output file 

3. __200_tract_coc_match__:  This program creates a geographic crosswalk between Census tracts and CoCs. To do this, it overlays tract centroid points (i.e. points representing the geographic center of each Census tract) onto CoC boundaries and matches each Census tract to the CoC into which its centroid falls. It produces the __tract_coc_match.csv__ output file

4. __300_coc_population__:  This program creates estimates of the total population and total population in poverty in each CoC.  It does this based on the __tract_coc_match.csv__ file and produces the __coc_population.csv__ shapefile

5. __400_county_coc_match__: This program creates a geographic crosswalk between counties and CoCs. It does this based on the __tract_coc_match.csv__ file and produces the __county_coc_match.csv__ output.

5. __500_run_all_pograms__:  This program runs simply calls each of the above programs in sequence. 

