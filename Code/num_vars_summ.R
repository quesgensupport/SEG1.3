
# num_vars_summ function ----------------------------------------------
# this summarizes a numerical variable (mean, median, sd, variance,
# min, max, and n) when given a data frame or tibble and variable:
# num_vars_summ(df, var)
num_vars_summ <- function(df, expr) {
  expr <- enquo(expr) # turns expr into a quosure
  summarise(df,
          n = sum((!is.na(!!expr))), # non-missing
          na = sum((is.na(!!expr))), #
          mean = mean(!!expr, na.rm = TRUE), # unquotes mean()
          median = median(!!expr, na.rm = TRUE), # unquotes median()
          sd = sd(!!expr, na.rm = TRUE), # unquotes sd()
          variance = var(!!expr, na.rm = TRUE), # unquotes var()
          min = min(!!expr, na.rm = TRUE), # unquotes min()
          max = max(!!expr, na.rm = TRUE)) # unquotes max()
}