library(tidyverse)
library(janitor)
library(readxl)
library(here)

# This script takes the wide excel spreadsheet we received from ChildCareAware and cleans it into a long, tidy dataframe
# It then checks that dataframe for valid zips based on two data sources for updated MO zip codes 
# In the end, 12 observations out 3,885 are removed (amounting to to 12 childcare programs in total) because the zip doesn't seem 
# to mach the most updated lists of MO zip codes. Removing these faulty zip codes now will also to crosswalk and map later


# Read in ChildCareAware data sent to us by Michael Austrin of ChildCareAware
df <- read_excel(here("data", "raw", "ChildCareAware_nov_2019_mar_2023.xlsx"), sheet = 2)

# Load data [from MO open data portal](https://data.mo.gov/Geography/Missouri-Zip-Codes-by-County-City/im7g-fucq) with zip codes
state_zips <- read_csv(here("data", "raw", "Missouri_Zip_Codes_by_County_City.csv")) %>% 
  clean_names() %>% 
  mutate(zip_code = as.character(zip_code)) %>% 
  select(zip_code, city, county)

# Load data from MO [department of insurance](https://insurance.mo.gov/industry/zips.php) with some updated zips 
updated_zips <- read_excel(here("data", "raw", "Missouri_Zip_Codes.xlsx")) %>% 
  clean_names()

# Combine zips together so we have a comprehensive list of all valid zips 
all_zips <- rbind(updated_zips, state_zips)


# Set column names for tidy data frame 
col_names <- c("zip", "childcare_programs", "licensed_capacity", "programs_accepting_subsidies", "children_under_six")

# Restructure each month-year to be a single dataframe and then bind them all together 
tidy_df <- rbind(
  nov_2019 <-  df[,1:5] %>% 
    slice(-1) %>% 
    set_names(col_names) %>% 
    mutate(month = "November", year = "2019") ,
  mar_2020 <- df[,6:10] %>% 
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "March", year = "2020"),
  sep_2020 <- df[,11:15] %>% 
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "September", year = "2020"),
  mar_2021 <- df[,16:20] %>%
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "March", year = "2021"),
  sep_2021 <- df[,21:25] %>% 
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "September", year = "2021"),
  mar_2022 <- df[,26:30] %>% 
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "March", year = "2022"),
  sep_2022 <- df[,31:35] %>%
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "September", year = "2022"),
  mar_2023 <- df[,36:40] %>% 
    slice(-1) %>% 
    set_names(col_names) %>%
    mutate(month = "March", year = "2023")
) %>% 
  mutate_at(c("childcare_programs", "licensed_capacity", "programs_accepting_subsidies", "children_under_six"), as.numeric) %>% 
  filter(!zip == "Grand Total") 

# Get rid of any zips that don't match the states list of valid zip codes, because these may data entry errors 
clean_and_tidy_df <- tidy_df %>% 
  filter(zip %in% all_zips$zip_code)
  
# The problem zips cause us to lose data from 12 programs 
problem_zips <- tidy_df %>% 
  filter(!zip %in% all_zips$zip_code) %>% 
  group_by(zip) %>% 
  summarize(programs = sum(childcare_programs))

write.csv(clean_and_tidy_df, "data/processed/ChildCareAware_cleaned.csv")
