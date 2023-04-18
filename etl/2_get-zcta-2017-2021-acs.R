library(tidyverse)
library(tidycensus)
library(here)
# The code below caches the zip code tabulation data we want from the Census 
options(tigris_use_cache = TRUE)


# Get population estimates for 2017-2021 5-year ACS by 5 years old, 3 and 4 years old, and under 3 years then sum together
pop_zcta <- get_acs(geography = "zcta", variables = c("B09001_005", "B09001_004", "B09001_003")) %>% 
  group_by(GEOID) %>% 
  summarize(pop_5_and_under = sum(estimate))

write.csv(pop_zcta, "data/processed/pop_zcta_5acs.csv")
