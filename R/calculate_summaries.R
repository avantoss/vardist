# Copyright 2017 Avant
# This file is licensed under the MIT license. For a full copy of the license, see: 
# https://github.com/avantoss/open-source/blob/master/LICENSE_MIT

#' Calculate columnwise summaries for a data frame.
#'
#' @param dataframe data.frame. The data you want to summarize.
#' @param summaries list. A list of summary functions. Each function must take
#'   as an input one numeric vector, and output a numeric vector of length 1.
#' @param parallel logical. Should we use \code{mclapply} instead of \code{lapply}?
#' @param mc.cores numeric. To be passed into \code{mclapply}.
#' @return data.frame, with a column called \code{variables} with the column names
#'   from the data frame, and a column for each summary function.
#' @export
calculate_numeric_summaries <- function(dataframe, summaries = default_numeric_summaries, parallel = FALSE, mc.cores = parallel::detectCores()) {
  dataframe <- remove_non_numeric_cols(dataframe)
  calculate_summaries(dataframe, summaries, parallel, mc.cores)
}

#' Calculate columnwise summaries for a data frame.
#' @inheritParams calculate_numeric_summaries
#' @export
calculate_character_summaries <- function(dataframe, summaries = default_character_summaries, parallel = FALSE, mc.cores = parallel::detectCores()) {
  dataframe <- remove_non_character_cols(dataframe)
  calculate_summaries(dataframe, summaries, parallel, mc.cores)
}

calculate_summaries <- function(dataframe, summaries, parallel = FALSE, mc.cores = parallel::detectCores()) {
  output <- list()
  output$variables <- names(dataframe)
  if (isTRUE(parallel)) {
    output[names(summaries)] <- lapply(summaries, function(fn) {
      unlist(parallel::mclapply(dataframe, fn, mc.cores = mc.cores))
    })
  } else {
    output[names(summaries)] <- lapply(summaries, function(fn) {
      vapply(dataframe, fn, numeric(1))
    })
  }
  as.data.frame(output, stringsAsFactors = FALSE) %>% `row.names<-`(., NULL)
}
