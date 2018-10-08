#=====================================================================#
# This is code to create: colored tables solution for SEG
# Authored by and feedback to: mjfrigaard@gmail.com
# MIT License
# SEG Version: 1.4
#=====================================================================#

# create
library(tidyverse)
library(magrittr)
library(readr)
library(styler)
library(DT)

# create table of data
RiskCat <- tibble::tribble(
~REF, ~`SEG Risk Category`, ~`Number of Pairs`, ~`% Of Pairs`, ~`Risk Factor Range`,
 0L,             "None",              10L,          "%",        "0.0 - 0.5",
 1L,    "Slight, Lower",              10L,          "%",       ">0.5 - 1.0",
 2L,  "Slight,  Higher",              10L,          "%",       ">1.0 - 1.5",
 3L,  "Moderate, Lower",              10L,          "%",       ">1.5 - 2.0",
 4L,  "Moderate Higher",              10L,          "%",       ">2.0 - 2.5",
 5L,   "Severe,  Lower",              10L,          "%",       ">2.5 - 3.0",
 6L,  "Severe,  Higher",              10L,          "%",       ">3.0 - 3.5",
 7L,          "Extreme",              10L,          "%",            "> 3.5")

RiskCat %>%
  DT::datatable(.) %>%
  DT::formatStyle('REF',
    target = "row",
    backgroundColor = DT::styleEqual(
      levels = c(
        0, 1, 2, 3,
        4, 5, 6, 7),
      values = c("#008B45", "#54FF9F", "#FFFF00",
                 "#FFC125", "#EE7600", "#FF0000",
                 "#CD2626", "#8B0000")))
