# Copyright 2017 Avant
# This file is licensed under the MIT license. For a full copy of the license, see: 
# https://github.com/avantoss/open-source/blob/master/LICENSE_MIT

context("default_tests")

describe("within_tolerance", {
  test_that("it can test for relative difference between numbers", {
    baseline         <- 100
    challenger_under <- 90
    challenger_over  <- 110

    reject_over       <- within_tolerance(0.05, ">")
    reject_under      <- within_tolerance(0.05, "<")
    reject_different  <- within_tolerance(0.05, "<>")

    expect_true(reject_over(baseline, challenger_under))
    expect_false(reject_over(baseline, challenger_over))

    expect_false(reject_under(baseline, challenger_under))
    expect_true(reject_under(baseline, challenger_over))

    expect_false(reject_different(baseline, challenger_under))
    expect_false(reject_different(baseline, challenger_over))

    big_baseline                <- 1000
    big_challenger_over         <- 1010
    big_challenger_further_over <- 1100

    expect_true(reject_over(big_baseline, big_challenger_over))
    expect_false(reject_over(big_baseline, big_challenger_further_over))
  })

  test_that("it can test for absolute difference between numbers", {
    small_baseline                <- 5
    small_challenger_over         <- 6
    small_challenger_further_over <- 8
    big_baseline                  <- 100
    big_challenger_over           <- 101
    big_challenger_further_over   <- 103

    less_than_two_apart <- within_tolerance(2, relative_diff = FALSE)

    expect_true(less_than_two_apart(small_baseline, small_challenger_over))
    expect_false(less_than_two_apart(small_baseline, small_challenger_further_over))

    expect_true(less_than_two_apart(big_baseline, big_challenger_over))
    expect_false(less_than_two_apart(big_baseline, big_challenger_further_over))
  })
})
