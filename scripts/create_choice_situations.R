# ------------------------------------------------------------------------------------------- #
# CREATE CHOICE SITUATIONS
# ------------------------------------------------------------------------------------------- #


# set-up ------------------------------------------------------------------

# clean environment
rm(list = ls())

# install and load packages if needed
required_packages <- c("tidyverse","lubridate","jsonlite","glue")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(required_packages, require, character.only = TRUE)


# load sp design ----------------------------------------------------------

sp_design <- read_csv(file = file.path(getwd(),"data","sp_design.csv")) %>%
  rename(cs_design = cs) %>%
  arrange(block, cs_design) %>% 
  group_by(block) %>%
  mutate(cs = row_number()) %>%
  ungroup()

str(sp_design)

# create labelled sp design -----------------------------------------------

sp_design_labelled <- sp_design %>%
  mutate(across(.fns = as.character),
         across(matches("^traveltime_.*$"), .fns = ~ if_else(is.na(.) == TRUE, NA_character_, paste0(.," min"))),
         across(matches("^price_.*$"), .fns = ~ if_else(is.na(.) == TRUE, NA_character_, paste0(.," CHF"))),
         across(.fns = ~ replace_na(., "")))

# create cards (a picture for each choice situation) ----------------------

sp_cards <- sp_design_labelled %>%
  generate_cards() %>%
  randomize_cards(file = "sp_cards_order.csv") %>%
  print_cards()

# create json files for each block ----------------------------------------

sp_design_json <- sp_design_labelled %>% generate_jsondata()

sp_data_jsons <- sp_data_labelled %>%
  select(ResponseId, cs = choice_id) %>%
  bind_cols(sp_data_json) %>%
  group_by(ResponseId)
sp_data_jsons_groupkeys <- group_keys(sp_data_jsons) %>% pull(ResponseId)

sp_data_jsons <- sp_data_jsons %>%
  group_split()
names(sp_data_jsons) <- sp_data_jsons_groupkeys

sp_data_jsons %>%
  walk2(names(.), ~ write_json(.x, here::here(paste0("data/jsons_batch",batchnr), paste0(.y,".json"))))














