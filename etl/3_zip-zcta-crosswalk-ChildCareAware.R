library(tidyverse)
library(janitor)
library(readxl)
library(tidycensus)
library(here)
library(sf)
library(tmap)
# The code below caches the zip code tabulation data we want from the Census 
options(tigris_use_cache = TRUE)


### LOAD IN DATA ###
# Clean ChildCareAware data
childcare_zips <- read_csv(here("data","processed", "ChildCareAware_cleaned.csv")) %>% 
  mutate(zip = as.character(zip)) 

  
# Zip code to zcta crosswalk file from UDS Mapper 
zip_zcta_crosswalk <- read_excel(here("data", "raw", "ZIPCodetoZCTACrosswalk2021UDS.xlsx"), sheet = 1) %>% 
  clean_names()


# ACS data for each zcta from 2017-2021 five year ACS
pop_zcta_5acs <- read_csv(here("data", "processed", "pop_zcta_5acs.csv")) %>% 
  select(GEOID, pop_5_and_under)

### JOIN CROSSWALK DATA ###
# We have to crosswalk data because zip codes just post office points and lines, what we really want are zctas, which are geoms supported by the Census 
# With zctas, we can safely map the data and connect it to demographic information 

# Filter UDS crosswalk data to just the state of Missouri 
# There are unique 1023 zctas and 1154 unique zip codes in MO. These also include PO boxes
mo_crosswalk <- zip_zcta_crosswalk %>% 
  filter(state == "MO") 

# Every zip code in the data from ChildCareAware is matched to a ZCTA from UDS 2021 crosswalk
crosswalk_join <- childcare_zips %>% 
  inner_join(mo_crosswalk, by = c("zip" = "zip_code")) 

# Now let's give each observation a 5 year acs value
# Condenses 3873 zip code observations to 3849 zcta observations 
acs_join <- crosswalk_join %>% 
  group_by(zcta, year, month) %>% 
  summarize_at(c("childcare_programs", "programs_accepting_subsidies", "licensed_capacity"), sum) %>% 
  inner_join(pop_zcta_5acs, by = c("zcta" = "GEOID"))


### EXPORT DATA FOR MAPPING AND ANALYSIS ### 
write.csv(acs_join, "data/processed/ChildCareAware_cleaned_and_crosswalked.csv")
