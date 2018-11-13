This document summarizes the fields in each of the three main output files:

1. __tract_coc_match.csv__:
    -  _coc_number_: The 2017 HUD CoC Number
    -  _coc_name_: The 2017 HUD CoC Name
    -  _tract_fips_:  The 2017 Census Tract FIPS code.
    -  _in_2017_PIT_: A flag indicating whether a particular CoC is in the 2017 HUD Point in Time (PIT) count file.  This is necessary because there is a slight mismatch between the CoCs in the 2017 CoC boundary shapefile and the 2017 PIT count data. 
    - _total_population_: An estimate of the total population in each tract from the American Community Survey 2012-2016 5-Year Estimates
    -  _total_pop_in_poverty_: An An estimate of the total population in each tract with income below the poverty threshold from the American Community Survey 2012-2016 5-Year Estimates
    
2. __coc_population.csv__: 
    - _coc_number_: The 2017 HUD CoC Number
    - _total_population_: An estimate of the total population in each CoC based on estimates from the American Community Survey 2012-2016 5-Year Estimates.
    -  _total_pop_in_poverty_: An An estimate of the total population in each CoC with income below the poverty threshold based on estimates from the American Community Survey 2012-2016 5-Year Estimates.
    
3. __county_coc_match.csv__: 
    - _county_fips_: The 5-digit county FIPS code
    -  _coc_number_: The 2017 HUD CoC Number
    -  _coc_name_: The 2017 HUD CoC Name
    - _in_2017_shapefile_: A flag indicating whether a particular CoC is in the 2017 HUD boundary shapefile.  This is necessary because there is a slight mismatch between the CoCs in the 2017 CoC boundary shapefile and the 2017 PIT count data. 
    -  _in_2017_PIT_: A flag indicating whether a particular CoC is in the 2017 HUD Point in Time (PIT) count file.  This is necessary because there is a slight mismatch between the CoCs in the 2017 CoC boundary shapefile and the 2017 PIT count data.
    - _n_cocs_in_county_: The number of CoCs in which a county is partially (or completely) located
    - _n_counties_in_coc_: The number of counties that a given CoC partially (or completely) encompasses
    - _mult_county_mult_coc: A flag indicating whether the county-CoC combination in a given row represents both a CoC that encompasses multiple counties and a county that is partially located in multiple CoCs.  
    - _rel_type_: The relationship type of the county-CoC combination represented by each row.  The relationship types are as follows: 
        - __1__: The boundaries of a single CoC and a single county are coterminous.    
        - __2__: A CoC's boundary fully encompass multiple counties. 
        - __3__: A single county fully contains multiple CoCs. 
        - __4__: A CoC  is partially located in multiple counties and the counties in which it is located also contain parts of multiple CoCs.
    - _pct_cnty_pop_coc_ : For the county-CoC combination represented by each row, this field provides the % of the county's population that is located in the CoC
    - _pct_cnty_pov_coc_: For the county-CoC combination represented by each row, this field provides the % of the county's population in poverty that is located in the CoC.

    