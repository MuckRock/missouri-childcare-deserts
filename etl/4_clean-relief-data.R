library(tidyverse)
library(janitor)
library(readxl)
library(here)
library(lubridate)


# Load in data 
# 426 observations total
# No status so all must be paid
arpa_training <- read_excel(here("data", "raw","ARPA Annual Training Costs with Paid.xlsx")) %>% 
  clean_names() %>% 
  select(request_number, facility_address_street_city_state_zip_code, paid_amount, signature_date) %>% 
  mutate(facility_address_street_city_state_zip_code = trimws(facility_address_street_city_state_zip_code)) %>% 
  mutate(zip = trimws(word(facility_address_street_city_state_zip_code, 5, sep = ","))) %>% 
  # There are variances in how the full addresses is recorded and a few edge cases the code below accounts for
  mutate(zip = case_when(zip == "MO" |zip == "ST. JOSEPH" ~ str_sub(facility_address_street_city_state_zip_code, -5),
                         # One mailing address and zip got swapped, so I'm hard coding it
                         # Hard coding will be marked with the unique ID for future fact-checking and reference
                         request_number == "E189-834" ~ "63031",
                         TRUE ~ zip)) %>% 
  mutate(zip = str_sub(zip, 1, 5)) %>% 
  mutate(type = "arpa_training") %>% 
  rename(amount = paid_amount) %>% 
  mutate(year = year(signature_date)) %>% 
  rename(id = request_number) %>% 
  select(id, zip, amount, type, year)
           
# 551 observations
# No status so all must be paid
arpa_paycheck_3 <- read_excel(here("data", "raw", "ARPA Paycheck Protection Round 3 with Paid.xlsx")) %>% 
  clean_names() %>%  
    select(request_number, facility_address_street_city_state_zip_code, paid_amount, signature_date) %>% 
    mutate(facility_address_street_city_state_zip_code = trimws(facility_address_street_city_state_zip_code)) %>% 
    mutate(zip = trimws(word(facility_address_street_city_state_zip_code, 5, sep = ","))) %>% 
  mutate(zip = case_when(zip == "MO" |zip == "ST. JOSEPH" ~ str_sub(facility_address_street_city_state_zip_code, -5),
                         # Another hardcoded data entry to recover error
                         request_number == "E973-956" ~ "63031",
                         TRUE ~ zip)) %>% 
    mutate(zip = str_sub(zip, 1, 5)) %>% 
    mutate(type = "arpa_paycheck_3") %>% 
    rename(amount = paid_amount) %>% 
    mutate(year = year(signature_date)) %>%
    rename(id = request_number) %>% 
    select(id, zip, amount, type, year)
 

# 582 observations 
# No status so all must be paid
arpa_retention <- read_excel(here("data", "raw", "ARPA Retention of Child Care Staff with Paid.xlsx")) %>% 
  clean_names() %>% 
  select(request_number, facility_address_street_city_state_zip_code, paid_amount, signature_date) %>% 
  mutate(facility_address_street_city_state_zip_code = trimws(facility_address_street_city_state_zip_code)) %>% 
  mutate(zip = trimws(word(facility_address_street_city_state_zip_code, 5, sep = ","))) %>% 
  mutate(zip = case_when(zip == "MO" |zip == "ST. JOSEPH" ~ str_sub(facility_address_street_city_state_zip_code, -5),
                         # Hardcoded
                         request_number == "P241-504" ~ "63031",
                         # Harcoded
                         request_number == "E582-132" ~ "65625",
                         TRUE ~ zip)) %>% 
  mutate(zip = str_sub(zip, 1, 5)) %>% 
  mutate(type = "arpa_retention") %>% 
  rename(amount = paid_amount) %>% 
  rename(id = request_number) %>%
  mutate(year = year(signature_date)) %>% 
  select(id, zip, amount, type, year)

# 832 observations and all are Paid
# Signature date is very messy, but all apps and signatures are in 2021, so we can just clear it that way
crrsa_paycheck_1 <-  read_excel(here("data", "raw", "CRRSA Paycheck Protection Round 1 with Paid.xlsx")) %>% 
  clean_names() %>% 
  filter(status == "Paid") %>% 
  mutate(facility_zip = str_sub(facility_zip, 1, 5)) %>% 
  # Three zips were written incorrectly. Harcoded like above
  mutate(facility_zip = case_when(facility_provider_dvn == "001833609" ~ "65536", 
                                   facility_provider_dvn == "001667665" ~ "64082", 
                                   facility_provider_dvn == "002415103" ~ "63115", 
                                   facility_provider_dvn == "001495029" ~ "63034",
                                   facility_provider_dvn == "002933295" ~ "63111",
                                   # One zip code was incorrect
                                   facility_provider_dvn == "000434757" ~ "63857",
                                   TRUE ~ facility_zip)) %>%    
  mutate(type = "crrsa_paycheck_1") %>% 
  rename(amount = amount_paid) %>% 
  rename(id = facility_provider_dvn) %>% 
  # All apps and signatures in 2021
  mutate(year = 2021) %>% 
  select(id, facility_zip, amount, type, year) %>% 
  rename(zip = facility_zip)
  
  
