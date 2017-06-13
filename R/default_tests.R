# Copyright 2014-2017 Avant. Full copy of license can be found at https://github.com/avantcredit/vardist#license

within_tolerance <- function(tolerance, comparison = "<>", relative_diff = TRUE) {

  diff <- function(baseline, challenger) {
    if (any(is.na(c(baseline, challenger)))) {
      warning("Unable to generate a diff with NA values")
      return(NA)
    }
    if (baseline == 0 && challenger == 0) { return(0) }
    if (relative_diff) {
      (challenger - baseline) / baseline
    } else { challenger - baseline }
  }

  test_functions <- list(
    ">" = function(baseline_value, challenger_value, ...){
      diff(baseline_value, challenger_value) < tolerance
    },
    "<" = function(baseline_value, challenger_value, ...){
      -diff(baseline_value, challenger_value) < tolerance
    },
    "<>" = function(baseline_value, challenger_value, ...){
      abs(diff(baseline_value, challenger_value)) < tolerance
    }
  )

  allowed_comparisons <- names(test_functions)
  if (!comparison %in% allowed_comparisons) {
    stop(sQuote(comparison), " must be one of ",
         paste(sQuote(allowed_comparisons), collapse = ", "), ".")
  }

  test_functions[[comparison]]
}

ks_test_fn <- function(threshold) {
  function(baseline_col, challenger_col) {
    stats::ks.test(challenger_col, baseline_col)$statistic < threshold
  }
}

accept_uniques_fn <- function(threshold, tolerance) {
  function(baseline_value, challenger_value, baseline_col, challenger_col) {
    if (baseline_value > threshold && challenger_value > threshold) {
      return(TRUE)
    }
    abs(baseline_value - challenger_value) < threshold
  }
}

default_numeric_tests <- function(tolerance, ks_test_threshold) {
  list(
    mean               = within_tolerance(tolerance),
    standard_deviation = within_tolerance(tolerance),
    min                = within_tolerance(tolerance, comparison = "<"),
    first_quartile     = within_tolerance(tolerance),
    median             = within_tolerance(tolerance),
    third_quartile     = within_tolerance(tolerance),
    max                = within_tolerance(tolerance, comparison = ">"),
    "percentile_10"    = within_tolerance(tolerance),
    "percentile_90"    = within_tolerance(tolerance),
    missing_pct        = within_tolerance(tolerance, relative_diff = FALSE),
    zero_pct           = within_tolerance(tolerance, relative_diff = FALSE),
    ks_test            = ks_test_fn(ks_test_threshold)
  )
}

default_character_tests <- function(discrete_tolerance, percent_tolerance, uniques_threshold, uniques_tolerance) {
  list(
    mean_length     = within_tolerance(discrete_tolerance, relative_diff = FALSE),
    min_length      = within_tolerance(discrete_tolerance, relative_diff = FALSE),
    max_length      = within_tolerance(discrete_tolerance, relative_diff = FALSE),
    zero_length_pct = within_tolerance(percent_tolerance, relative_diff = FALSE),
    missing_pct     = within_tolerance(percent_tolerance, relative_diff = FALSE),
    uniques         = accept_uniques_fn(uniques_threshold, uniques_tolerance)
  )
}
