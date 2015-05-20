shinyUI(fluidPage(
    titlePanel("Buffer Diversity Dashboard"),
    title="Buffer Diversity Dashboard",
    fluidRow(
        column(width=10,
            plotOutput("ethnicityPlot"), height=400
        )
    ),
    fluidRow(
        plotOutput("genderPlot"), height=600
    )
))
