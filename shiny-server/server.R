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

        applicants_data <- readGoogleSheet(applicants_url)
        applicants_data <- cleanUpData(applicants_data)

        team_data <- readGoogleSheet(team_url)
        team_data <- cleanUpData(team_data)

        ## RETURN REQUESTED DATASET
        datasetInput <- reactive({
          switch(input$dataset,
                 "Buffer Team" = team_data,
                 "Applicants" = applicants_data)
        })


        #plots
        output$ethnicityPlot <- renderPlot({
            data <- datasetInput()

            department_and_gender <- data %>%
            group_by(department,gender) %>%
            summarise(n=n()) %>%
            mutate(percent=n/sum(n),department_size=sum(n))
            ggplot(department_and_gender, aes(x=reorder(department,-department_size), y=n, fill=gender)) +
            geom_bar(stat="identity") + scale_fill_brewer(palette="Pastel1") +
                labs(x="Area at Buffer",y="Team Members", title="Gender Breakdown of Buffer Across Areas")
        })

        #raw data
        output$table <- renderTable({datasetInput()})


}
