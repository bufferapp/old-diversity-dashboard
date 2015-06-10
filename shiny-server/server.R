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
        filterEthnicities <- function(data,ethnicities) {
           data[data$ethnicity %in% ethnicities,]
        }
        filterGenders <- function(data,genders) {
           data[data$gender %in% genders,]
        }
        filterAgeRanges <- function(data,age_ranges) {
           data[data$age_range %in% age_ranges,]
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
        })


        #gender most/least
        output$genderRatings <- renderUI({
            data <- datasetInput()
            department_and_gender <- data %>%
                group_by(department,gender) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department_size=sum(n))

            ag <- department_and_gender %>% 
                filter(department_size > 3) %>% #significant sample
                group_by(department) %>%
                summarise(mean=mean(n),sd=sd(n), sum=sum(n))

            min <- ag %>% slice(which.min(sd))
            max <- ag %>% slice(which.max(sd))
            output$debugTable1 <-renderTable(department_and_gender)
            output$debugTable2 <-renderTable(max)

            most_item <-paste("<li>Most diverse area: ", min[1,]$department, "</li>")
            least_item <-paste("<li>Least diverse area: ", max[1,]$department, "</li>")
            HTML(paste("<ul style='margin: 20px;'>", most_item, least_item, "</ul>"))
        })

        #gender plots
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


            total_gender_breakdown <- rbind(department_and_gender,total_row)
            if(input$plotType == 'p') {
                ggplot(total_gender_breakdown,aes(x=factor(1),y=percent,fill=gender)) +
                  geom_bar(stat="identity",width=1) +
                  facet_wrap(~department) +
                  coord_polar(theta="y") +
                  scale_fill_brewer(palette="Pastel1", limits=c("Man", "Woman", "Prefer Not to Answer")) +
                  theme_minimal() +
                  theme(axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank()) +
                  labs(x="",y="",title="Gender Breakdown\n")
            }
            else {
                ggplot(department_and_gender, aes(x=reorder(department,department_size), y=n, fill=gender)) +
                    geom_bar(stat="identity") + 
                    scale_fill_brewer(palette="Pastel1", limits=c("Man", "Woman", "Prefer Not to Answer")) +
                    coord_flip() +
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
           if(length(is.na(time_and_gender$n)) > 0) {
               #time_and_gender[is.na(time_and_gender$n),]$n <- 0
           }

            ggplot(time_and_gender, aes(x=posixDate,y=n, fill=gender)) +
                geom_area(stat="Identity") +
                scale_fill_brewer(palette="Pastel1", limits=c("Man", "Woman", "Prefer Not to Answer")) +
                labs(x="Date",y="People", title="Gender of Applicants over time\n") +
                theme_minimal()

        })


        #ethnicity most/least
        output$ethnicityRatings <- renderUI({
            data <- datasetInput()
            department_and_ethnicity <- data %>%
                group_by(department,ethnicity) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department_size=sum(n))

            ag <- department_and_ethnicity %>% 
                group_by(department) %>%
                filter(department_size > 3) %>% #significant sample
                summarise(mean=mean(n),sd=sd(n), sum=sum(n))

            min <- ag %>% slice(which.min(sd))
            max <- ag %>% slice(which.max(sd))

            most_item <-paste("<li>Most diverse area: ", min[1,]$department, "</li>")
            least_item <-paste("<li>Least diverse area: ", max[1,]$department, "</li>")
            HTML(paste("<ul style='margin: 20px;'>", most_item, least_item, "</ul>"))
        })

        #ethnicity plots
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
                    scale_fill_brewer(palette="Pastel1",limits=c("Asian","Black/African","Caucasian","Hispanic/Latino","Indian","Mixed Race","Prefer Not to Answer","Self Described","West Asian/Middle Eastern")) +
                    theme_minimal() +
                    theme(axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank()) +
                    labs(x="",y="",title="Ethnicity Breakdown\n")
            } else {
                ggplot(department_and_ethnicity, aes(x=reorder(department,department_size), y=n, fill=ethnicity)) +
                    geom_bar(stat="identity") + 
                    coord_flip() +
                    labs(x="Area at Buffer",y="\nPeople", title="Ethnicity Breakdown Across Areas\n") +
                    scale_fill_brewer(palette="Pastel1",limits=c("Asian","Black/African","Caucasian","Hispanic/Latino","Indian","Mixed Race","Prefer Not to Answer","Self Described","West Asian/Middle Eastern")) + 
                    theme_minimal()
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

            ggplot(time_and_ethnicity, aes(x=posixDate,y=n, fill=ethnicity)) +
                geom_area(stat="Identity") +
                scale_fill_brewer(palette="Pastel1",limits=c("Asian","Black/African","Caucasian","Hispanic/Latino","Indian","Mixed Race","Prefer Not to Answer","Self Described","West Asian/Middle Eastern")) +
                labs(x="Date",y="People", title="Ethnicity of Applicants over time\n") +
                theme_minimal()

        })


        #age most/least
        output$ageRatings <- renderUI({
            data <- datasetInput()
            department_and_age <- data %>%
                group_by(department,age_range) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department_size=sum(n))

            ag <- department_and_age %>% 
                filter(department_size > 3) %>% #significant sample
                group_by(department) %>%
                summarise(mean=mean(n),sd=sd(n), sum=sum(n))

            min <- ag %>% slice(which.min(sd))
            max <- ag %>% slice(which.max(sd))

            most_item <-paste("<li>Most diverse area: ", min[1,]$department, "</li>")
            least_item <-paste("<li>Least diverse area: ", max[1,]$department, "</li>")
            HTML(paste("<ul style='margin: 20px;'>", most_item, least_item, "</ul>"))
        })

        #age plots
        output$agePlot <- renderPlot({
            data <- datasetInput()

            department_and_age <- data %>%
                group_by(department,age_range) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department_size=sum(n))


            by_age <- data %>%
                group_by(department,age_range) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n))

             total_age_row <- data %>%
                group_by(age_range) %>%
                summarise(n=n()) %>%
                mutate(percent=n/sum(n),department="Total")


            total_age_breakdown <- rbind(by_age,total_age_row)

            if(input$plotType == 'p') {
                ggplot(total_age_breakdown,aes(x=factor(1),y=percent,fill=age_range)) +
                    geom_bar(stat="identity",width=1) +
                    facet_wrap(~department) +
                    coord_polar(theta="y") + 
                    scale_fill_brewer(palette="Pastel1",limits=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above")) +
                    theme_minimal() +
                    theme(axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank()) +
                    labs(x="",y="",title="Age Breakdown\n")
            } else {
                ggplot(department_and_age, aes(x=reorder(department,department_size), y=n, fill=age_range)) +
                    geom_bar(stat="identity") + 
                    coord_flip() +
                    labs(x="Area at Buffer",y="\nPeople", title="Age Breakdown Across Areas\n") +
                    scale_fill_brewer(palette="Pastel1",limits=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above")) + 
                    theme_minimal()
            }
        })

        output$ageTimeSeries <- renderPlot({
            data <- datasetInput()
            data <- data[-1,]
            data$posixDateTime <- as.POSIXct(data$date,format="%m/%d/%Y")
            data$posixDate <- as.Date(data$posixDateTime)

            time_and_age <- data %>%
                group_by(posixDate,age_range) %>%
                summarise(n=n())

           #fill in empty time series data with zeros to make stacked area chart
           empty <- expand.grid(posixDate=unique(time_and_age$posixDate), age_range=unique(time_and_age$age_range))
           time_and_age <- merge(x=empty, y=time_and_age, all.x=T)
           time_and_age[is.na(time_and_age$n),]$n <- 0

            ggplot(time_and_age, aes(x=posixDate,y=n, fill=age_range)) +
                geom_area(stat="Identity") +
                scale_fill_brewer(palette="Pastel1",limits=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above")) +
                labs(x="Date",y="People", title="Age of Applicants over time\n") +
                theme_minimal()

        })


        #raw data
        output$teamTable <- renderTable(data$team_raw)
        output$applicantsTable <- renderTable(data$applicants_raw)
}
