lapply(c("download_files.R", "read_abs_vintages.R", "legacy_vintages.R"), source)

dates <- seq(as.Date("2006-03-01"), as.Date("2019-03-31"), by="quarter")

# Get available files for vintages between 2006 and 2011 

cpi_files <- get_files(dates, cat_no="6401.0") # CPI
wpi_files <- get_files(dates, cat_no="6345.0") # WPI

# Download all the CPI Files.

download_absfiles(cpi_files, download_dir = "./", vintage_dir = TRUE, 
                  vintage_prefix = TRUE)

# Download only Table 1 of the WPI 
table_1_wpi <- wpi_files |>
  dplyr::filter(FileName == "634501.xls")

download_absfiles(table_1_wpi, download_dir = "./data/")

# Read in data using readabs
wpi_vintages <- read_absfiles(dates, cat_no = "6345.0", download_dir = "./data/")
