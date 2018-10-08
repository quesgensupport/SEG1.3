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
# create tibble (5 cats)
SmallRiskCat <- tibble::tribble(
            ~Risk.Grade,    ~N,       ~`%`,        ~RANGE, ~REF,
                    "A", 9474L, "96.00%",     "0 - 0.5",   0L,
                    "B",  294L,  "3.00%", "> 0.5 - 1.0",   1L,
                    "C",   79L,  "0.80%", "> 1.0 - 2.0",   2L,
                    "D",   21L,  "0.20%", "> 2.0 - 3.0",   3L,
                    "E",    0L,  "0.00%",       "> 3.0",   4L)

SmallRiskCat %>%
  DT::datatable(.) %>%
    # select numerical reference
  DT::formatStyle('REF',
                  target = "row",
                  backgroundColor =
  DT::styleEqual(levels =  # five levels/labels
                     c(0, 1, 2, 3, 4),
                values = c("#008B00", "#00FF00",
                           "#FFFF00", "#FFA500",
                           "#FF0000")))

# create tibble (8 cats)
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
  datatable(.) %>%
    # select numerical reference
        formatStyle('REF',
                  target = "row",
                  backgroundColor = styleEqual(
                      levels =  # eight levels/labels
                            c(0, 1, 2, 3,
                                4, 5, 6, 7),
                        values = c("#008B45", "#54FF9F", "#FFFF00",
                                    "#FFC125", "#EE7600", "#FF0000",
                                    "#CD2626", "#8B0000")))

# need to find way to remove the extra/REF number column
