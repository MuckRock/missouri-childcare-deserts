library(tidyverse)
library(janitor)
library(readxl)
library(here)

dese_funds <- read_excel(here("data", "processed", "dese_funds_update.xlsx")) %>% 
  clean_names() %>% 
  mutate(awarded_approved_amount = as.numeric(if_else(awarded_approved_amount == "Pending", "0", awarded_approved_amount))) %>% 
  mutate(paid_amount_as_of_4_14_23 = as.numeric(paid_amount_as_of_4_14_23))


our_foia_data <- dese_funds %>% 
  filter(application_name %in% c("Enhancement", "Paycheck Protection", "Technical Business Assistance",
                                 "Expansion", "Startup", "Retention of Staff", "Annual Training Costs"))

foia_awarded <- sum(our_foia_data$awarded_approved_amount)

foia_paid <- sum(our_foia_data$paid_amount_as_of_4_14_23)

total_awarded <- sum(dese_funds$awarded_approved_amount)

total_paid <- sum(dese_funds$paid_amount_as_of_4_14_23)
