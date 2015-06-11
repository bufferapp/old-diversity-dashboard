team_url <- 'https://docs.google.com/spreadsheets/u/1/d/1E9WwcIEYuGxR8GUrmxL1iaozOk_0FKSPPWbnCDn_C0A/pubhtml'
applicants_url <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"

applicants_raw <- readGoogleSheet(applicants_url, 'applicants')
applicants_raw <- cleanUpData(applicants_raw)

team_raw <- readGoogleSheet(team_url, 'team')
team_raw <- cleanUpData(team_raw)

applicants <- mergeData(applicants_raw)
team <- mergeData(team_raw)

data <- list(applicants_raw=applicants_raw, team_raw=team_raw, applicants=applicants, team=team)

getFilteredData <- function(key, input) {
    data[[key]] %>%
        filter(gender %in% input$genderFilter) %>%
        filter(ethnicity %in% input$ethnicityFilter) %>%
        filter(age_range %in% input$ageFilter) %>%
        filter(department %in% input$areaFilter)
}

getDataForInput <- function (input) {
          switch(input$dataset,
                 "The Buffer Team" = data$team %>%
                    filter(gender %in% input$genderFilter) %>%
                    filter(ethnicity %in% input$ethnicityFilter) %>%
                    filter(age_range %in% input$ageFilter) %>%
                    filter(department %in% input$areaFilter),
                 "Applicants" = data$applicants %>%
                    filter(gender %in% input$genderFilter) %>%
                    filter(ethnicity %in% input$ethnicityFilter) %>%
                    filter(age_range %in% input$ageFilter) %>%
                    filter(department %in% input$areaFilter)
           )
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

