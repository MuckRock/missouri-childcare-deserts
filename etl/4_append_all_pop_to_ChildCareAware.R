library(tidyverse)
library(janitor)
library(readxl)
library(tidycensus)
library(here)
library(sf)
library(tmap)
# The code below caches the zip code tabulation data we want from the Census 
options(tigris_use_cache = TRUE)


# 5 year ACS estimates pf population five and under for all zctas in the country
acs <- read_csv(here("data", "processed", "pop_zcta_5acs.csv"))

# Load all zctas not included in ChildCareAware survey 
# There are 1023 unique zctas in MO according to these crosswalk
mo_zctas <- read_excel(here("data", "raw", "ZIPCodetoZCTACrosswalk2021UDS.xlsx"), sheet = 1) %>% 
  clean_names() %>% 
  filter(state == "MO") %>% 
  distinct(zcta)

# Join MO ZCTAs with ACS data to catch zip codes with no providers but more than 50 children
all_provider_join <- mo_zctas %>% 
  left_join(acs, by = c("zcta" = "GEOID")) %>% 
  select(zcta, pop_5_and_under)

childcare_aware <- read_csv(here("data", "processed", "ChildCareAware_cleaned_and_crosswalked.csv")) %>% 
  mutate(zcta = as.character(zcta))


fall_2019 <- childcare_aware %>% 
  filter(year == 2019) %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2019") %>% 
  mutate(month = "November")

spring_2020 <- childcare_aware %>% 
  filter(year == 2020) %>% 
  filter(month == "March") %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2020") %>% 
  mutate(month = "March")

fall_2020 <- childcare_aware %>% 
  filter(year == 2020) %>% 
  filter(month == "September") %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2020") %>% 
  mutate(month = "September")

spring_2021 <- childcare_aware %>% 
  filter(year == 2021) %>% 
  filter(month == "March") %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2021") %>% 
  mutate(month = "March")

fall_2021 <- childcare_aware %>% 
  filter(year == 2021) %>% 
  filter(month == "September") %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2021") %>% 
  mutate(month = "September")

spring_2022 <- childcare_aware %>% 
  filter(year == 2022) %>% 
  filter(month == "March") %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2022") %>% 
  mutate(month = "March")

fall_2022 <- childcare_aware %>% 
  filter(year == 2022) %>% 
  filter(month == "September") %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under")) %>% 
  mutate(year = "2022") %>% 
  mutate(month = "September")

spring_2023 <- childcare_aware %>% 
  filter(year == 2023) %>% 
  right_join(all_provider_join, by = c("zcta", "pop_5_and_under"))  %>% 
  mutate(year = "2023") %>% 
  mutate(month = "March")


all <- rbind(fall_2019, spring_2020, fall_2020, spring_2021, fall_2021, spring_2022, fall_2022, spring_2023)

### EXPORT DATA FOR MAPPING AND ANALYSIS ### 
write.csv(all, "data/processed/childcare_supply_and_demand_2019_2023.csv")
