library(shinythemes)

shinyUI(
    navbarPage(title="Buffer Diversity Dashboard",theme = shinytheme("flatly"),
        tabPanel('Graphs',
            tags$link(rel = "stylesheet", type = "text/css", href = "button.css"),
            sidebarLayout(
                sidebarPanel(
                    tags$h3("We're building a more inclusive Buffer!"),
                    tags$div(style="margin-bottom: 20px", "Here's a transparent, real-time look at the overall demographic diversity of our team and our candidate pool.\n"),
                    tags$div(style="margin-bottom: 20px","Want to be part of the journey? ", tags$a(href="https://buffer.com/journey", "We're hiring!")),
                    selectInput("dataset", "Show diversity data for",choices = c("Applicants","The Buffer Team")),
                    radioButtons("plotType", "Plot type",c("Bar"="b", "Pie"="p")),
                    checkboxGroupInput("areaFilter", "Filter by area",
                        c('Development',
                        'Happiness',
                        'Data',
                        'Product',
                        'Content',
                        'Customer Research',
                        'Growth',
                        'Community'),
                        selected=c('Development',
                            'Happiness',
                            'Data',
                            'Product',
                            'Content',
                            'Customer Research',
                            'Growth',
                            'Community')
                    ),
                    checkboxGroupInput("ethnicityFilter", "Filter by ethnicity",
                        c('Asian',
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
                            'Self Described',
                            'Prefer Not to Answer'
                        ),
                        selected=c('Asian',
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
                            'Self Described',
                            'Prefer Not to Answer'
                        )
                    ),
                    tags$div(style="margin: 50px 0 20px", 
                             tags$h3("Buffer is the easiest way to save time on social media"),
                             tags$button(class="button large btn-primary hero-cta btn-rounded",
                                tags$a(href="https://bufferapp.com/?utm_source=traction&utm_medium=DiversityDashboard&utm_campaign=sidebar-sign-up",
                                       "Start Scheduling Posts on Social Media")
                             )
                    )
                ),
                mainPanel(
                    fluidRow(
                        column(width=10,
                            tags$div(class='panel panel-default',
                                tags$div(class='panel-heading','Gender Data'),
                                tags$div(class='panel-body',
                                    plotOutput("genderPlot"),
                                    conditionalPanel(condition="input.dataset =='Applicants'",
                                        plotOutput("genderTimeSeries")
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
                                    plotOutput("ethnicityPlot"),
                                    conditionalPanel(condition="input.dataset =='Applicants'",
                                        plotOutput("ethnicityTimeSeries")
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
                                    plotOutput("agePlot"),
                                    conditionalPanel(condition="input.dataset =='Applicants'",
                                        plotOutput("ageTimeSeries")
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
        #mainPanel(
        #tableOutput('debugTable1'),
        #tableOutput('debugTable2')
        #)
        #)
    )
)
