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

sp_design <- readr::read_csv(file = file.path(getwd(),"data","sp_design.csv")) %>%
  dplyr::rename(cs_design = cs) %>%
  dplyr::arrange(block, cs_design) %>% 
  dplyr::group_by(block) %>%
  dplyr::mutate(cs = row_number()) %>%
  dplyr::ungroup()

str(sp_design)

# create labelled sp design -----------------------------------------------

sp_design_labelled <- sp_design %>%
  dplyr::mutate(dplyr::across(.fns = as.character),
                dplyr::across(matches("^traveltime_.*$"), .fns = ~ dplyr::if_else(is.na(.) == TRUE, NA_character_, paste0(.," min"))),
                dplyr::across(matches("^cost_.*$"), .fns = ~ dplyr::if_else(is.na(.) == TRUE, NA_character_, paste0(.," CHF"))),
                dplyr::across(.fns = ~ tidyr::replace_na(., "")))

str(sp_design_labelled)

# create cards (a picture for each choice situation) ----------------------

source(file.path(getwd(),"scripts","helper_functions.R"))

sp_cards <- sp_design_labelled %>%
  generate_cards() %>%
  randomize_cards(file = "sp_cards_order.csv") %>%
  print_cards()

# create json files for each block ----------------------------------------

sp_design_jsons <- sp_design_labelled %>%
  generate_jsondata() %>%
  dplyr::group_by(block_name)
sp_design_jsons_groupkeys <- dplyr::group_keys(sp_design_jsons) %>% dplyr::pull(block_name)

sp_design_jsons <- sp_design_jsons %>%
  dplyr::group_split()
names(sp_design_jsons) <- sp_design_jsons_groupkeys

sp_design_jsons %>%
  purrr::walk2(names(.), ~ jsonlite::write_json(.x, file.path(getwd(), "data/jsons", paste0(.y,".json"))))














