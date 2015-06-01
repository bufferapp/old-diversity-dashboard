library(data.table);
library(dplyr);
library(tidyr);


cleanGoogleTable <- function(dat, table=1, skip=0, ncols=NA, nrows=-1, header=TRUE, dropFirstCol=NA){
      if(!is.data.frame(dat)){
              dat <- dat[[table]]
  }
  if(is.na(dropFirstCol)) {
          firstCol <- na.omit(dat[[1]])
      if(all(firstCol == ".") || all(firstCol== as.character(seq_along(firstCol)))) {
                dat <- dat[, -1]
          }
        } else if(dropFirstCol) {
                dat <- dat[, -1]
          }
    if(skip > 0){
            dat <- dat[-seq_len(skip), ]
      }
    if(nrow(dat) == 1) return(dat)
      if(nrow(dat) >= 2){
              if(all(is.na(dat[2, ]))) dat <- dat[-2, ]
      }
      if(header && nrow(dat) > 1){
              header <- as.character(dat[1, ])
          names(dat) <- header
              dat <- dat[-1, ]
            }
        # Keep only desired columns
        if(!is.na(ncols)){
                ncols <- min(ncols, ncol(dat))
            dat <- dat[, seq_len(ncols)]
              }
        # Keep only desired rows
        if(nrows > 0){
                nrows <- min(nrows, nrow(dat))
            dat <- dat[seq_len(nrows), ]
              }
          # Rename rows
          rownames(dat) <- seq_len(nrow(dat))
          dat
}

readGoogleSheet <- function(url, na.string="", header=TRUE){
    day <-format(Sys.time(), "%Y-%m-%d")
    filename <- paste0('/data/data',day,'.csv')
    if (!file.exists(filename))
        download(url, destfile=filename)

    # Suppress warnings because Google docs seems to have incomplete final line
    suppressWarnings({
        doc <- paste(readLines(filename), collapse=" ")
    })
    if(nchar(doc) == 0) stop("No content found")
    htmlTable <- gsub("^.*?(<table.*</table).*$", "\\1>", doc)
    ret <- readHTMLTable(htmlTable, header=header, stringsAsFactors=FALSE, as.data.frame=TRUE)
    raw <- lapply(ret, function(x){ x[ x == na.string] <- NA; x})
    cleanGoogleTable(raw, table=1)
}


cleanUpData <- function(data) {
        ## IMPORT AND TIDY DATA
    names(data) <- c("datetime","gender","ethnicity","region","age_range","department")

    data$ethnicity <- gsub("White","Caucasian",data$ethnicity)
    data$ethnicity <- gsub("Southeast Asian","Asian",data$ethnicity)
    data
}
