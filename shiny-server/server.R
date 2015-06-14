library("XML")
library("ggplot2")
library("downloader")
library('scales')
library('grid')
library('RColorBrewer')
source('data.R')

function(input, output) {
        ## RETURN REQUESTED DATASET
        datasetInput <- reactive({
          switch(input$dataset,
               "The Buffer Team" = getFilteredData('team', input),
                "Applicants" =  getFilteredData('applicants',input)
          )
        })

        #generic UI functions
        getRatings <- function(by) {
            {
                data <- datasetInput()
                department_and_by <- groupSumAndPercent(data, by=by)
                ag <- reGroupMeanAndSd(department_and_by)

                min <- ag %>% slice(which.min(sd))
                max <- ag %>% slice(which.max(sd))

                most_item <-paste("<li>Most diverse area: ", min[1,]$department, "</li>")
                least_item <-paste("<li>Least diverse area: ", max[1,]$department, "</li>")
                HTML(paste("<ul style='margin: 20px;'>", most_item, least_item, "</ul>"))
            }
        }

        departmentPlot <- function(by, limits=c()) {
            renderPlot({
                data <- datasetInput()
                if(length(limits) == 0) {
                    limits <- unique(data[[by]])
                }
                department_and_by <- groupSumAndPercent(data, by=by)

                total_row <- data %>%
                    regroup(list(by)) %>%
                    summarise(n=n()) %>%
                    mutate(percent=n/sum(n),department="Total", department_size=n)


                total_breakdown <- rbind(department_and_by,total_row)
                if(input$plotType == 'p') {
                    ggplot(total_breakdown,aes_string(x=factor(1),y='percent',fill=by)) +
                      geom_bar(stat="identity",width=1) +
                      facet_wrap(~department) +
                      coord_polar(theta="y") +
                      scale_fill_brewer(limits=limits) +
                      theme_minimal() +
                      theme(axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank()) +
                      labs(x="",y="",title=paste(by, "breakdown\n"))
                } else {
                    ggplot(department_and_by, aes_string(x='reorder(department,department_size)', y='n', fill=by)) +
                        geom_bar(stat="identity") +
                        scale_fill_brewer(limits=limits) +
                        coord_flip() +
                        labs(x="\nArea at Buffer",y="People", title=paste(by, "breakdown across areas\n")) +
                        theme_minimal()
               }
            })
        }

        timeSeriesPlot <-function(by,limits=c()) {
            renderPlot({
                rdata <- datasetInput()
                rdata <- rdata[-1,]
                rdata$posixDateTime <- as.POSIXct(rdata$date,format="%m/%d/%Y")
                rdata$posixDate <- as.Date(rdata$posixDateTime)

                if(length(limits) == 0) {
                    limits <- unique(data[[by]])
                }

                time_and_field <- rdata %>%
                    regroup(list('posixDate', by)) %>%
                    summarise(n=n())

               #fill in empty time series data with zeros to make stacked area chart
               expand_args <- list(posixDate=unique(time_and_field$posixDate))
               expand_args[by] = unique(time_and_field[by])
               empty <- expand.grid(expand_args)
               time_and_field <- merge(x=empty, y=time_and_field, all.x=T)
               if(length(is.na(time_and_field$n)) > 0) {
                   if(nrow(time_and_field[is.na(time_and_field$n),]) > 0) {
                       time_and_field[is.na(time_and_field$n),]$n <- 0
                   }
               }

                ggplot(time_and_field, aes_string(x='posixDate', y='n', fill=by)) +
                    geom_area(stat="Identity") +
                    scale_fill_brewer(limits=limits) +
                    labs(x="Date",y="People", title=paste(by, "of applicants over time\n")) +
                    theme_minimal()

            })
        }

        #assemble UI elements
        #gender data 
        output$genderRatings <- renderUI(getRatings('gender'))
        output$genderPlot <- departmentPlot('gender',limits=c("Man", "Woman", "Prefer Not to Answer"))
        output$genderTimeSeries <- timeSeriesPlot('gender',limits=c("Man", "Woman", "Prefer Not to Answer"))

        #ethnicity data 
        output$ethnicityRatings <- renderUI(getRatings('ethnicity'))
        output$ethnicityPlot <- departmentPlot('ethnicity')
        output$ethnicityTimeSeries <- timeSeriesPlot('ethnicity')


        #age data 
        output$ageRatings <- renderUI(getRatings('age_range'))
        output$agePlot <- departmentPlot('age_range',limits=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above"))
        output$ageTimeSeries <- timeSeriesPlot('age_range',limits=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above"))


        #raw data
        output$teamTable <- renderTable(data[['team_raw']])
        output$applicantsTable <- renderTable(data[['applicants_raw']])
}
