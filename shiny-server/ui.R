shinyUI(fluidPage(
    titlePanel("Buffer Diversity Dashboard"),
    title="Buffer Diversity Dashboard",
    fluidRow(
        column(width=10,
            plotOutput("ethnicityPlot"), height=400
        )
    ),
    fluidRow(
        column(width=10,
            plotOutput("genderPlot"), height=600
        )
    )
))
