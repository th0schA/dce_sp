# ------------------------------------------------------------------------------------------- #
# CREATE SP CHOICE SITUATIONS
# ------------------------------------------------------------------------------------------- #


# set-up ------------------------------------------------------------------

# clean environment
rm(list = ls())

# install and load packages if needed
required_packages <- c("tidyverse","lubridate","jsonlite","glue","aws.s3")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(required_packages, require, character.only = TRUE)

# AWS S3 set up
# replace "your..." with your AWS S3 credentials
# see https://github.com/cloudyr/aws.s3 for help
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = "yourkey",
  "AWS_SECRET_ACCESS_KEY" = "yoursecretkey",
  "AWS_DEFAULT_REGION" = "yourregion"
)

# create two folders in bucket on AWS S3 to store png and JSON files
aws.s3::put_folder(folder = "cards", bucket = "yourbucket")
aws.s3::put_folder(folder = "jsons", bucket = "yourbucket")


# load helper functions ---------------------------------------------------

# several functions to:
# 1. produce pictures
# 2. produce json files
source(file.path(getwd(),"scripts","helper_functions.R"))


# load sp design ----------------------------------------------------------

# loads a simple choice design for mode choice with divided into 4 blocks
# one person will be faced with 4 choice situations (from one block)
# 4 alternatives: walk, bicycle, car and public transport (pt) and
# 2 attributes: cost (only for car and pt) and travel time
sp_design <- readr::read_csv(file = file.path(getwd(),"data","sp_design.csv")) %>%
  dplyr::rename(cs_design = cs) %>%
  dplyr::arrange(block, cs_design) %>% 
  dplyr::group_by(block) %>%
  dplyr::mutate(cs = row_number()) %>%
  dplyr::ungroup()

str(sp_design)


# create labelled sp design -----------------------------------------------

# adds labels for each alternative and its attributes
sp_design_labelled <- sp_design %>%
  dplyr::mutate(dplyr::across(.fns = as.character),
                dplyr::across(matches("^traveltime_.*$"),
                              .fns = ~ dplyr::if_else(is.na(.) == TRUE, NA_character_, paste0(.," min"))),
                dplyr::across(matches("^cost_.*$"),
                              .fns = ~ dplyr::if_else(is.na(.) == TRUE, NA_character_, paste0(.," CHF"))),
                dplyr::across(.fns = ~ tidyr::replace_na(., "")))

str(sp_design_labelled)


# create cards (a picture for each choice situation) ----------------------

# 3 main functions from file helper_functions.R:
# 1. generate_cards(): creates a list of dfs, each element is a choice situation
# 2. randomize_cards(): randomly changes order of alternatives in each choice situation
#                       and saves a csv file with the order for later rematching
# 3. print_cards(): applies a theme to each choice situation and draws/saves it to folder
#                   can also only print cards for inspection
# detailed information in script "helper_functions.R"
sp_cards <- sp_design_labelled %>%
  generate_cards() %>%
  randomize_cards(file = "sp_cards_order.csv") %>%
  print_cards(draw = F, save = T)

# upload png files to AWS
lapply(dir(file.path(getwd(),"data/cards"), full.names = TRUE, recursive = TRUE), function(filename) {
  aws.s3::put_object(file = filename,
                     object = stringr::str_extract(filename, "block_\\d_cs_\\d.png$"),
                     bucket = "testivt/cards",
                     acl = "public-read")
})


# create json files for each block ----------------------------------------

# this section creates a JSON (JavaScript Object Notation) file for each block, containing
# the data for one block and its 4 choice situations and saves each to folder as well as
# uploads it to AWS

# 1. generate_jsondata(): creates a df and adds block names

# group output of generate_jsondata() by block name
sp_design_jsons <- sp_design_labelled %>%
  generate_jsondata() %>%
  dplyr::group_by(block_name)
# saves block name for each group
sp_design_jsons_groupkeys <- dplyr::group_keys(sp_design_jsons) %>% dplyr::pull(block_name)

# creates a list of dfs
sp_design_jsons <- sp_design_jsons %>%
  dplyr::group_split()
# add block names as names to list elements
names(sp_design_jsons) <- sp_design_jsons_groupkeys

# save list elements with names as separate JSON files
sp_design_jsons %>%
  purrr::walk2(names(.), ~ jsonlite::write_json(.x, file.path(getwd(), "data/jsons", paste0(.y,".json"))))

# upload json files to AWS
lapply(dir(file.path(getwd(),"data/jsons"), full.names = TRUE, recursive = TRUE), function(filename) {
  aws.s3::put_object(file = filename,
             object = stringr::str_extract(filename, "block_.*.json$"),
             bucket = "testivt/jsons",
             acl = "public-read")
})










