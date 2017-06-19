# Copyright 2017 Avant
# This file is licensed under the MIT license. For a full copy of the license, see: 
# https://github.com/avantoss/open-source/blob/master/LICENSE_MIT

context("calculate_summaries")

describe("calculate_numeric_summaries", {
  dataframe   <- data.frame(a = 1:9, b = 101:109, stringsAsFactors = FALSE)
  summaries   <- list(mean = mean, min = min, max = max)
  expectation <- data.frame(variables = c("a", "b"),
                            mean      = c(5, 105),
                            min       = c(1, 101),
                            max       = c(9, 109),
                            stringsAsFactors = FALSE)
  data_with_char_col <- dataframe
  data_with_char_col$char_col <- "characters"

  test_that("it returns a data frame with summaries", {
    expect_equal(calculate_numeric_summaries(dataframe, summaries), expectation)
  })

  test_that("non-numeric columns are not summarized", {
    suppressWarnings(expect_equal(calculate_numeric_summaries(data_with_char_col, summaries), expectation))
  })

  test_that("parallel execution paralellizes over dataframe columns", {
    if (parallel::detectCores() < 2L) { skip("Running on a single core machine") }
    slow_summaries <- list(slow_mean = function(col) { Sys.sleep(1.5); mean(col) })
    timing <- as.list(system.time(foo <- calculate_numeric_summaries(dataframe, slow_summaries, parallel = TRUE, mc.cores = 2L)))
    expect_less_than(timing$elapsed, 2)
    expect_equal(foo$slow_mean, expectation$mean)
  })
})


describe("calculate_character_summaries", {

  dataframe <- data.frame(a = as.character(letters),
                          b = rep("aaa", length(letters)),
                          stringsAsFactors = FALSE)

  summaries <- list(
    mean_length   = function(col) { mean(nchar(col)) },
    count_uniques = function(col) { length(unique(col)) }
  )

  expectation <- data.frame(variables = c("a", "b"),
                            mean_length = c(1, 3),
                            count_uniques = c(length(letters), 1),
                            stringsAsFactors = FALSE)

  data_with_numeric_col <- dataframe
  data_with_numeric_col$numeric_col <- seq_along(letters)

  test_that("it returns a data frame with summaries", {
    expect_equal(calculate_character_summaries(dataframe, summaries), expectation)
  })

  test_that("non-character columns are not summarized", {
    suppressWarnings(expect_equal(calculate_character_summaries(data_with_numeric_col, summaries), expectation))
  })
})
