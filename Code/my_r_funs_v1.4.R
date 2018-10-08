#=====================================================================#
# This code is used to create a collection of handy functions for
# wrangling data.
# Authored by and feedback to mjfrigaard@gmail.com
# MIT License
# Version: 1.4
# source: https://goo.gl/6uCLqE
#=====================================================================#
require(tidyverse)
require(magrittr)

# These are useful functions for viewing and summarizing data.
# To see how to attach them to your .env, see this post:
# https://csgillespie.github.io/efficientR/3-3-r-startup.html#renviron


#     headTail -----

headTail = function(d, n = 5) rbind(head(x = d, n = n), tail(x = d, n = n))

#      Show the first 5 rows & first 5 columns of a data frame

headSmall = function(d) d[1:5, 1:5]

#     headSmall -----

#       In the .Rprofile file we can create a hidden environment

# .env = new.env()

#       and then add functions to this environment

# .env$headTail = function(d, n = 5) rbind(head(x = d, n = n), tail(x = d, n = n))

#       At the end of the .Rprofile file, we use attach, which makes it
#       possible to refer to objects in the environment by their names
#       alone.

# attach(.env)

# sectionLabel --------------------------------------------------------

sectionLabel <- function(..., pad = "-") {
    title <- paste0(...)
    width <- getOption("width") - nchar(title) - 10
    cat("# > ", title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
sectionLabel("load functions")


# numvarSum -----------------------------------------------------------

numvarSum <- function(df, expr) {
  expr <- enquo(expr) # turns expr into a quosure
  summarise(df,
          n = sum((!is.na(!!expr))), # non-missing
          na = sum((is.na(!!expr))), # missing
          mean = mean(!!expr, na.rm = TRUE), # unquotes mean()
          median = median(!!expr, na.rm = TRUE), # unquotes median()
          sd = sd(!!expr, na.rm = TRUE), # unquotes sd()
          variance = var(!!expr, na.rm = TRUE), # unquotes var()
          min = min(!!expr, na.rm = TRUE), # unquotes min()
          max = max(!!expr, na.rm = TRUE), # unquotes max()
          se = sd/sqrt(n)) # standard error
}
# mtcars %>% numvarSum(mpg)


# dataShape -----------------------------------------------------------

dataShape <- function(df) {
    obs <- nrow(df)
    vars <- ncol(df)
    class <- paste0(class(df), collapse = "; ")
    first_var <- base::names(df) %>% head(1)
    last_var <- base::names(df) %>% tail(1)
    group <- is_grouped_df(df)
    heads_tails <- tibble::as_tibble(headTail(df))
    cat("Observations: ", obs, "\n", sep = "")
    cat("Variables: ", vars, "\n", sep = "")
    cat("Class(es): ", class, "\n", sep = " ")
    cat("First/last variable: ", first_var, "/", last_var, "\n", sep = "")
    cat("Grouped: ", group, "\n", sep = "")
    cat("Top 5 & bottom 5 observations:", "\n", sep = "")
    heads_tails
}
mtcars %>% dataShape()


# timeStamper ---------------------------------------------------------
timeStamper <- function(...) {
mytime <- stringr::str_sub(string = as.character.Date(Sys.time()),
                 start = 12L,
                 end = 19L)
mydate <- stringr::str_sub(string = as.character.Date(Sys.time()),
                 start = 1L,
                 end = 10L)
mytime <- stringr::str_replace_all(mytime, ":", ".")
paste0(mydate, "-", mytime)
}
# timeStamper()

# fileNamer -----------------------------------------------------------
fileNamer <- function(..., version = "0.0", extension = ".R") {
    title <- str_replace_all(string = ..., pattern = "\\W", replacement = "_")
    title <- str_to_lower(title)
    pad <- "-"
    file_name <- paste0(version, pad, title, extension, sep = "")
    if (!file.exists(file_name)) {
        file.create(file_name)
    }
    return(file_name)
}
# fileNamer("My File", version = "1.0", extension = ".R")

# normVarNames --------------------------------------------------------

normVarNames <- function(vars, sep="_")
{
  if (sep == ".") sep <- "\\."

  # Replace all _ and . and ' ' with the nominated separator. Note
  # that I used [] originally but that fails so use |.

  pat  <- '_|\u00a0|\u2022| |,|-|:|/|&|\\.|\\?|\\[|\\]|\\{|\\}|\\(|\\)'
  rep  <- sep
  vars <- gsub(pat, rep, vars)

  # Replace any all capitals words with Initial capitals. This uses an
  # extended perl regular expression. The ?<! is a zero-width negative
  # look-behind assertion that matches any occurrence of the following
  # pattern that does not follow a Unicode property (the \p) of a
  # letter (L) limited to uppercase (u). Not quite sure of the
  # use-case for the look-behind.

  pat  <- '(?<!\\p{Lu})(\\p{Lu})(\\p{Lu}*)'
  rep  <- '\\1\\L\\2'
  vars <- gsub(pat, rep, vars, perl=TRUE)

  # Replace any capitals not at the beginning of the string with _
  # and then the lowercase letter.

  pat  <- '(?<!^)(\\p{Lu})'
  rep  <- paste0(sep, '\\L\\1')
  vars <- gsub(pat, rep, vars, perl=TRUE)

  # WHY DO THIS? Replace any number sequences not preceded by an
  # underscore, with it preceded by an underscore. The (?<!...) is a
  # lookbehind operator.

  pat  <- paste0('(?<![', sep, '\\p{N}])(\\p{N}+)')
  rep  <- paste0(sep, '\\1')
  vars <- gsub(pat, rep, vars, perl = TRUE)

  # Remove any resulting initial or trailing underscore or multiples:
  #
  # _2level -> 2level

  vars <- gsub("^_+", "", vars)
  vars <- gsub("_+$", "", vars)
  vars <- gsub("__+", "_", vars)

  # Convert to lowercase

  vars <- tolower(vars)

  # Remove repeated separators.

  pat  <- paste0(sep, "+")
  rep  <- sep
  vars <- gsub(pat, rep, vars)

  return(vars)
}

# datevarSum function ---------------------------------------------
# this summarizes a date variable (min, median, max, and n) when given
# a data frame or tibble and variable:
# datevarSum(df, var)

datevarSum <- function(df, expr) {
  expr <- enquo(expr) # turns expr into a quosure
  summarise(df,
          min = min(!!expr, na.rm = TRUE), # unquotes min()
          median = median(!!expr, na.rm = TRUE), # unquotes median()
          max = max(!!expr, na.rm = TRUE), # unquotes max()
          n = sum((!is.na(!!expr))), # non-missing
          na = sum((is.na(!!expr)))) # missing
}

show_missings <- function(df) {
n <- sum(is.na(df))
cat("Missing values: ", n, "\n", sep = "")
invisible(df)
}
