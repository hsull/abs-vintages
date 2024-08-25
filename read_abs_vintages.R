library(xml2)
library(httr2)

get_url <- function(vintage_date, release_id) {
  month <- format(vintage_date, "%b") |> as.character()
  year <- format(vintage_date, "%Y") |> as.character()
  url <-paste0("https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/", 
               release_id, month, "%20",year, "?OpenDocument")
  url
}

clean_name <- function(name) {
  stringr::str_remove_all(name, "[\\t\\.]")
}

parse_downloadurl <- function(download_url) {
  parsed_url <- httr2::url_parse(download_url)
  query <- names(parsed_url$query)
  
  file_name <- query[[2]]
  code <- query[[5]]
  url <- sprintf("https://www.ausstats.abs.gov.au/ausstats/meisubs.nsf/0/%s/$File/%s",
                 code,
                 file_name)
  list(file_name=file_name,
       url=url,
       ext=tools::file_ext(file_name))
}

parse_listentry <- function(listentry) {
  name <- listentry |> 
    html_text2() |> 
    clean_name()
  
  href <- listentry |> 
    html_element("a") |> 
    html_attr("href")
  
  parsed <- sprintf("https://www.ausstats.abs.gov.au%s", href) |> 
    parse_downloadurl()
  
  return(data.frame(Name=name, Link=parsed$url, FileName=parsed$file_name,
                    FileType=parsed$ext))
}

#' @param data data frame containing files.
#' @param download_dir directory to download the files to. 
download_files <- function(data, download_dir="./") {
  purrr::map2(data$FileName, data$Link, function(name,link) download.file(link, paste0(download_dir, "/", name), mode = "wb"))
  # mode = wb needed for windows
}


# Main Function -----------------------------------------------------------
get_files <- function(vintage_date, publication_id) {
  url <- get_url(vintage_date, publication_id)
  html <- read_html(url)
  list_entries <- html |> 
    html_elements("#mainpane") |> 
    html_elements(".listentry") 
  file_data <- purrr::map(list_entries, function(x) parse_listentry(x)) |> 
    dplyr::bind_rows()
  file_data
}