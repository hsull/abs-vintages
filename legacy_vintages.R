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
  sub_section <- stringr::str_split(parsed_url$path, "/")[[1]][[3]]
  
  file_name <- query[[2]]
  code <- query[[5]]
  url <- sprintf("https://www.abs.gov.au/ausstats/%s/0/%s/$File/%s",
                 sub_section,
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
  
  hrefs <- listentry |> 
    html_elements("a") |> 
    html_attr("href")
  
  icon_descs <- listentry |> 
    html_elements("a") |>
    html_elements("img") |>
    html_attr("alt") 
  
  func <- function(icon_desc, href) {
    if (stringr::str_detect(icon_desc, "Download")) {
      parsed <- sprintf("https://www.ausstats.abs.gov.au%s", href) |> 
        parse_downloadurl()
      df <- (data.frame(Name=name, Link=parsed$url, FileName=parsed$file_name,
                        FileType=parsed$ext))
    } else {
      df <- NULL
    }
    df
  }
  purrr::map2(icon_descs, hrefs, func) |>
    dplyr::bind_rows()
}

get_files_for_vintage_legacy <- function(vintage_date, cat_no) {
  url <- get_url(vintage_date, cat_no)
  html <- read_html(url)
  list_entries <- html |> 
    html_elements("#mainpane") |> 
    html_elements(".listentry") 
  file_data <- purrr::map(list_entries, function(x) parse_listentry(x)) |> 
    dplyr::bind_rows() |> 
    dplyr::mutate(Vintage = vintage_date, 
                  CatNo = cat_no)
}