## Version 0.4.1-0.4.2
- Parallelize calculating stats over the columns of the dataframe, as that would
  give a bigger speedup, especially for summaries that take long to calculate.

## Version 0.4.0
- Add support for parallelization via `parallel::mclapply`.

## Version 0.3.4
- Make `within_tolerance` a bit more robust with respect to special cases (handling zeroes and NAs).
- Minor bugfixes between 0.3.0 - 0.3.3

## Version 0.3.0
- renamed `calculate_summaries` and `compare_distributions` to `calculate_numeric_summaries` and `compare_numeric_distributions`.
- Added support for character data frames via `calculate_character_summaries` and `compare_character_distributions`. Use the options "vardist.character_discrete_tolerance", "vardist.character_percent_tolerance", "vardist.character_uniques_threshold", and "vardist.character_uniques_tolerance" to control the default tests.

## Version 0.2.5
- Added options "vardist.summary_tolerance" and "vardist.ks_test_threshold", for use with `default_tests`.

## Version 0.2.4
- Added function `generate_report_from_summaries`.

## Version 0.2.3
- Moved `magrittr` from `Imports` to `Depends`.

## Version 0.2.2
- Enforcing numeric columns only in `calculate_summaries`.

## Version 0.2.1
- Fixed Roxygen documentation, actually exporting functions.

## Version 0.2.0
- Constructed default values for `summaries` and `tests`.
- Added documentation via Roxygen, as well as a more detailed README.
- Renamed main function to `compare_distributions`.

## Version 0.1.0
- Added main function, `variable_summaries`.

## Version 0.0.2
- Created tool to generate reports from stats and data.

## Version 0.0.1
- The initial creation of the package.
