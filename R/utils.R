# Copyright 2014-2017 Avant. Full copy of license can be found at https://github.com/avantcredit/vardist#license

get_common_columns <- function(df1, df2) {
  common_columns <- intersect(names(df1), names(df2))
  if (length(common_columns) == 0) {
    stop("The data frames provided have no common column names, ",
         "cannot calculate summaries.")
  }
  common_columns
}

subset_columns <- function(colnames, dataframe) {
  current_names <- names(dataframe)
  if (length(setdiff(colnames, current_names)) > 0) {
    stop("You passed in column names that were not in the data frame. This is bad!")
  }
  count_removed_columns <- length(setdiff(current_names, colnames))
  if (count_removed_columns > 0) {
    warning(deparse(substitute(dataframe)), " has ", count_removed_columns, " columns ",
            "not listed in ", deparse(substitute(colnames)), ". Removing extra columns.")
    dataframe[colnames]
  } else { dataframe }
}

remove_non_numeric_cols <- function(dataframe) {
  numeric_columns <- names(dataframe)[vapply(dataframe, is.numeric, logical(1))]
  subset_columns(numeric_columns, dataframe)
}

remove_non_character_cols <- function(dataframe) {
  character_columns <- names(dataframe)[vapply(dataframe, is.character, logical(1))]
  subset_columns(character_columns, dataframe)
}

subset_variables <- function(varnames, dataframe) {
  current_vars <- dataframe$variables
  if (is.null(current_vars)) {
    stop("The ", sQuote("variables"), " column in ", deparse(substitute(dataframe)),
         "is NULL, either your data frame is empty or ",
         "it has no column called ", sQuote("variables"), ".")
  }
  if (length(setdiff(varnames, current_vars))) {
    stop("You passed in variable names that were not in the data frame. This is bad!")
  }
  count_removed_vars <- length(setdiff(current_vars, varnames))
  if (count_removed_vars > 0) {
    warning(deparse(substitute(dataframe)), " has ", count_removed_vars, " variables ",
            "not listed in ", deparse(substitute(colnames)), ". Removing extra variables")
    is_in_varnames <- vapply(dataframe$variables, function(x) { x %in% varnames }, logical(1))
    dataframe[is_in_varnames, ]
  } else { dataframe }

}

