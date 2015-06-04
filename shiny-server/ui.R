library(shinythemes)

shinyUI(
    navbarPage("Buffer Diversity Dashboard",theme = shinytheme("flatly"),
        tabPanel('Graphs',
            sidebarLayout(
                sidebarPanel(
                    tags$div(style="margin-bottom: 40px", "All data collected from a voluntary, anonymous survey completed by applicants and the Buffer team\n"),
                    selectInput("dataset", "Show diversity data for",choices = c("The Buffer Team", "Applicants")),
                    radioButtons("plotType", "Plot type",c("Bar"="b", "Pie"="p"))
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
        #,tabPanel('Debug',
        #        mainPanel(
        #            tableOutput('debugTable1'),
        #            tableOutput('debugTable2')
        #        )
        #)
    )
)
