library(tidyverse)
library(tidycensus)
library(janitor)
library(readxl)
library(here)
# The code below caches the zip code tabulation data we want from the Census 
options(tigris_use_cache = TRUE)

# Check out variables for 2017-2021 5-year ACS and find the ones we want
# These variables are part of the grouping "Population Under 18 Years by Age"
variables <- load_variables(2021, "acs5", cache = TRUE) %>% 
  filter(name %in% c("B09001_005","B09001_004", "B09001_003"))

# Get population estimates for 2017-2021 5-year ACS by 5 years old, 3 and 4 years old, and under 3 years then sum together
pop_zcta <- get_acs(geography = "zcta", variables = c("B09001_005", "B09001_004", "B09001_003")) %>% 
  group_by(GEOID) %>% 
  summarize(pop_5_and_under = sum(estimate))

# Write to CSV for analysis later 
write.csv(pop_zcta, "data/processed/pop_zcta_5acs.csv")

# Fact-checking
# To fact check these numbers and be sure I pulled the correct variables, I compare them to Census Quick Facts
# The Quick facts are vintage 2022 ACS https://www.census.gov/quickfacts/MO

under_five_pop <- get_acs(geography = "zcta", variables = c("B09001_004", "B09001_003")) %>% 
  group_by(GEOID) %>% 
  summarize(pop = sum(estimate))

five_pop <- get_acs(geography = "zcta", variables = c("B09001_005")) %>% 
  group_by(GEOID) %>% 
  summarize(pop = sum(estimate))

# Zip code to zcta crosswalk file from UDS Mapper 
zip_zcta_crosswalk <- read_excel(here("data", "raw", "ZIPCodetoZCTACrosswalk2021UDS.xlsx"), sheet = 1) %>% 
  clean_names()

# Filter UDS crosswalk data to just the state of Missouri 
# There are unique 1023 zctas and 1154 unique zip codes in MO. These also include PO boxes
mo_crosswalk <- zip_zcta_crosswalk %>% 
  filter(state == "MO") 

# Sum of population five years old in MO is 75271
five_pop_crosswalk_join <- five_pop %>% 
  inner_join(mo_crosswalk, by = c("GEOID" = "zip_code"))

# Sum of population under five years old in MO is 367103
under_five_pop_crosswalk_join <- under_five_pop %>% 
  inner_join(mo_crosswalk, by = c("GEOID" = "zip_code"))

# Census Quick Facts place total state pop at 6,177,957 and children under five at 5.8 percent of that, or 358,321 children under five
# Our pull places 367,103 under five which general lines up

