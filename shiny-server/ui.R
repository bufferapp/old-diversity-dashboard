library(shinythemes)
library(downloader)
library('rCharts')




shinyUI(
  navbarPage(title="ustwo Diversity Dashboard",theme = shinytheme("flatly"),
             tabPanel('Graphs',
                      tags$head(
                        tags$script("
                                    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                                    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                                    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                                    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
                                    ga('create', 'UA-7940378-1', 'auto');
                                    "),
                            tags$meta(property="og:title", content="ustwo Diversity Dashboard"),
                            tags$meta(property="og:url", content="http://diversity.ustwo.com"),
                            tags$meta(property="og:description", content="With this Dashboard we share our team data in the specific areas of age, gender, and ethnicity.")
                      ),
                      tags$link(rel = "stylesheet", type = "text/css", href = "button.css"),
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("dataset", "Show diversity data for",choices = c("The ustwo Team","Applicants")),
                          radioButtons("plotType", "Plot type",c("Bar"="b", "Pie"="p")),
                          checkboxGroupInput("genderFilter", "Filter by gender",
                                             c('Man', 'Woman', 'Self Described', 'Prefer Not to Answer'),
                                             selected=c('Man', 'Woman', 'Self Described', 'Prefer Not to Answer')
                          ),
                          checkboxGroupInput("areaFilter", "Filter by area",
                                             c('Development',
                                               'Happiness',
                                               'Data',
                                               'People',
                                               'Product',
                                               'Marketing',
                                               'Leadership',
                                               'Research',
                                               'Growth',
                                               'Community'),
                                             selected=c('Development',
                                                        'Happiness',
                                                        'Data',
                                                        'People',
                                                        'Product',
                                                        'Marketing',
                                                        'Leadership',
                                                        'Research',
                                                        'Growth',
                                                        'Community')
                          ),
                          checkboxGroupInput("ethnicityFilter", "Filter by race",
                                             c('Asian',
                                               'Black/African descent',
                                               'Latinx/Hispanic',
                                               'White',
                                               'Biracial',
                                               'Multiracial',
                                               'Indigenous Australian',
                                               'Native American',
                                               'Pacific Islander',
                                               'Self Described',
                                               'Prefer Not to Answer'
                                             ),
                                             selected=c('Asian',
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
                                                        'Pacific Islander',
                                                        'Southeast Asian',
                                                        'West Asian/Middle Eastern',
                                                        'Mixed Race',
                                                        'Self Described',
                                                        'Prefer Not to Answer'
                                             )),
                          checkboxGroupInput("ageFilter", "Filter by age range",
                                             c('Under 18',
                                               '18-24',
                                               '25-34',
                                               '35-44',
                                               '45-54',
                                               '55-64',
                                               '65 or Above',
                                               'Prefer Not to Answer'
                                             ),
                                             selected=c('Under 18',
                                                        '18-24',
                                                        '25-34',
                                                        '35-44',
                                                        '45-54',
                                                        '55-64',
                                                        '65 or Above',
                                                        'Prefer Not to Answer'
                                             )
                          )
                        ),
                        mainPanel(
                          fluidRow(
                            column(width=10,
                                   tags$div(class='panel panel-default',
                                            tags$div(class='panel-heading','Gender Data'),
                                            htmlOutput('genderRatings'),
                                            tags$div(class='panel-body',
                                                     showOutput("genderPlot","nvd3"),
                                                     conditionalPanel(condition="input.dataset =='Applicants'",
                                                                      showOutput("genderTimeSeries","nvd3")
                                                     )
                                            )
                                   )
                            )
                          ),

                          #ethnicity
                          fluidRow(
                            column(width=10,
                                   tags$div(class='panel panel-default',
                                            tags$div(class='panel-heading','Ethnicity Data'),
                                            tags$div(class='panel-body',
                                                     htmlOutput('ethnicityRatings'),
                                                     showOutput("ethnicityPlot","nvd3"),
                                                     conditionalPanel(condition="input.dataset =='Applicants'",
                                                                       showOutput("ethnicityTimeSeries","nvd3")
                                                     )
                                            )
                                   )
                            )
                          ),
                          #age
                          fluidRow(
                            column(width=10,
                                   tags$div(class='panel panel-default',
                                            tags$div(class='panel-heading','Age Data'),
                                            tags$div(class='panel-body',
                                                     htmlOutput('ageRatings'),
                                                     showOutput("age_rangePlot","nvd3"),
                                                     conditionalPanel(condition="input.dataset =='Applicants'",
                                                                       showOutput("age_rangeTimeSeries","nvd3")
                                                     )
                                            )
                                   )
                            )
                          )

                        )
                      )
                      ),
             tabPanel('Raw Data',
                      mainPanel(
                        titlePanel("Team Data"),
                        tableOutput('teamTable'),
                        titlePanel("Applicants Data"),
                        tableOutput('applicantsTable')
                      )
             )
             #,tabPanel('Debug',
             #          mainPanel(
             #            tableOutput('debugTable1'),
             #            tableOutput('debugTable2')
             #          )
             #)
             )
)
