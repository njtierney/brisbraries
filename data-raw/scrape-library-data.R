library(xml2)
library(rvest)
library(purrr)
library(stringr)

URL <- "https://www.data.brisbane.qld.gov.au/data/dataset/library-checkouts-branch-date#"

# get the library links
library_links <- read_html(URL) %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  str_subset(".csv$")

fs::dir_create("data")


# make it a function to save to data/
save_library_to_data <- function(x){
  download.file(x,
                glue::glue("data-raw/{extract_file_name(x)}"))
}


# convert to a function
download_brisbane_library_checkouts <- function(){
  walk(library_links, save_library_to_data)
}

# let's turn this into a function
tidy_lib_names <- function(x){
  x %>%
  str_remove("^library-checkouts-by-date---") %>%
  str_remove("^library-checkouts-all-branches-")
}


# now let's add that to `extract_file_name`
extract_file_name <- function(x) {
  old_name <- str_split(x, 
                        pattern = "/") %>%
    flatten_chr() %>%
    pluck(length(.)) %>%
    tidy_lib_names()
  
  # if the file does not contain a number, return old name
  if (is.data.frame(attributes(suppressWarnings(readr::parse_number(old_name)))$problems)) {
    return(old_name)
  }
  # if the file does contain a number, tidy it up
  if (is.numeric(suppressWarnings(readr::parse_number(old_name)))) {
    # actually let's make the names so that they are YYYY-month
    ext_year <- readr::parse_number(old_name) %>% 
      str_remove("-") %>%
      str_remove("v2")
    
    ext_month <- str_extract(old_name, "[a-z]+")
    
    # print new name
    return(glue::glue("{ext_year}-{ext_month}.csv"))
  }
  
}

# now let's re-download the data
download_brisbane_library_checkouts()

# now let's combine the data
# get all file paths from data-raw that start with a number
data_paths <- list.files("data-raw/", full.names = TRUE)

all_raw_data <- fs::dir_map("data-raw/", 
                            readr::read_csv)

metadata <- all_raw_data[[16]]

all_libraries <- all_raw_data[1:15]

all_libraries

bris_libs_raw <- data.table::rbindlist(all_libraries) %>% 
  tibble::as_tibble() %>%
  janitor::clean_names()

# do all dates have the same length? 
all(nchar(bris_libs_raw$date),na.rm = TRUE)

library(dplyr)
library(lubridate)

bris_libs <- bris_libs_raw %>%
  mutate(datetime = as.POSIXct(strptime(date, "%Y%m%e%H%M")),
         year = year(datetime),
         month = month(datetime),
         day = wday(datetime, label = TRUE))

View(bris_libs)
# Save as tidy data
use_description()
use_data(bris_libs)
