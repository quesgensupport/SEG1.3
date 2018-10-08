# =====================================================================#
# This is the code to create: a function to create a table with the
# output from a binomial test (given a cleaned/prepared data set).
#
# This works with the prepare_csv() function the SEG Shiny app.
# Authored by and feedback to mjfrigaard@gmail.com
# MIT License
# Version: 1.1
# =====================================================================#

# DEFINE Binomial test function =============  -------
binomial_tbl <- function(dataset) {
  successes <- nrow(dataset) - (filter(
    dataset,
    iso_range %in% "> 15% or 15 mg/dL"
  )) %>% nrow()
  trials <- nrow(dataset)
  # create probability
  prb <- 0.95
  # create criterion
  broom::tidy(binom.test(
    x = successes,
    n = trials,
    p = prb,
    conf.level = 0.95
  ))
}
