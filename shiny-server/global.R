library(data.table)
library(dplyr)
library(tidyr)
library(plotly)


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
    filename <- paste0('./data/',name,day,'.csv')
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
    data$ethnicity <- gsub("^Caucasian.*$", replacement = "Caucasian",data$ethnicity,ignore.case=T)
    data$ethnicity <- gsub("^White.*$", replacement = "Caucasian",data$ethnicity,ignore.case=T)

    data$ethnicity <- gsub("Southeast Asian","Asian",data$ethnicity)
    data$ethnicity <- gsub("Chinese","Asian",data$ethnicity)
    data$ethnicity <- gsub("Taiwanese","Asian",data$ethnicity)
    data$ethnicity <- gsub("Hispanic/Caucasian","Mixed Race",data$ethnicity)

    data$ethnicity <- ifelse(data$ethnicity %in% radioEthnicity, data$ethnicity,"Self Described")

    data
}

readData <- function (key='team') {
    team_url <- 'https://docs.google.com/spreadsheets/u/1/d/1E9WwcIEYuGxR8GUrmxL1iaozOk_0FKSPPWbnCDn_C0A/pubhtml'
    applicants_url <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"
    u <- list(team=team_url, applicants=applicants_url)

    d <- readGoogleSheet(u[key], key)
    cleanUpData(d)
}

#This script is necessary in the app folder
#but the user should not have to edit it

#Output Graph Function
graphOutput <- function(inputId, width="100%", height="550px") {
  tagList(
    singleton(tags$head(
      tags$script(src="plotlyGraphWidget.js")
    )),
    tags$iframe(id=inputId, src="https://plot.ly/~playground/7.embed",
                class="graphs", style="border:none;", seamless=TRUE, width=width, height=height)
  )
}

renderGraph <- function(expr, env=parent.frame(), quoted=FALSE) {
  ## This gets called when inputs change --
  ## Place data wrangling code in here
  ## and pass the result to the client
  ## to be graphed.
  
  installExprFunction(expr, "func", env, quoted)
  
  function(){
    data = func();
    ## data is the state of the widgets: see server.R
    ## this function returns a list of named lists that descripe
    ## valid postMessage commands to be sent to the embedded iframe.
    ## see binding.renderValue for the receiving JS side of this function
    ## and https://github.com/plotly/Embed-API for more about the postMessage
    ## graph messages
    return(data)
  }
}
