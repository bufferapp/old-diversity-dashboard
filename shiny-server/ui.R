library(shinythemes)
library(downloader)
library('rCharts')




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
                                    "),
                            tags$meta(property="og:title", content="Buffer Open Source Diversity Dashboard"),
                            tags$meta(property="og:url", content="http://diversity.buffer.com"),
                            tags$meta(property="og:description", content="What gets measured, gets managed. With this dashboard, we’re sharing real-time data on the demographic diversity of the Buffer team, as well as those who’ve expressed interest in joining our team, in the specific areas of age, gender, and ethnicity."),
                            tags$meta(property="og:image", content="https://open.bufferapp.com/wp-content/uploads/2015/06/pablo-23.png")
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
                                             c('Man', 'Woman', 'Self Described', 'Prefer Not to Answer'),
                                             selected=c('Man', 'Woman', 'Self Described', 'Prefer Not to Answer')
                          ),
                          checkboxGroupInput("areaFilter", "Filter by area",
                                             c('Development',
                                               'CEO',
                                               'Happiness',
                                               'Data',
                                               'People',
                                               'Product',
                                               'Marketing',
                                               'Research',
                                               'Growth',
                                               'Community'),
                                             selected=c('Development',
                                                        'CEO',
                                                        'Happiness',
                                                        'Data',
                                                        'People',
                                                        'Product',
                                                        'Marketing',
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
                                   tags$button(class="buffer-button-cta large buffer-btn-primary hero-cta buffer-btn-rounded",
                                               tags$a(href="https://bufferapp.com/?utm_source=traction&utm_medium=DiversityDashboard&utm_campaign=sidebar-sign-up",
                                                      "Start Scheduling Posts on Social Media")
                                   )
                          ),
                          tags$div(id="fb-root"),
                          tags$script("(function(d, s, id) {
                              var js, fjs = d.getElementsByTagName(s)[0];
                                if (d.getElementById(id)) return;
                                js = d.createElement(s); js.id = id;
                                  js.src = '//connect.facebook.net/en_US/all.js#xfbml=1&appId=103667826405103';
                                  fjs.parentNode.insertBefore(js, fjs);
                              }(document, 'script', 'facebook-jssdk'))"),
                          tags$script(src="https://apis.google.com/js/plusone.js"),
                          tags$div(HTML('<div class="share">
                                           <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?"http":"https";if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document, "script", "twitter-wjs");</script>
                                          <div class="grid-row">
                                              <div class="">
                                                  <div class="social-sharing-buttons-centered">
                                                      <div class="fb-like" data-send="false" data-layout="button_count" data-width="90" data-show-faces="false" style="width:83px; overflow:hidden;position:relative; top:auto;  bottom:0px; left:3px;"></div>
                                                      <a href="https://twitter.com/share" class="twitter-share-button" data-via="buffer" data-text="We\'re building a more inclusive Buffer! Take a look at our diversity dashboard">Tweet</a>
                                                      <g:plusone size="medium"></g:plusone>
                                                      <a href="http://bufferapp.com/add" class="buffer-add-button" data-text="We&#39;re building a more inclusive Buffer! Take a look at our diversity dashboard" data-url="http:&#x2F;&#x2F;diversity.buffer.com" data-count="horizontal" data-via="buffer" ></a><script type="text/javascript" src="https://d389zggrogs7qo.cloudfront.net/js/button.js"></script>
                                                  </div>
                                              </div>
                                          </div>
                                         </div>'))
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
