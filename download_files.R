download_absfile <- function(row, download_dir, vintage_dir=FALSE, cat_dir=FALSE, vintage_prefix=FALSE) {
  name <- row$FileName
  file_type <- row$FileType
  link <- row$Link
  vintage <- as.character(row$Vintage)
  cat_no <- as.character(row$CatNo)
  
  if (file_type == "pdf") {
    warning("Unable to download pdf files.")
    return(NULL)
  }
  
  # Save the file into a subdirectory with the vintage name.
  if (vintage_dir) {
    vintage_dirname <- sprintf("%s/%s", download_dir, vintage)
    if(!dir.exists(vintage_dirname)) {
      dir.create(vintage_dirname)
    }
    download_dir <- vintage_dirname
  } 
  
  # Save the file into a subdirectory with the cat name
  if (cat_dir) {
    cat_dirname <- sprintf("%s/%s", download_dir, cat_no)
    if(!dir.exists(cat_dirname)) {
      dir.create(cat_dirname)
    }
    download_dir <- cat_dirname
  }
  
  # Add the vintage to the front of the file name.
  if (vintage_prefix) {
    name <- sprintf("%s_%s", vintage, name)
  }
  
  # mode = wb needed for windows
  download.file(link, paste0(download_dir, "/", name), mode = "wb")
}

#' @param data data frame containing files.
#' @param download_dir directory to download the files to. 
download_absfiles <- function(data, download_dir="./",
                              vintage_dir=TRUE,
                              cat_dir=TRUE,
                              vintage_prefix=FALSE) {
  if (nrow(data) == 0) {
    stop("No rows in input data")
  }
  split(data, 1:nrow(data)) |>
    purrr::map(purrr::partial(download_absfile, 
                              download_dir=download_dir, 
                              vintage_dir=vintage_dir,
                              cat_dir=cat_dir,
                              vintage_prefix=vintage_prefix))
}
