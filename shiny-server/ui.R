shinyUI(fluidPage(
    titlePanel("Buffer Diversity Dashboard"),
    title="Buffer Diversity Dashboard",


    fluidRow(
        column(width=10,
            selectInput("dataset", "Choose a dataset:",
                                      choices = c("Buffer Team", "Applicants"))
        )
    ),
    fluidRow(
        column(width=10,
            plotOutput("ethnicityPlot")
        )
    ),
    fluidRow(
        column(width=10
            #plotOutput("genderPlot"), height=600
        )
    ),
    fluidRow(
        column(width=10,
            titlePanel("Raw Data"),
            tableOutput('table')
        )
     )
))
