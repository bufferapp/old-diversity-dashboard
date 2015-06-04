library(data.table)
library(dplyr)
library(tidyr)


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

urls <- function() {
    team_url <- 'https://docs.google.com/spreadsheets/u/1/d/1E9WwcIEYuGxR8GUrmxL1iaozOk_0FKSPPWbnCDn_C0A/pubhtml'
    applicants_url <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"
    list(team=team_url, applicants=applicants_url)
}

readGoogleSheet <- function(url, name, na.string="", header=TRUE){
    day <-format(Sys.time(), "%Y-%m-%d")
    filename <- paste0('/data/','foo',name,day,'.csv')
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

    data
}

mergeData <- function(data) {
    radioEthnicity <- c('Asian',
                        'Black/African',
                        'Caucasian',
                        'Chinese',
                        'Hispanic/Latino',
                        'Indian',
                        'Indigenous Australian',
                        'Native American',
                        'Pacific Inslander',
                        'Southeast Asian',
                        'West Asian/Middle Eastern',
                        'Mixed Race',
                        'Prefer Not to Answer'
    )
    data$ethnicity <- gsub("White","Caucasian",data$ethnicity)
    data$ethnicity <- gsub("Southeast Asian","Asian",data$ethnicity)

    data[!(data$ethnicity %in% radioEthnicity),]$ethnicity <- 'Self described'
    data
}

readData <- function (key='team') {
    team_url <- 'https://docs.google.com/spreadsheets/u/1/d/1E9WwcIEYuGxR8GUrmxL1iaozOk_0FKSPPWbnCDn_C0A/pubhtml'
    applicants_url <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"
    u <- list(team=team_url, applicants=applicants_url)

    d <- readGoogleSheet(u[key], key)
    cleanUpData(d)
}
