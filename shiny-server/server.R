library(XML)
library(ggplot2)
library(downloader)
library(scales)
library(grid)
library(RColorBrewer)
library(rCharts)
library(ISOweek)

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
  
  departmentPlot <- function(by, levels=c()) {
    renderChart({
      data <- datasetInput()
      if(length(levels) == 0) {
        levels <- unique(data[[by]])
      }
      
      ## Order Levels of By Factor
      data[[by]] <- factor(data[[by]],levels=levels)
      
      department_and_by <- groupSumAndPercent(data, by=by)
      
      total_row <- data %>%
        regroup(list(by)) %>%
        summarise(n=n()) %>%
        mutate(percent=n/sum(n),department="Total", department_size=n)
      
      total_breakdown <- rbind(department_and_by,total_row)
      
      #fill in empty department data with zeros
      expand_args <- list(department=unique(department_and_by$department))
      expand_args[by] = unique(department_and_by[by])
      empty <- expand.grid(expand_args)
      department_and_field <- merge(x=empty, y=department_and_by, all.x=T)
      if(length(is.na(department_and_field$n)) > 0) {
        if(nrow(department_and_field[is.na(department_and_field$n),]) > 0) {
          department_and_field[is.na(department_and_field$n),]$n <- 0
        }
      }
      
      ## Order Levels of By Factor in department_and_field
      department_and_field[[by]] <- factor(department_and_field[[by]],levels=levels)
      
      if(input$plotType == 'p') {
        if(by=="gender") {
          n1 <- nPlot(~gender, data = data[order(data[[by]]),],type="pieChart",dom=paste(by,"Plot",sep=""))
        } else if(by=="ethnicity") {
          n1 <- nPlot(~ethnicity, data = data[order(data[[by]]),],type="pieChart",dom=paste(by,"Plot",sep=""))
        } else{
          n1 <- nPlot(~age_range, data = data[order(data[[by]]),],type="pieChart",dom=paste(by,"Plot",sep=""))
        }
        n1$params$width <- 700
        return(n1)
   
      } else {
        n2 <- nPlot(n~department,group=by,data=department_and_field[order(department_and_field[[by]]),],type="multiBarChart",dom=paste(by,"Plot",sep=""))
        n2$chart(stacked=T)
        n2$chart(reduceXTicks = FALSE)
        n2$yAxis(tickFormat = "#! function(y) { return (y).toFixed(0) } !#" )
        n2$params$width <- 700
        return(n2)
      }
    })
  }
  
  timeSeriesPlot <-function(by,levels=c()) {
    renderChart({
      rdata <- datasetInput()
      rdata <- rdata[-1,]
      rdata$posixDateTime <- as.POSIXct(rdata$date,format="%m/%d/%Y")
      rdata$posixDate <- as.Date(rdata$posixDateTime)
      rdata$week_num <- as.numeric(strftime(rdata$posixDateTime,format="%W")) 
      
      
      date_in_week <- function(year, week, weekday){
        w <- paste0(year, "-W", sprintf("%02d", week), "-", weekday)
        ISOweek2date(w)
      }
      
      rdata$week <- as.Date(date_in_week(year=as.numeric(format(rdata$posixDate,"%Y")),week=rdata$week_num + 1,weekday=1))
      
    
      
      if(length(levels) == 0) {
        levels <- unique(data[[by]])
      }
      
      ## Order Levels of By Factor
      rdata[[by]] <- factor(rdata[[by]],levels=levels)
      
      time_and_field <- rdata %>%
        regroup(list('week', by)) %>%
        summarise(n=n())
      
      
      #fill in empty time series data with zeros to make stacked area chart
      expand_args <- list(week=unique(time_and_field$week))
      expand_args[by] = unique(time_and_field[by])
      empty <- expand.grid(expand_args)
      time_and_field <- merge(x=empty, y=time_and_field, all.x=T)
      if(length(is.na(time_and_field$n)) > 0) {
        if(nrow(time_and_field[is.na(time_and_field$n),]) > 0) {
          time_and_field[is.na(time_and_field$n),]$n <- 0
        }
      }
      
      ## Order Levels of By Factor in time_and_field
      time_and_field[[by]] <- factor(time_and_field[[by]],levels=levels)
      
      
      n3 <- nPlot(n~week,group=by,data=time_and_field[order(time_and_field[[by]]),],type='stackedAreaChart',dom=paste(by,"TimeSeries",sep=""))
      n3$chart(useInteractiveGuideline=TRUE)
      n3$xAxis(
        tickFormat =   "#!
        function(d) {return d3.time.format('%b %d')(new Date(d*1000*3600*24));}
        !#"
      )
      n3$yAxis(tickFormat = "#! function(y) { return (y).toFixed(0) } !#" )
      n3$params$width <- 700
      return(n3)
      #ggplot(time_and_field, aes_string(x='posixDate', y='n', fill=by)) +
      #  geom_area(stat="Identity") +
      #  scale_fill_brewer(limits=limits) +
      #  labs(x="Date",y="People", title=paste(by, "of applicants over time\n")) +
      #  theme_minimal()
      
    })
  }
  
  #assemble UI elements
  #gender data 
  output$genderRatings <- renderUI(getRatings('gender'))
  output$genderPlot <- departmentPlot('gender',levels=c("Man", "Woman", "Self Described","Prefer Not to Answer"))
  output$genderTimeSeries <- timeSeriesPlot('gender',levels=c("Man", "Woman","Self Described", "Prefer Not to Answer"))
  
  #ethnicity data 
  output$ethnicityRatings <- renderUI(getRatings('ethnicity'))
  output$ethnicityPlot <- departmentPlot('ethnicity',levels=c('Asian',
                                                              'Black/African',
                                                              'Black/African descent',
                                                              'Latinx/Hispanic',
                                                              'Caucasian',
                                                              'White',
                                                              'Biracial',
                                                              'Multiracial',
                                                              'Chinese',
                                                              'Hispanic/Latino',
                                                              'Indigenous Australian',
                                                              'Native American',
                                                              'Pacific Inslander',
                                                              'Southeast Asian',
                                                              'West Asian/Middle Eastern',
                                                              'Mixed Race',
                                                              'Self Described',
                                                              'Prefer Not to Answer'))
  output$ethnicityTimeSeries <- timeSeriesPlot('ethnicity',levels=c('Asian',
                                                                    'Black/African',
                                                                    'Black/African descent',
                                                                    'Latinx/Hispanic',
                                                                    'Caucasian',
                                                                    'White',
                                                                    'Biracial',
                                                                    'Multiracial',
                                                                    'Chinese',
                                                                    'Hispanic/Latino',
                                                                    'Indigenous Australian',
                                                                    'Native American',
                                                                    'Pacific Inslander',
                                                                    'Southeast Asian',
                                                                    'West Asian/Middle Eastern',
                                                                    'Mixed Race',
                                                                    'Self Described',
                                                                    'Prefer Not to Answer'))
  
  
  
  #age data 
  output$ageRatings <- renderUI(getRatings('age_range'))
  output$age_rangePlot <- departmentPlot('age_range',levels=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above","Prefer Not to Answer"))
  output$age_rangeTimeSeries <- timeSeriesPlot('age_range',levels=c("Under 18","18-24","25-34","35-44","45-54","55-64","65 or Above","Prefer Not to Answer"))
  
  
  #raw data
  output$teamTable <- renderTable(data[['team_raw']])
  output$applicantsTable <- renderTable(data[['applicants_raw']])
}

