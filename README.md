
<!-- README.md is generated from README.Rmd. Please edit that file -->

# brisbraries

`brisbraries` provides tidied up data from the [Brisbane library
checkouts](https://www.data.brisbane.qld.gov.au/data/dataset/library-checkouts-branch-date#)

## Installation

You can install the released version of brisbraries from github with:

``` r
install_github("njtierney/brisbraries")
```

## Example

Let’s

``` r
library(brisbraries)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
count(bris_libs_tidy, title, sort = TRUE) 
#> # A tibble: 121,046 x 2
#>    title                                n
#>    <chr>                            <int>
#>  1 Australian house and garden       1469
#>  2 New scientist (Australasian ed.)  1380
#>  3 Australian home beautiful         1331
#>  4 Country style                     1229
#>  5 The New idea                      1186
#>  6 Hello                             1133
#>  7 Woman's day                       1096
#>  8 Country life                      1056
#>  9 Better homes and gardens. (AU)    1041
#> 10 Yi Zhou Kan                        884
#> # ... with 121,036 more rows
count(bris_libs_tidy, item_type, sort = TRUE) 
#> # A tibble: 69 x 2
#>    item_type       n
#>    <chr>       <int>
#>  1 PICTURE-BK 121126
#>  2 DVD         98283
#>  3 AD-PBK      91671
#>  4 JU-PBK      88402
#>  5 NONFICTION  76168
#>  6 AD-MAGS     60516
#>  7 AD-FICTION  53090
#>  8 LARGEPRINT  19113
#>  9 JU-FICTION  17261
#> 10 LOTE-BOOK   12303
#> # ... with 59 more rows
count(bris_libs_tidy, age, sort = TRUE) 
#> # A tibble: 5 x 2
#>   age           n
#>   <chr>     <int>
#> 1 ADULT    420287
#> 2 JUVENILE 283902
#> 3 YA        13715
#> 4 <NA>        147
#> 5 UNKNOWN      36
count(bris_libs_tidy, library, sort = TRUE) 
#> # A tibble: 38 x 2
#>    library     n
#>    <chr>   <int>
#>  1 SBK     49154
#>  2 BSQ     45968
#>  3 CNL     45642
#>  4 IPY     44569
#>  5 GCY     43090
#>  6 CDE     42775
#>  7 ASH     42086
#>  8 WYN     35124
#>  9 KEN     33947
#> 10 MTO     31201
#> # ... with 28 more rows
```

# License

This data is provided under a [CC BY 4.0
license](https://creativecommons.org/licenses/by/4.0/)

It has been downloaded from [Brisbane library
checkouts](https://www.data.brisbane.qld.gov.au/data/dataset/library-checkouts-branch-date#),
and tidied up using the code in `data-raw`.
