library("XML")
library("ggplot2")
library("downloader")
library('scales')
library('grid')
library('RColorBrewer')

function(input, output) {
        filterAreas <- function(data,areas) {
           data[data$department %in% areas,]
        }
        data <- list()

        team_url <- 'https://docs.google.com/spreadsheets/u/1/d/1E9WwcIEYuGxR8GUrmxL1iaozOk_0FKSPPWbnCDn_C0A/pubhtml'
        applicants_url <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"

        data$applicants_raw <- readGoogleSheet(applicants_url, 'applicants')
        data$applicants_raw <- cleanUpData(data$applicants_raw) 

        data$team_raw <- readGoogleSheet(team_url, 'team')
        data$team_raw <- cleanUpData(data$team_raw) 

        data$applicants <- mergeData(data$applicants_raw)
        data$team <- mergeData(data$team_raw)

        ## RETURN REQUESTED DATASET
        datasetInput <- reactive({
          switch(input$dataset,
                 "The Buffer Team" = filterAreas(data$team, input$areaFilter),
                 "Applicants" = filterAreas(data$applicants, input$areaFilter))
        })


        #bar charts
        output$genderPlot <- renderPlot({
            data <- datasetInput()
            department_and_gender <- data %>%
                group_by(department,gender) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department_size=sum(n))

            total_row <- data %>%
                group_by(gender) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department="Total", department_size=n)

            output$debugTable2 <-renderTable(total_row)

            total_gender_breakdown <- rbind(department_and_gender,total_row)
            #total_gender_breakdown$gender <- factor(total_gender_breakdown$gender,levels=rev(levels(total_gender_breakdown$gender)))
            if(input$plotType == 'p') {
                ggplot(total_gender_breakdown,aes(x=factor(1),y=percent,fill=gender)) +
                  geom_bar(stat="identity",width=1) +
                  facet_wrap(~department) +
                  coord_polar(theta="y") +
                  scale_fill_brewer(palette="Pastel1") +
                  theme_minimal() +
                  theme(axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank()) +
                  labs(x="",y="",title="Gender Breakdown\n")
            }
            else {
                ggplot(department_and_gender, aes(x=reorder(department,-department_size), y=n, fill=gender)) +
                    geom_bar(stat="identity") + scale_fill_brewer(palette="Pastel1") +
                    labs(x="\nArea at Buffer",y="People", title="Gender Breakdown Across Areas\n") +
                    theme_minimal() 
              }
        })

        output$genderTimeSeries <- renderPlot({
            data <- datasetInput()
            data <- data[-1,]
            data$posixDateTime <- as.POSIXct(data$date,format="%m/%d/%Y")
            data$posixDate <- as.Date(data$posixDateTime)

            time_and_gender <- data %>%
                group_by(posixDate,gender) %>%
                summarise(n=n())

           #fill in empty time series data with zeros to make stacked area chart
           empty <- expand.grid(posixDate=unique(time_and_gender$posixDate), gender=unique(time_and_gender$gender))
           time_and_gender <- merge(x=empty, y=time_and_gender, all.x=T) 
           time_and_gender[is.na(time_and_gender$n),]$n <- 0

            output$debugTable1 <-renderTable(time_and_gender)
            output$debugTable2 <-renderTable(empty)

            ggplot(time_and_gender, aes(x=posixDate,y=n, fill=gender)) +
                geom_area(stat="Identity") +
                scale_fill_brewer(palette="Pastel1") +
                labs(x="Date",y="People", title="Gender of Applicants over time\n") +
                theme_minimal()

        })

        output$ethnicityPlot <- renderPlot({
            data <- datasetInput()

            department_and_ethnicity <- data %>%
                group_by(department,ethnicity) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department_size=sum(n))


            by_ethnicity <- data %>%
                group_by(department,ethnicity) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n))

             total_ethnicity_row <- data %>%
                group_by(ethnicity) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department="Total")


            total_ethnicity_breakdown <- rbind(by_ethnicity,total_ethnicity_row)

            if(input$plotType == 'p') {
                ggplot(total_ethnicity_breakdown,aes(x=factor(1),y=percent,fill=ethnicity)) +
                    geom_bar(stat="identity",width=1) + 
                    facet_wrap(~department) +
                    coord_polar(theta="y") + 
                    scale_fill_brewer(palette="Pastel1") +
                    theme_minimal() +
                    theme(axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank()) +
                    labs(x="",y="",title="Ethnicity Breakdown\n")
            } else {
                ggplot(department_and_ethnicity, aes(x=reorder(department,department_size), y=n, fill=ethnicity)) +
                    geom_bar(stat="identity") + scale_y_continuous(breaks=seq(0,10,2)) + coord_flip() +
                    labs(x="Area at Buffer",y="\nPeople", title="Ethnicity Breakdown Across Areas\n") +
                    scale_fill_brewer(palette="Pastel1") + theme_minimal()
            }
        })

        output$ethnicityTimeSeries <- renderPlot({
            data <- datasetInput()
            data <- data[-1,]
            data$posixDateTime <- as.POSIXct(data$date,format="%m/%d/%Y")
            data$posixDate <- as.Date(data$posixDateTime)

            time_and_ethnicity <- data %>%
                group_by(posixDate,ethnicity) %>%
                summarise(n=n())

           #fill in empty time series data with zeros to make stacked area chart
           empty <- expand.grid(posixDate=unique(time_and_ethnicity$posixDate), ethnicity=unique(time_and_ethnicity$ethnicity))
           time_and_ethnicity <- merge(x=empty, y=time_and_ethnicity, all.x=T) 
           time_and_ethnicity[is.na(time_and_ethnicity$n),]$n <- 0

            output$debugTable1 <-renderTable(time_and_ethnicity)
            output$debugTable2 <-renderTable(empty)

            ggplot(time_and_ethnicity, aes(x=posixDate,y=n, fill=ethnicity)) +
                geom_area(stat="Identity") +
                scale_fill_brewer(palette="Pastel1") +
                labs(x="Date",y="People", title="Ethnicity of Applicants over time\n") +
                theme_minimal()

        })


        #raw data
        output$teamTable <- renderTable(data$team_raw)
        output$applicantsTable <- renderTable(data$applicants_raw)
}
