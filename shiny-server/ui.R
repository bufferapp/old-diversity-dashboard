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
                            tags$div(class='panel panel-default',
                                tags$div(class='panel-heading','Gender Data'),
                                tags$div(class='panel-body',
                                    plotOutput("genderPlot")
                                )
                            )
                        )
                    ),

                    fluidRow(
                        column(width=10,
                            tags$div(class='panel panel-default',
                                tags$div(class='panel-heading','Ethnicity Data'),
                                tags$div(class='panel-body',
                                    plotOutput("ethnicityPlot")
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
    )
)
