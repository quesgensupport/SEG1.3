# =====================================================================#
# This code is used to reate: a function that takes a ,csv file and adds
# summary statistics, risk factors, and categorical values so it can be
# used in the Shiny heatmap.
# Authored by and feedback to mjfrigaard@gmail.com
# MIT License
# Version: 1.1
# =====================================================================#


prepare_csv <- function(file) {
  # 0.1 - import data frame ----
  SampMeasData <- readr::read_csv(file,
    col_types =
      cols(
        BGM = col_double(),
        REF = col_double()
      )
  )
  # 0.2.2 create SEG_pair_type ---- ----  ---- ----  ---- ----  ---- ----
  SampMeasData %>%
    dplyr::mutate(
      SEG_pair_type = dplyr::case_when(
        BGM > 600 ~ "out of range",
        REF > 600 ~ "out of range",
        BGM <= 20 ~ "out of range",
        REF <= 20 ~ "out of range",
        REF > BGM ~ "BGM below ref",
        REF < BGM ~ "BGM above ref",
        BGM == REF ~ "BGM equal to ref"
      ) # 0.2.3 Join RiskPairData data to SampMeasData data ---- ----  ----
    ) %>%
    dplyr::inner_join(.,
      y = RiskPairData,
      by = c("BGM", "REF")
    ) %>%
    dplyr::mutate( # 0.2.4 Create risk_cat variable ---- ---- ---- ---- ----
      risk_cat =
        base::findInterval(
          x = abs_risk, # the abs_risk absolute value
          vec = LookUpRiskCat$ABSLB, # the lower bound absolute risk
          left.open = TRUE
        ) - 1
    ) %>%
    dplyr::inner_join( # 0.2.5 Join to LookUpRiskCat data ---- ----  ----
      x = ., y = LookUpRiskCat, # inner join to look-up
      by = "risk_cat"
    ) %>%
    dplyr::mutate( # 0.2.6 create pairtypes ---- ----
      # excluded over 600
      pairtype_gt600 = dplyr::case_when(
        REF > 600 ~ "REF > 600",
        TRUE ~ NA_character_
      ),
      # create excluded under 21
      pairtype_lt21 = dplyr::case_when(
        REF < 21 ~ "REF < 21",
        TRUE ~ NA_character_
      ),
      # create pair_type
      pair_type = dplyr::case_when(
        BGM < REF ~ "BGM < REF",
        BGM == REF ~ "BGM = REF",
        BGM > REF ~ "BGM > REF",
        TRUE ~ NA_character_
      )
    ) %>%
    dplyr::mutate( # 0.2.7 create the risk cat text variable ---- ----  ----
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
    dplyr::mutate( # 0.3.1, 0.3.2 create MARD variables ----- -----
      rel_diff = (BGM - REF) / REF, # relative diff
      abs_rel_diff = abs(rel_diff), # abs relative diff
      sq_rel_diff = rel_diff^2,
      iso_diff = # 0.3.3 create iso_diff variable ---- ---- ---- ----
      if_else(REF >= 100, # condition 1
        100 * abs(BGM - REF) / REF, # T 1
        if_else(REF < 100, # condition 2
          abs(BGM - REF), # T 2
          NA_real_
        ), # F 2
        NA_real_
      ), # F1
      iso_range = dplyr::case_when( # 0.3.4 create iso range variable ----
        iso_diff <= 5 ~ "<= 5% or 5 mg/dL",
        iso_diff > 5 & iso_diff <= 10 ~ "> 5 - 10% or mg/dL",
        iso_diff > 10 & iso_diff <= 15 ~ "> 10 - 15% or mg/dL",
        iso_diff > 15 & iso_diff ~ "> 15% or 15 mg/dL"
      )
    )
}
