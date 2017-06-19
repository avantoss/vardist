# Copyright 2017 Avant
# This file is licensed under the MIT license. For a full copy of the license, see: 
# https://github.com/avantoss/open-source/blob/master/LICENSE_MIT

#' Compare summary statistics for two datasets, given the summaries and the datasets.
#'
#' In the list \code{tests}, some elements may be named after some of the
#' summaries (which at this point are column names in \code{baseline_stats}).
#'
#' If an element in \code{tests} is named after a summary, then the element is
#' expected to be a function that takes in the baseline statistic, the challenger
#' statistic, and the respective columns. Otherwise, it is expected to take in
#' the two columns.
#'
#' @param challenger_stats data.frame. Summaries for the challenger data frame,
#'   created by \code{calculate_summaries}.
#' @param baseline_stats data.frame. Summaries for the baseline data frame,
#'   created by \code{calculate_summaries}.
#' @param challenger_df data.frame.
#' @param baseline_df data.frame.
#' @param tests list. A named list of functions that compare the challenger and
#'   the baseline. See above for details.
#' @param parallel logical. Should we use \code{mclapply} instead of \code{lapply}?
#' @param mc.cores numeric. To be passed into \code{mclapply}.
#' @return a data.frame of logical values showing if each test passed or failed
#'   for each column.
generate_report <- function(challenger_stats, baseline_stats, challenger_df,
                     baseline_df, tests, parallel = FALSE, mc.cores = parallel::detectCores()) {

  stopifnot(setequal(baseline_stats$variables, names(baseline_df)))
  stopifnot(setequal(names(baseline_df), names(challenger_df)))
  stopifnot(setequal(baseline_stats$variables, challenger_stats$variables))
  stopifnot(setequal(names(baseline_stats), names(challenger_stats)))

  report <- list()
  report$variables = baseline_stats$variables

  calculate_test_results <- function(idx) {
    map_method <- if (isTRUE(parallel)) { parallel::mcMap } else { Map }
    make_args <- function(lst) {
      if (isTRUE(parallel)) {
        append(lst, list(mc.cores = mc.cores))
      } else { lst }
    }
    if (idx %in% names(baseline_stats)) {
      baseline_results   <- baseline_stats[[idx]]
      challenger_results <- challenger_stats[[idx]]
      args <- make_args(list(tests[[idx]], baseline_results, challenger_results,
        baseline_df, challenger_df))
      unlist(do.call(map_method, args))
    } else {
      args <- make_args(list(tests[[idx]], baseline_df, challenger_df))
      unlist(do.call(map_method, args))
    }
  }
  report[names(tests)] <- `names<-`(lapply(names(tests),  calculate_test_results), names(tests))
  as.data.frame(report, stringsAsFactors = FALSE) %>% `row.names<-`(., NULL)
}


#' Compare summary statistics for two datasets, given only the summaries.
#'
#' @param challenger_stats data.frame. Summaries for the challenger data frame,
#'   created by \code{calculate_summaries}.
#' @param baseline_stats data.frame. Summaries for the baseline data frame,
#'   created by \code{calculate_summaries}.
#' @param challenger_df data.frame.
#' @param baseline_df data.frame.
#' @param tests list. A named list of functions that compare the challenger and
#'   the baseline. See above for details.
#' @return a data.frame of logical values showing if each test passed or failed
#'   for each column.
#' @export
generate_report_from_summaries <- function(challenger_stats, baseline_stats, tests) {
  common_stats     <- intersect(names(baseline_stats), names(challenger_stats))
  if (length(setdiff(names(tests), common_stats)) > 0) {
    stop("You've specified tests that don't match to columns in your statistics.")
  }
  baseline_stats   <- subset_columns(common_stats, baseline_stats)
  challenger_stats <- subset_columns(common_stats, challenger_stats)

  common_variables <- intersect(baseline_stats$variables, challenger_stats$variables)
  baseline_stats   <- subset_variables(common_variables, baseline_stats)
  challenger_stats <- subset_variables(common_variables, challenger_stats)

  report <- list()
  report$variables <- baseline_stats$variables
  report[names(tests)] <- lapply(names(tests), function(idx) {
    baseline_results   <- baseline_stats[[idx]]
    challenger_results <- challenger_stats[[idx]]
    Map(tests[[idx]], baseline_results, challenger_results) %>% unlist
  }) %>% setNames(., names(tests))

  as.data.frame(report, stringsAsFactors = FALSE) %>% `row.names<-`(., NULL)
}
