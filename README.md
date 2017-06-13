# vardist
[![forthebadge](http://forthebadge.com/images/badges/as-seen-on-tv.svg)](http://forthebadge.com)
===========

Variable distribution summaries in an easy-to-consume format, and tools to compare variable distributions between data sets.

You're welcome.

## Installation
```r
if (!require("devtools")) { install.packages("devtools") }
devtools::install_github("avantcredit/vardist")
```

## Quick Start

Let's suppose you have a data frame with all numeric fields. If you want variable summaries for this data frame, you can call `calculate_numeric_summaries`:

```r
library(vardist)
df <- data.frame(a = runif(100) + 5, b = runif(100) + 5)
calculate_numeric_summaries(df)
#   variables     mean standard_deviation     min first_quartile   median third_quartile      max percentile_10 percentile_90 missing_pct zero_pct
# 1         a 5.441890          0.2888938 5.01808       5.192760 5.412176       5.691090 5.968628      5.066621      5.893265           0        0
# 2         b 5.505793          0.2887159 5.01823       5.264106 5.542553       5.731539 5.994678      5.127110      5.908680           0        0
```

If you want to compare it to a data frame with baseline values, you can call `compare_numeric_distributions`:
```r
library(vardist)
baseline   <- data.frame(a = runif(100) + 5, b = runif(100) + 5)
challenger <- data.frame(a = runif(100) + 5, b = runif(100) + 8)
compare_numeric_distributions(challenger, baseline)
# $challenger_stats
#   variables     mean standard_deviation      min first_quartile   median third_quartile      max percentile_10 percentile_90 missing_pct zero_pct
# 1         a 5.490797          0.2876895 5.005764       5.254185 5.462860       5.755028 5.994012      5.107292      5.889627           0        0
# 2         b 8.514025          0.2765906 8.000728       8.272374 8.500748       8.765646 8.996240      8.158079      8.889809           0        0
#
# $baseline_stats
#   variables     mean standard_deviation      min first_quartile   median third_quartile      max percentile_10 percentile_90 missing_pct zero_pct
# 1         a 5.508399          0.2935941 5.026837       5.241170 5.469960       5.757797 5.999796      5.123201      5.929961           0        0
# 2         b 5.504826          0.2819114 5.005868       5.254398 5.482953       5.736300 5.972390      5.138694      5.914151           0        0
#
# $report
#   variables  mean standard_deviation  min first_quartile median third_quartile   max percentile_10 percentile_90 missing_pct zero_pct ks_test
# 1         a  TRUE               TRUE TRUE           TRUE   TRUE           TRUE  TRUE          TRUE          TRUE        TRUE     TRUE    TRUE
# 2         b FALSE               TRUE TRUE          FALSE  FALSE          FALSE FALSE         FALSE         FALSE        TRUE     TRUE   FALSE
```

There are analogous functions `calculate_character_summaries` and `compare_character_distributions`, which operate on character fields.


## Custom Summaries and Tests

The package comes with default choices of variable summaries and tests for comparison with the baseline. However, you can write your own custom summaries and tests.

For example, suppose you wanted one of your summaries to be the first element in a column, and the other to be a random element. (In practice, of course, you'd choose *useful* summaries.) Then, for your summaries, you would want:
```r
my_summaries <- list(
  first_element  = function(col) { col[1] },
  random_element = function(col) { col[sample(length(col), 1)] }
)
```

Now suppose that you want to test if the first elements of your data frames are identical, the random elements chosen are identical, and that columns have the same length. (Again, in practice, you'd run *useful* tests.) For your tests, you would want:
```r
my_tests <- list(
  first_element  = function(baseline_value, challenger_value, ...) { identical(baseline_value, challenger_value) },
  random_element = function(baseline_value, challenger_value, ...) { identical(baseline_value, challenger_value) },
  same_col_length = function(baseline_col, challenger_col) { length(baseline_col) == length(challenger_col) }
)
```

The first two elements are named after summaries, so they will have access to the summary values when they are exectued. They will also have access to the underlying columns of data - we write `...` here because we are not using them, but they will still be passed in to the test function.

The third element is not named after any summary, so it only has access to the data itself.

Putting it all together:
```r
library(vardist)
baseline   <- data.frame(a = runif(100) + 5, b = runif(100) + 5)
challenger <- data.frame(a = runif(100) + 5, b = runif(100) + 8)
compare_numeric_distributions(challenger, baseline, summaries = my_summaries, tests = my_tests)
# $challenger_stats
#   variables first_element random_element
# 1         a      5.993870       5.017843
# 2         b      8.494429       8.109733
#
# $baseline_stats
#   variables first_element random_element
# 1         a      5.828025       5.927089
# 2         b      5.727900       5.909929
#
# $report
#   variables first_element random_element same_col_length
# 1         a         FALSE          FALSE            TRUE
# 2         b         FALSE          FALSE            TRUE
```

## License

Copyright 2014-2017 Avant

Author: Abel Castillo

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
