library("XML")
library("ggplot2")
library("downloader")
library('scales')
library('grid')
library('RColorBrewer')



function(input, output) {
        team_url <- 'https://docs.google.com/spreadsheets/u/1/d/1E9WwcIEYuGxR8GUrmxL1iaozOk_0FKSPPWbnCDn_C0A/pubhtml'
        applicants_url <- "https://docs.google.com/spreadsheets/d/11GXSEkgDnLIBWmqYWJA1VbG9xmsPPl2MFRWxvFiWmwQ/pubhtml"

        urls <- list(team = team_url, applicants = applicants_url)

        data <- list()

        data$applicants_raw <- readData('applicants')
        data$team_raw <- readData('team')
        data$applicants <- mergeData(data$applicants_raw)
        data$team <- mergeData(data$team_raw)

        ## RETURN REQUESTED DATASET
        datasetInput <- reactive({
          switch(input$dataset,
                 "The Buffer Team" = data$team,
                 "Applicants" = data$applicants)
        })
        datasetInputRaw <- reactive({
          switch(input$dataset,
                 "The Buffer Team" = data$team_raw,
                 "Applicants" = data$applicants_raw)
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

            output$debugTable1 <-renderTable(department_and_gender)
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


        #raw data
        output$teamTable <- renderTable(data$team_raw)
        output$applicantsTable <- renderTable(data$applicants_raw)
}
