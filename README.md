# Analysis of Missouri child care deserts 

This repository contains data and findings for an ongoing collaboration between MuckRock and The Missouri Indepedent on Missouri's "child care deserts", areas where there are more than three children under the age of 5 for every licensed child care slot or no licensed slots at all. 

The findings in the article [Missouri child care deserts now include nearly half of kids 5 and under](link to article) are summarized in the file [`analysis/findings.qmd`](analysis/findings.qmd). 


## Data 
### Supply of Missouri child care programs
- The "supply" of child programs, [`data/raw/ChildCareAware_nov_2019_mar_2023`](data/raw/ChildCareAware_nov_2019_mar_2023.xlsx), was determind by the licensed capacity of programs by zip code, through data provided by the advocacy group [Child Care Aware](https://mochildcareaware.org/) who has pulled data from [Missouri’s active facility list](https://dese.mo.gov/media/file/active-facility-list-04012023) since 2019

### Demand for Missouri child care 
- The demand for child care was determind by the number of children five and under by Zip Code Tabulation Area, using American Community Survey 5-Year Data (2017-2021). This methodology is similiar to the one used by [Child Care Aware Missouri](https://mochampionofchildren.com/caredeserts/) and in [child care research more broadly](childcareaccess.org/methods/)
- ACS data was pulled using the `tidycensus` package in [`etl/2_get-zcta-2017-2021-acs`](etl/2_get-zcta-2017-2021-acs.R) and stored in [`processed/pop_zcta_5acs`](processed/pop_zcta_5acs.csv)

### Pandemic funding and grant applications 
- Through public records requests, MuckRock and The Missouri Indepedent recieved data on every application through seven grants in two federal COVID-19 relief programs — the Biden administration’s American Rescue Plan (ARPA) and the Coronavirus Response and Relief Supplemental Appropriations Act of 2021 (CRRSA)
- The raw data for each application can be found in [`data/raw`](`data/raw`) with ARPA and CRRSA precedending the grant type, as in `ARPA Paycheck Protection Round 3 with Paid`


## Methodology 
- Supply of Missouri child care programs by zip code was crosswalked to supply by ZCTA using [the popular UDS crosswalk](https://udsmapper.org/zip-code-to-zcta-crosswalk/) in [`etl/3_zip-zcta-crosswalk-ChildCareAware`](etl/3_zip-zcta-crosswalk-ChildCareAware.R). This is necessary to both map the data and to join the data to ACS population estimates, which are in ZCTA format, not ZIP. 
- ZCTA-level supply was joined to demand (ACS estimates of population) in [`etl/4_append_all_pop_to_ChildCareAware`](etl/4_append_all_pop_to_ChildCareAware.R)
- Grant applications with the address of each facility were cleaned and crosswalked to ZCTAs in [`etl/5_clean-relief-data`](etl/5_clean-relief-data.R). Several addresses had incorrect zip codes and these were manually changed by searching the address on Google Maps, after which each application's unique ID was marked in the code and commenting as zip code that was manually corrected. 
- The file [`analysis/findings.qmd`](analysis/findings.qmd) brings these sources of data together to map ZCTA areas that qualify as child care deserts and assess whether funding from the grants we tracked went to those areas. 


## Questions / Feedback
Contact Dillon Bergin at dillon@muckrock.com
