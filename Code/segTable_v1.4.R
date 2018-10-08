# =====================================================================#
# This code is used to reate: a function that takes a ,csv file and adds
# summary statistics, risk factors, and categorical values so it can be
# used in the Shiny heatmap.
# Authored by and feedback to mjfrigaard@gmail.com
# MIT License
# Version: 1.4
# =====================================================================#

# 4.3.1 - DEFINE DATA INPUTS ---- ---- ---- ----
github_root <- "https://raw.githubusercontent.com/"
# 4.3.2  define inputs ---- ---- ---- ----
riskpair_repo <- "mjfrigaard/SEG_shiny/master/Data/RiskPairData.csv"
lookup_repo <- "mjfrigaard/SEG_shiny/master/Data/LookUpRiskCat.csv"
# Load and wrangle the risk pair data
RiskPairData <- read_csv(paste0(github_root, riskpair_repo))
# Make sure the names in the RiskPairData data frame are identical
# to the names in SampMeasData
# 4.3.3 create absolute value of RiskFactor in RiskPairData  ---- ---- ----
RiskPairData <- RiskPairData %>%
  dplyr::mutate(abs_risk = abs(RiskFactor))
# 4.3.4 reorganize columns in RiskPairData  ---- ---- ---- ----
RiskPairData <- RiskPairData %>%
  dplyr::select(
    RiskPairID,
    REF = RefVal,
    BGM = MeasVal,
    everything()
  )
# 4.3.6 Load look-up table data ---- ---- ---- ----
LookUpRiskCat <- read_csv(paste0(github_root, lookup_repo))
# 4.3.7 rename RiskCatLabel, remove RiskCatRangeTxt
LookUpRiskCat <- LookUpRiskCat %>%
  dplyr::select(
    risk_cat,
    ABSLB,
    ABSUB
  )
# packages   ---- ---- ---- ----
require(dplyr) # Data wrangling, glimpse(50) and tbl_df().
require(ggplot2) # Visualise data.
require(lubridate) # Dates and time.
require(readr) # Efficient reading of CSV data.
require(stringr) # String operations.
require(tibble) # Convert row names into a column.
require(tidyr) # Prepare a tidy dataset, gather().
require(magrittr) # Pipes %>%, %T>% and equals(), extract().
require(tidyverse) # all tidyverse packages
require(mosaic) # favstats and other summary functions
require(fs) # file management functions
require(shiny) # apps
require(datapasta) # for pasting tibbles
# segTable() FUNCTION ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
segTable <- function(file) {
  # 4.3.7 - import data frame ----
  SampMeasData <- readr::read_csv(file,
    col_types =
      cols(
        BGM = readr::col_double(),
        REF = readr::col_double()
      )
  )
  # 4.3.8 create bgm_pair_cat ---- ----  ---- ----  ---- ----  ---- ----
  SampMeasData <- SampMeasData %>%
    dplyr::mutate(
      bgm_pair_cat =
        dplyr::case_when(
          BGM < REF ~ "BGM < REF",
          BGM == REF ~ "BGM = REF",
          BGM > REF ~ "BGM > REF"
        )
    ) %>%
    # 4.3.8 create ref_pair_2cat ---- ----  ---- ----  ---- ----  ---- ----
    dplyr::mutate(
      ref_pair_2cat =
        dplyr::case_when(
          REF > 600 ~ "REF > 600: Excluded from SEG Analysis",
          REF < 21 & REF <= 600 ~ "REF <21: Included in SEG Analysis"
        )
    ) %>%
    # # 4.3.9 create included ---- ----  ---- ----  ---- ----  ---- ----  ----
    dplyr::mutate(
      included =
        dplyr::case_when(
          REF <= 600 ~ "Total included in SEG Analysis",
          REF > 600 ~ "Total excluded in SEG Analysis"
        )
    ) %>%
    # # 4.3.10 join to RiskPairData ---- ----  ---- ----
    dplyr::inner_join(.,
      y = RiskPairData,
      by = c("BGM", "REF")
    ) %>%
    dplyr::mutate( # 4.3.11 Create risk_cat variable ---- ---- ---- ---- ----
      risk_cat =
        base::findInterval(
          x = abs_risk, # the abs_risk absolute value
          vec = LookUpRiskCat$ABSLB, # the lower bound absolute risk
          left.open = TRUE
        ) - 1
    ) %>%
    dplyr::inner_join( # # 4.3.12 Join to LookUpRiskCat data ---- ----  ----
      x = ., y = LookUpRiskCat, # inner join to look-up
      by = "risk_cat"
    ) %>%
    dplyr::mutate( # # 4.3.13 create the risk cat text variable ---- ----  ----
      risk_cat_txt = # text risk categories
      dplyr::case_when(
        abs_risk < 0.5 ~ "None",
        abs_risk >= 0.5 & abs_risk <= 1 ~ "Slight, Lower",
        abs_risk > 1 & abs_risk <= 1.5 ~ "Slight, Higher",
        abs_risk > 1.5 & abs_risk <= 2.0 ~ "Moderate, Lower",
        abs_risk > 2 & abs_risk <= 2.5 ~ "Moderate, Higher",
        abs_risk > 2.5 & abs_risk <= 3.0 ~ "Severe, Lower",
        abs_risk > 3.0 & abs_risk <= 3.5 ~ "Severe, Higher",
        abs_risk > 3.5 ~ "Extreme"
      )
    ) %>%
    dplyr::mutate( # # 4.3.14 create MARD variables ----- -----
      rel_diff = (BGM - REF) / REF, # relative diff
      abs_rel_diff = abs(rel_diff), # abs relative diff
      sq_rel_diff = rel_diff^2,
      iso_diff = # # 4.3.15 create iso_diff variable ---- ---- ---- ----
      if_else(REF >= 100, # condition 1
        100 * abs(BGM - REF) / REF, # T 1
        if_else(REF < 100, # condition 2
          abs(BGM - REF), # T 2
          NA_real_
        ), # F 2
        NA_real_
      ), # F1
      iso_range = # # 4.3.16 create iso range variable ----
      dplyr::case_when(
        iso_diff <= 5 ~ "<= 5% or 5 mg/dL",
        iso_diff > 5 & iso_diff <= 10 ~ "> 5 - 10% or mg/dL",
        iso_diff > 10 & iso_diff <= 15 ~ "> 10 - 15% or mg/dL",
        iso_diff > 15 & iso_diff ~ "> 15% or 15 mg/dL"
      ),
      risk_grade = dplyr::case_when(
        abs_risk >= 0.0 & abs_risk < 0.5 ~ "A",
        abs_risk >= 0.5 & abs_risk < 1.0 ~ "B",
        abs_risk >= 1.0 & abs_risk < 2.0 ~ "C",
        abs_risk >= 2.0 & abs_risk < 3.0 ~ "D",
        abs_risk >= 3.0 ~ "E"
      ),
      risk_grade_txt = dplyr::case_when(
        abs_risk >= 0.0 & abs_risk < 0.5 ~ "0 - 0.5",
        abs_risk >= 0.5 & abs_risk < 1.0 ~ "> 0.5 - 1.0",
        abs_risk >= 1.0 & abs_risk < 2.0 ~ "> 1.0 - 2.0",
        abs_risk >= 2.0 & abs_risk < 3.0 ~ "> 2.0 - 3.0",
        abs_risk >= 3.0 ~ "> 3.0"
      )
    )
}
