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

# now I need to download them all. But let's practice for one.
download.file(library_links[1],
              "data/link_1.csv")

# OK, but now it needs a better name
library_links[1]

# OK crap, there is no info in this.

# what's in the data?
link_1 <- readr::read_csv("data/link_1.csv")

View(link_1)
# OK, this looks like metadata. That is fine.

# let's look at the second dataset
download.file(library_links[2],
              "data/link_2.csv")

# It's got a sane name as well
library_links[2]

# what's in the data?
link_2 <- readr::read_csv("data/link_2.csv")

# OK, there's date info in there as well.
View(link_2)

# Now let's extract the last element of the html to find a good file name
str_split(library_links[2],
          pattern = "/") %>%
  flatten_chr() %>%
  pluck(length(.))

# let's make this a function as we are going to repeat this
extract_file_name <- function(x) {
  str_split(x, 
            pattern = "/") %>%
  flatten_chr() %>%
  pluck(length(.)) %>%
    
}

# test it out
extract_file_name(library_links[2])

# test it inside download.file
download.file(library_links[1],
              extract_file_name(library_links[1]))

# make it a function to save to data/
save_library_to_data <- function(x){
  download.file(x,
                glue::glue("data/{extract_file_name(x)}"))
}

# test it out
save_library_to_data(library_links[1])

# save all the data
walk(library_links, save_library_to_data)

# convert to a function
download_brisbane_library_checkouts <- function(){
  walk(library_links, save_library_to_data)
}

# Now, I've found that a lot of the names are repeated.
# let's remove the parts we don't like
extract_file_name(library_links[2]) %>%
  str_remove("^library-checkouts-by-date---") %>%
  str_remove("^library-checkouts-all-branches-")

# let's turn this into a function
tidy_lib_names <- function(x){
  x %>%
  str_remove("^library-checkouts-by-date---") %>%
  str_remove("^library-checkouts-all-branches-")
}

library_links[2] %>%
  extract_file_name() %>%
  tidy_lib_names() 

# now let's add that to `extract_file_name`
extract_file_name <- function(x) {
  str_split(x, 
            pattern = "/") %>%
    flatten_chr() %>%
    pluck(length(.)) %>%
    tidy_lib_names()
}

# now let's re-download the data
download_brisbane_library_checkouts()

# actually let's make the names so that they are YYYY-month
old_name <- extract_file_name(library_links[2])

ext_year <- readr::parse_number(old_name) %>% 
  str_remove("-") %>%
  str_remove("v2")

ext_year

ext_month <- str_extract(old_name, "[a-z]+")

new_name <- glue::glue("{ext_year}-{ext_month}.csv")

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

extract_file_name(library_links[1])
extract_file_name(library_links[2])

# now let's re-download the data
download_brisbane_library_checkouts()

# now let's combine the data

# but let's put the raw data into a raw-data folder
save_library_to_data <- function(x){
  download.file(x,
                glue::glue("data-raw/{extract_file_name(x)}"))
}

# fs::dir_create("data-raw")

# now let's re-download the data
download_brisbane_library_checkouts()

# now let's combine the data
# get all file paths from data-raw that start with a number
fs::path_file("data-raw/")

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

strptime(bris_libs_raw$date[1], "%Y%m%e%I%M")

all_bris_dates <- strptime(bris_libs_raw$date, "%Y%m%e%H%M")

library(dplyr)
library(lubdridate)
bris_libs_tidy <- bris_libs_raw %>%
  mutate(datetime = as.POSIXct(strptime(date, "%Y%m%e%H%M")))

# Save as tidy data
use_description()
use_data(bris_libs_tidy)
