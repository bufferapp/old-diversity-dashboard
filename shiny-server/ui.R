library(shinythemes)

shinyUI(
    navbarPage(title="Buffer Diversity Dashboard",theme = shinytheme("flatly"),
        tabPanel('Graphs',
            tags$link(rel = "stylesheet", type = "text/css", href = "button.css"),
            sidebarLayout(
                sidebarPanel(
                    tags$div(style="margin-bottom: 40px", "All data collected from a voluntary, anonymous survey completed by applicants and the Buffer team\n"),
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
                    tags$div(style="margin: 50px 0 40px", 
                             tags$h3("Buffer is the easiest way to save time on social media"),
                             tags$button(class="button large btn-primary hero-cta btn-rounded",
                                tags$a(href="https://bufferapp.com/?utm_source=traction&utm_medium=DiversityDashboard&utm_campaign=sidebar-sign-up",
                                       "Start Scheduling Posts on Social Media")
                             )
                    ),
                    tags$div("Want to be part of the journey? ", tags$a(href="https://buffer.com/journey", "We're hiring!"))
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
        ,tabPanel('Debug',
        mainPanel(
        tableOutput('debugTable1'),
        tableOutput('debugTable2')
        )
        )
    )
)
