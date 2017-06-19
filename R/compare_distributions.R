# Copyright 2017 Avant
# This file is licensed under the MIT license. For a full copy of the license, see: 
# https://github.com/avantoss/open-source/blob/master/LICENSE_MIT

#' Compare the distribution of common fields across two data frames.
#'
#' Typically you have a data set whose integrity is unknown, and you want to compare
#' it to a data set whose reliability has already been established by other means.
#' With this function, you can compare the uncertain data set (the "challenger") to
#' the certain one (the "baseline") and see if they have similar enough distributions.
#'
#' @param challenger data.frame.
#' @param baseline data.frame.
#' @param summaries list. A named list of summary functions. Each function must take
#'   as an input one numeric vector, and output a numeric vector of length 1.
#' @param tests list. A named list of functions that return \code{TRUE} or \code{FALSE}, and take in
#'   columns or summary statistics fom the \code{challenger} and the \code{baseline}.
#' @param parallel logical. Should we use \code{mclapply} instead of \code{lapply}?
#' @param mc.cores numeric. To be passed into \code{mclapply}.
#' @return a list with three data frames - the columnwise summaries for the \code{challenger},
#'   the columnwise summaries for the \code{baseline}, and a report with the results of the
#'   \code{tests}.
#' @seealso calculate_summaries, generate_report
#' @export
compare_numeric_distributions <- function(challenger, baseline,
                           summaries = default_numeric_summaries,
                           tests     = default_numeric_tests(
                             tolerance         = getOption("vardist.numeric_summary_tolerance", 0.1),
                             ks_test_threshold = getOption("vardist.ks_test_threshold", 0.5)),
                           parallel = FALSE,
                           mc.cores = parallel::detectCores()) {
  challenger <- remove_non_numeric_cols(challenger)
  baseline   <- remove_non_numeric_cols(baseline)
  calculate_summaries_and_report(challenger, baseline, summaries, tests, parallel, mc.cores)
}

#' Compare the distribution of common fields across two data frames.
#' @inheritParams compare_numeric_distributions
#' @seealso compare_numeric_distributions
#' @export
compare_character_distributions <- function(challenger, baseline,
                           summaries = default_character_summaries,
                           tests     = default_character_tests(
                             discrete_tolerance = getOption("vardist.character_discrete_tolerance", 2),
                             percent_tolerance  = getOption("vardist.character_percent_tolerance", 0.1),
                             uniques_threshold  = getOption("vardist.character_uniques_threshold", 100),
                             uniques_tolerance  = getOption("vardist.character_uniques_tolerance", 10)),
                           parallel = FALSE,
                           mc.cores = parallel::detectCores()) {
  challenger <- remove_non_character_cols(challenger)
  baseline   <- remove_non_character_cols(baseline)
  calculate_summaries_and_report(challenger, baseline, summaries, tests, parallel, mc.cores)
}

calculate_summaries_and_report <- function(challenger, baseline, summaries, tests, parallel, mc.cores) {
  common_columns <- get_common_columns(challenger, baseline)
  challenger     <- subset_columns(common_columns, challenger)
  baseline       <- subset_columns(common_columns, baseline)

  challenger_stats <- calculate_summaries(challenger, summaries, parallel, mc.cores)
  baseline_stats   <- calculate_summaries(baseline, summaries, parallel, mc.cores)
  report           <- generate_report(challenger_stats, baseline_stats,
                        challenger, baseline, tests, parallel, mc.cores)

  list(
    challenger_stats = challenger_stats,
    baseline_stats   = baseline_stats,
    report           = report
  )
}
