library(xml2)
library(httr2)

get_files_for_vintage <- function(vintage_date, cat_no) {
  if (vintage_date >= as.Date("2019-06-01")) {
    stop("Vintages past June 2019 are not supported. You can use the readabs 
         package to download and read these.")
  } else {
    file_data <- get_files_for_vintage_legacy(vintage_date, cat_no)
  }
  file_data  
}

# Main Function -----------------------------------------------------------
get_files <- function(vintage_dates, cat_no) {
  purrr::map(vintage_dates, purrr::partial(get_files_for_vintage, 
                                           cat_no=cat_no)) |>
    dplyr::bind_rows()
  
}


read_absfile <- function(vintage_date, cat_no, download_dir) {
  path <- sprintf("%s/%s", download_dir, vintage_date)
  read_absfile_ <- function() {
      readabs::read_abs_local(cat_no=cat_no, path = path) |>
      dplyr::mutate(vintage=vintage_date)
  }
  
  onError <- function(e) {
    print(sprintf("Unable to read %s", path))
    NULL
  }
  
  tryCatch(read_absfile_(), error=onError)
} 

#' 
#' Assumes the files are downloaded using the default parameters for download_absfiles.
read_absfiles <- function(vintage_dates, cat_no, download_dir) {
  purrr::map(vintage_dates, purrr::partial(read_absfile, cat_no=cat_no, download_dir=download_dir)) |>
    dplyr::bind_rows()
}
