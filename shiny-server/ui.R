library(shinythemes)

shinyUI(
    navbarPage("Buffer Diversity Dashboard",theme = shinytheme("flatly"),
        tabPanel('Graphs',
            sidebarLayout(
                sidebarPanel(
                    selectInput("dataset", "Show diversity data for",choices = c("The Buffer Team", "Applicants"))
                ),
                mainPanel(
                    fluidRow(
                        column(width=10,
                            plotOutput("genderPlot")
                        )
                    ),


                    fluidRow(
                        column(width=10,
                            plotOutput("ethnicityPlot"), height=600
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
    )
)
