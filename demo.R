# TODO
# currently doesn't work for selected dates.


# Get CPI data for 2009-03-31

files <- get_files(as.Date("2009-03-31"), publication_id = "6401.0") |> 
  dplyr::filter(FileType != "pdf")

download_files(files)


# Get CPI data for all vintages 
dates <- seq(as.Date("2007-03-01"), as.Date("2011-12-31"), by="quarter")
files <- purrr::map(dates, purrr::partial(get_files, publication_id="6401.0"))

get_files(as.Date("2012-03-31"), publication_id = "6401.0")
