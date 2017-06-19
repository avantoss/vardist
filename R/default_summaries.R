# Copyright 2017 Avant
# This file is licensed under the MIT license. For a full copy of the license, see: 
# https://github.com/avantoss/open-source/blob/master/LICENSE_MIT

missing_pct <- function(col) { mean(is.na(col)) }

zero_pct <- function(col) {
  vapply(col, function(x) identical(x, 0), logical(1)) %>% mean
}

quantile_fn <- function(x) {
  stopifnot(length(x) == 1)
  function(col) {
    quantile(col, x, na.rm = TRUE)
  }
}

five_number_summary <- list(
  min            = function(col) { min(col, na.rm = TRUE) },
  first_quartile = quantile_fn(0.25),
  median         = quantile_fn(0.5),
  third_quartile = quantile_fn(0.75),
  max            = function(col) { max(col, na.rm = TRUE) }
)

mean_and_sd <- list(
  mean               = function(col) { mean(col, na.rm = TRUE) },
  standard_deviation = function(col) { sd(col, na.rm = TRUE) }
)

default_numeric_summaries <- c(
  mean_and_sd,
  five_number_summary,
  list(
    "percentile_10" = quantile_fn(0.1),
    "percentile_90" = quantile_fn(0.9),
    "missing_pct"   = missing_pct,
    "zero_pct"      = zero_pct
  )
)

# if we don't pass in `keepNA = TRUE`, and `NA` will be replaced
# by a zero - but we want to distinguish between `NA` and `""`!
nchar_ <- function(x) nchar(x, keepNA = TRUE)

string_length_summaries <- list(
  mean_length     = function(col) { nchar_(col) %>% mean(., na.rm = TRUE) },
  min_length      = function(col) { nchar_(col) %>% min(., na.rm = TRUE) },
  max_length      = function(col) { nchar_(col) %>% max(., na.rm = TRUE) },
  zero_length_pct = function(col) { nchar_(col) %>% zero_pct }
)

default_character_summaries <- c(
  string_length_summaries,
  list(
    missing_pct   = missing_pct,
    count_uniques = function(col) {length(unique(col))}
  )
)