# 1231 observations
# No status so all must be paid
crrsa_paycheck_2 <-  read_excel(here("data", "raw", "CRRSA Paycheck Protection Round 2 with Paid.xlsx")) %>% 
  clean_names() %>% 
  select(request_number, facility_address_street_city_state_zip_code, paid_amount, signature_date) %>% 
  mutate(facility_address_street_city_state_zip_code = trimws(facility_address_street_city_state_zip_code)) %>% 
  mutate(zip = trimws(word(facility_address_street_city_state_zip_code, 5, sep = ","))) %>% 
  mutate(zip = case_when(zip == "MO" |zip == "ST. JOSEPH" ~ str_sub(facility_address_street_city_state_zip_code, -5),
                         # Four zip codes are missing and I hardcoded by request number
                         request_number == "E817-412" ~ "63760",
                         request_number == "E564-851" ~ "65625",
                         request_number == "E245-402" ~ "65051",
                         request_number == "E573-202" ~ "64465", 
                         # Two zip codes were incorrect 
                         request_number == "P304-368" ~ "63857",
                         request_number == "E789-621" ~ "63021", 
                         TRUE ~ zip)) %>% 
  mutate(zip = str_sub(zip, 1, 5)) %>% 
  mutate(type = "crrsa_paycheck_2") %>% 
  rename(id = request_number) %>%
  mutate(year = year(signature_date)) %>% 
  rename(amount = paid_amount) %>% 
  select(id, zip, amount, type, year)


# 613 observations, but only 264 are paid already 
# Signature data is messed up 
crrsa_startup_expansion <-  read_excel(here("data", "raw", "CRRSA Startup and Expansion with Paid.xlsx")) %>% 
  clean_names() %>%   
  filter(status == "Paid") %>% 
  mutate(physical_address_zip = str_sub(physical_address_zip, 1, 5)) %>%
  # Another city written for a zip, hardcoded in 
  mutate(physical_address_zip = case_when(dvn == "2915537" ~ "63141", TRUE ~ physical_address_zip)) %>% 
  mutate(type = "crrsa_startup_expansion") %>% 
  rename(amount = paid_amount) %>% 
  mutate(id = dvn) %>% 
  extract(signature_date, "year", "(\\d{4})", remove = FALSE, convert = TRUE) %>% 
  select(id, physical_address_zip, amount, type, year) %>%
  mutate(year = case_when(id == "2944425" ~ as.integer(2022), 
                          id == "2921977" ~ as.integer(2021),
                          id == "2909428" ~ as.integer(2021),
                          TRUE ~ year)) %>% 
  rename(zip = physical_address_zip)

  
  
# 920 observations, 813 are paid
# Signature dates are also broken 
crrsa_tech_asistance <-  read_excel(here("data", "raw", "CRRSA Technical Business Assistance with Paid.xlsx")) %>% 
  clean_names() %>% 
  filter(status == "Paid") %>% 
  mutate(facility_zip = str_sub(facility_zip, 1, 5)) %>% 
  mutate(facility_zip = case_when(facility_provider_dvn_1 == "002590736" ~ "64152", 
                                  facility_provider_dvn_1 == "002746443" ~ "63138",
                                  facility_provider_dvn_1 == "000180969" ~ "63136",
                                  TRUE ~ facility_zip)) %>% 
  mutate(type = "crrsa_tech_asistance") %>% 
  rename(amount = amount_paid) %>% 
  rename(id = facility_provider_dvn_1) %>% 
  extract(signature_date, "year", "(\\d{4})", remove = FALSE, convert = TRUE) %>% 
  # Manually fixing years by checking against application date
  mutate(year = case_when(id == "000181879" ~ as.integer(2022),
                          id == "002176318" ~ as.integer(2022),
                          id == "002444331" ~ as.integer(2022),
                          id == "002490442" ~ as.integer(2021),
                          id == "001994552" ~ as.integer(2021),
                          id == "002637294" ~ as.integer(2021),
                          id == "002244324" ~ as.integer(2021),
                          id == "002875465" ~ as.integer(2021),
                          id == "002810659" ~ as.integer(2021),
                          id == "002416246" ~ as.integer(2022),
                          id == "002921977" ~ as.integer(2022), TRUE ~ year)) %>% 
  select(id, facility_zip, amount, type, year) %>% 
  rename(zip = facility_zip)


all_relief <- rbind(arpa_paycheck_3, arpa_training, arpa_retention, crrsa_paycheck_1, crrsa_paycheck_2, crrsa_startup_expansion, 
                    crrsa_tech_asistance)

write.csv(all_relief, "data/processed/all_relief_cleaned.csv")
