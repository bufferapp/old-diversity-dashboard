library(shinythemes)

shinyUI(
    navbarPage(title="Buffer Diversity Dashboard",theme = shinytheme("flatly"),
        tabPanel('Graphs',
            tags$head(
                tags$script("
                    (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                    })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
                    ga('create', 'UA-18896347-6', 'auto');
                    ga('send', 'pageview');
                ")
            ),
            tags$link(rel = "stylesheet", type = "text/css", href = "button.css"),
            sidebarLayout(
                sidebarPanel(
                    tags$h3("We're building a more inclusive Buffer!"),
                    tags$div(style="margin-bottom: 20px", "Here's a transparent, real-time look at the overall demographic diversity of our team and our candidate pool.\n"),
                    tags$div(style="margin-bottom: 20px","Want to be part of the journey? ", tags$a(href="https://buffer.com/journey", "We're hiring!")),
                    selectInput("dataset", "Show diversity data for",choices = c("Applicants","The Buffer Team")),
                    radioButtons("plotType", "Plot type",c("Bar"="b", "Pie"="p")),
                    checkboxGroupInput("genderFilter", "Filter by gender",
                        c('Man', 'Woman', 'Prefer Not to Answer'),
                        selected=c('Man', 'Woman', 'Prefer Not to Answer')
                    ),
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
                        )),
                        checkboxGroupInput("ageFilter", "Filter by age range",
                            c('Under 18',
                                '18-24',
                                '25-34',
                                '35-44',
                                '45-54',
                                '55-64',
                                '65 or Above'
                            ),
                            selected=c('Under 18',
                                '18-24',
                                '25-34',
                                '35-44',
                                '45-54',
                                '55-64',
                                '65 or Above'
                            )
                        ),
                    tags$div(style="margin: auto",
                             tags$h3(style="text-align:center;margin-top: 40px;","Buffer is the easiest way to save time on social media"),
                             tags$button(class="buffer-button large buffer-btn-primary hero-cta buffer-btn-rounded",
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
                                htmlOutput('genderRatings'),
                                tags$div(class='panel-body',
                                    graphOutput("genderPlot"),
                                    conditionalPanel(condition="input.dataset =='Applicants'",
                                        graphOutput("genderTimeSeries")
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
                                    graphOutput("ethnicityPlot"),
                                    conditionalPanel(condition="input.dataset =='Applicants'",
                                        graphOutput("ethnicityTimeSeries")
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
                                    graphOutput("age_rangePlot"),
                                    conditionalPanel(condition="input.dataset =='Applicants'",
                                        graphOutput("age_rangeTimeSeries")
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
