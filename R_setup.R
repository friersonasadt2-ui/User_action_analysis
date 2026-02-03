suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
  library(dplyr)
  library(stringr)
  library(ggplot2)
  library(scales)
})

#工程文件夹
dir.create("data",   showWarnings = FALSE, recursive = TRUE)
dir.create("output", showWarnings = FALSE, recursive = TRUE)
dir.create("R",      showWarnings = FALSE, recursive = TRUE)

#分类文件夹
out_root  <- "output"

dir_data  <- file.path(out_root, "00_data")
dir_feat  <- file.path(out_root, "01_features")
dir_dict  <- file.path(out_root, "02_dict")
dir_uni   <- file.path(out_root, "03_validation_uni")
dir_multi <- file.path(out_root, "04_validation_multi")
dir_model <- file.path(out_root, "05_model")

dirs <- c(out_root, dir_data, dir_feat, dir_dict, dir_uni, dir_multi, dir_model)
invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

cat(paste0(dirs), sep = "\n")

#时间解析
parse_time_utc <- function(x) {
  x <- str_trim(gsub("/", "-", as.character(x)))
  
  out <- as.POSIXct(x, format = "%Y-%m-%d %H", tz = "UTC")
  
  if (anyNA(out)) {
    out2 <- as.POSIXct(x, format = "%Y-%m-%d %H:%M", tz = "UTC")
    out[is.na(out)] <- out2[is.na(out)]
  }
  if (anyNA(out)) {
    out3 <- as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    out[is.na(out)] <- out3[is.na(out)]
  }
  out
}


fill0_numeric <- function(DT) {
  num_cols <- names(DT)[sapply(DT, is.numeric)]
  posix_cols <- names(DT)[sapply(DT, inherits, "POSIXct")]
  num_cols <- setdiff(num_cols, posix_cols)
  
  for (cn in num_cols) {
    DT[is.na(get(cn)), (cn) := 0]
  }
  DT
}
