# Copyright 2014-2017 Avant. Full copy of license can be found at https://github.com/avantcredit/vardist#license

context("compare_distributions")

describe("compare_numeric_distributions", {
  baseline_df   <- data.frame(a = 1:9, b = 101:109)
  challenger_df <- data.frame(a = 1:9, b = 100:108)

  challenger_with_one_common_col <- data.frame(a = 1:9, c = 2:10)
  challenger_with_no_common_cols <- data.frame(c = 0:8, d = 3:11)

  summaries <- list(mean = mean, min  = min, max  = max)

  identical_statistic_values <- function(baseline_value, challenger_value, ...) {
    identical(baseline_value, challenger_value)
  }

  tests <- list(
    mean             = identical_statistic_values,
    max              = identical_statistic_values,
    same_col_lengths = function(baseline_col, challenger_col) {
       identical(length(baseline_col), length(challenger_col))
    }
  )

  test_that("it returns a list with stats and reports", {
    var_summaries <- compare_numeric_distributions(challenger_df, baseline_df, summaries, tests)

    expected_outputs <- c("challenger_stats", "baseline_stats", "report")
    lapply(expected_outputs, function(x) {
      expect_true(x %in% names(var_summaries))
    })

    expect_equal(var_summaries$challenger_stats,
      data.frame(variables = c("a", "b"),
                 mean      = c(5, 104),
                 min       = c(1, 100),
                 max       = c(9, 108),
                 stringsAsFactors = FALSE)
    )
    expect_equal(var_summaries$baseline_stats,
      data.frame(variables = c("a", "b"),
                 mean      = c(5, 105),
                 min       = c(1, 101),
                 max       = c(9, 109),
                 stringsAsFactors = FALSE)
    )

    expect_equal(var_summaries$report,
      data.frame(variables        = c("a", "b"),
                 mean             = c(TRUE, FALSE),
                 max              = c(TRUE, FALSE),
                 same_col_lengths = c(TRUE, TRUE),
                 stringsAsFactors = FALSE)
    )
  })

  test_that("it only calculates stats and tests for common columns", {
    var_summaries <- suppressWarnings(compare_numeric_distributions(challenger_with_one_common_col, baseline_df, summaries, tests))
    lapply(var_summaries, function(df) {
      expect_equal(df$variables, "a")
    })
  })

  test_that("it errors out if there are no common columns", {
    expect_error(compare_numeric_distributions(challenger_with_no_common_cols, baseline_df, summaries, tests),
                 "no common column names")
  })

  test_that("it only calculates stats and tests for numeric columns", {
    baseline_with_char   <- data.frame(a = 1:9, b = 101:109, char_col = rep("text", 9))
    challenger_with_char <- data.frame(a = 1:9, b = 100:108, char_col = rep("text", 9))
    var_summaries <- suppressWarnings(compare_numeric_distributions(challenger_with_char, baseline_with_char, summaries, tests))
    lapply(var_summaries, function(df) {
      expect_false("char_col" %in% df$variables)
    })
  })

})
