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
  team_url <- 'https://docs.google.com/spreadsheets/d/17rf2ggqrYusM2u0esd_HG3z7iR1pve08F0CpYTEs6mE/pubhtml'
  list(team=team_url)
}

readGoogleSheet <- function(url, name, na.string="", header=TRUE){
  day <-format(Sys.time(), "%Y-%m-%d")
  filename <- paste0('/data/',name,day,'.csv')
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


cleanUpNames <- function(data) {
  if (length(names(data)) == 8) {
    names(data) <- c("datetime","gender","ethnicity","region","age_range","department", "comment","opt_in")
  } else if(length(names(data)) == 7) {
    names(data) <- c("datetime","gender","ethnicity","region","age_range","department", "comment")
  } else {
    names(data) <- c("datetime","gender","ethnicity","region","age_range","department")
  }

  data
}

removeOptOut <- function(data) {
  data[!grepl('please keep',data$opt_in), ]
}

mergeData <- function(data) {
  radioEthnicity <- c('Asian/Asian Other',
                      'Black/African/Caribbean/Black Other',
                      'Latino/Hispanic',
                      'Mixed/Multiple ethnic groups',
                      'Other ethnic group',
                      'Pacific Islander',
                      'Prefer not to say',
                      'Self-described',
                      'White/Caucasian/White Other'
  )
  data$ethnicity <- ifelse(data$ethnicity %in% radioEthnicity, data$ethnicity,"Self Described")

  data
}

readData <- function (key='team') {
  team_url <- 'https://docs.google.com/spreadsheets/d/17rf2ggqrYusM2u0esd_HG3z7iR1pve08F0CpYTEs6mE/pubhtml'
  u <- list(team=team_url)

  d <- readGoogleSheet(u[key], key)
  cleanUpNames(d)
}

getDataForInput <- function (input) {
  switch(input$dataset,
         "The ustwo Team" = data$team %>%
           filter(gender %in% input$genderFilter) %>%
           filter(ethnicity %in% input$ethnicityFilter) %>%
           filter(age_range %in% input$ageFilter) %>%
           filter(department %in% input$areaFilter)
  )
}

getFilteredData <- function(key, input) {
  data[[key]] %>%
    filter(gender %in% input$genderFilter) %>%
    filter(ethnicity %in% input$ethnicityFilter) %>%
    filter(age_range %in% input$ageFilter) %>%
    filter(department %in% input$areaFilter)
}


groupSumAndPercent <- function(data, by) {
  data %>%
    regroup(list('department', by)) %>%
    summarise(n=n()) %>%
    mutate(percent=n/sum(n),department_size=sum(n))

}

reGroupMeanAndSd <- function(data) {
  data %>%
    filter(department_size > 3) %>% #significant sample
    group_by(department) %>%
    summarise(mean=mean(n),sd=sd(n), sum=sum(n))
}

team_url <- 'https://docs.google.com/spreadsheets/d/17rf2ggqrYusM2u0esd_HG3z7iR1pve08F0CpYTEs6mE/pubhtml'

team_raw <- readGoogleSheet(team_url, 'team')
team_raw <- team_raw[,colSums(is.na(team_raw))<nrow(team_raw)]
team_raw <- cleanUpNames(team_raw)

team <- mergeData(team_raw)

data <- list(team_raw=team_raw, team=team)
