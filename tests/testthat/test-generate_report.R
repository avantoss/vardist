# Copyright 2014-2017 Avant. Full copy of license can be found at https://github.com/avantcredit/vardist#license

context("generate_report")

baseline_df   <- data.frame(a = 1:9, b = 101:109)
challenger_df <- data.frame(a = 1:9, b = 102:110)

stats_for <- function(df) {
  data.frame(
    variables = c("a", "b"),
    mean      = c(mean(df$a), mean(df$b)),
    max       = c(max(df$a), max(df$b)),
    stringsAsFactors = FALSE
  )
}

baseline_stats   <- stats_for(baseline_df)
challenger_stats <- stats_for(challenger_df)


identical_statistic_values <- function(baseline_value, challenger_value, ...) {
  identical(baseline_value, challenger_value)
}

tests = list(
  mean             = identical_statistic_values,
  max              = identical_statistic_values,
  same_col_lengths = function(baseline_col, challenger_col) {
    identical(length(baseline_col), length(challenger_col))
  }
)

stats_only_tests <- tests[c("mean", "max")]

test_that("generate_report generates a data.frame of logical values", {
  expected <- data.frame(
    variables        = c("a", "b"),
    mean             = c(TRUE, FALSE),
    max              = c(TRUE, FALSE),
    same_col_lengths = c(TRUE, TRUE),
    stringsAsFactors = FALSE
  )

  actual <- generate_report(challenger_stats, baseline_stats, challenger_df, baseline_df, tests)

  expect_equal(expected, actual)
})

test_that("parallelizeable across dataframe columns", {
  expected <- data.frame(
    variables             = c("a", "b"),
    slow_same_col_lengths = c(TRUE, TRUE),
    stringsAsFactors      = FALSE
  )

  slow_tests <- list(slow_same_col_lengths = function(baseline_col, challenger_col) {
    Sys.sleep(1.5)
    identical(length(baseline_col), length(challenger_col))
  })
  timing <- as.list(system.time(actual <- generate_report(challenger_stats, baseline_stats, challenger_df, baseline_df, slow_tests, parallel = TRUE, mc.cores = 2)))

  expect_less_than(timing$elapsed, 2)
  expect_equal(expected, actual)
})

test_that("generate_report_from_summaries generates a data.frame of logical values", {
  expected <- data.frame(
    variables        = c("a", "b"),
    mean             = c(TRUE, FALSE),
    max              = c(TRUE, FALSE),
    stringsAsFactors = FALSE
  )
  actual <- generate_report_from_summaries(challenger_stats, baseline_stats, stats_only_tests)

  expect_equal(expected, actual)
})
