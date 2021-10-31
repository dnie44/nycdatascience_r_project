###### ui.R ######

dashboardPage(
  dashboardHeader(title = span("How Caring is ",
                          span("Home Healthcare?",
                              style = 
                              "font-weight: 600; 
                              color: SteelBlue; 
                              font-size: 26px")),
                  titleWidth = 390,
                  userOutput("author"),
                  dropdownMenu(type = 'message',
                               messageItem(from = 'Author',
                                           message = 'Last Updated: 10-30-2021',
                                           icon = icon("info-circle"),
                                           time = "22:00"))
                  ),
  # Sidebar -------------------------------------------------------------------
  dashboardSidebar(
    sidebarUserPanel(name = span("An R Project    ",
                                 style = "font-weight: 700; 
                                 color: White; 
                                 font-size: 16px"),
                     subtitle = span("by Daniel Nie    ",
                                     style = "color: White"),
                     image = 'https://dnie44.github.io/assets/img/wave.png'),
    
    sidebarMenu(
      menuItem("Motivation", tabName = "motiv", icon = icon("heartbeat")),
      menuItem("Coverage", tabName = "maps", icon = icon("globe-americas")),
      menuItem("Analysis", tabName = "charts", icon = icon("chart-area")),
      menuItem("Care Quality", tabName = "stats", icon = icon("file-medical-alt")),
      menuItem(''),
      menuItem('')
      ),
    
    box(width = NULL, title = 'Home Health Agency Search',
    selectizeInput(inputId='state', label='Select State',
                   choices=unique(pop$STNAME), selected = 'New York'),
    selectizeInput(inputId ='city', label = 'Select City',
                   choices = NULL)
    ),
    sidebarMenu(
      menuItem("Search Results", tabName = "data", icon = icon("map-marked-alt"))
      ),
    #------------HTML Tag Code------------
    # Fixes user-Panel color issue between shiny-dashboard and leaflet
    tags$head(
      HTML("<title>Home Health</title>"),
      tags$style(
        HTML("
        .skin-blue .main-sidebar .sidebar .user-panel {
        background-color: #004885; 
        }
        .skin-blue .main-sidebar .sidebar .user-panel .pull-left{
        background-color: #004885;
        }
        "),
      )
      )
    #------------HTML Tag Code------------
    ),
  
  # Body -------------------------------------------------------------------
  dashboardBody(
    ### change theme
    shinyDashboardThemes(
      theme = "grey_dark"
    ),
    tabItems(
      # TAB 1 - Motivation
      tabItem(tabName = 'motiv', 
              #ROW 1
              fluidRow(
                box(width = 7, solidHeader = TRUE, 
                    title = tags$h3('Home Healthcare Agencies'),
                    background = 'navy',
                    tags$p('Home Healthcare allows for the provision of skilled medical 
                           care to those with mobility issues or are homebound, in the 
                           comfort of their own homes. It is not only used for 
                           transitional care after hospitalization, but also plays a 
                           role in delivering preventive care to older people.',
                           style = 'font-size: 120%'),
                    tags$br(),
                    tags$p('Home healthcare spending has grown rapidy.',
                           tags$a(href="https://www.cms.gov/files/document/highlights.pdf", "CMS Expenditures"),
                           'on home health increased 7.7% in 2019, outpacing the total 
                           healthcare spending increase of 4.6% for the same period.',
                           'More importantly, home health has been shown to be ',
                           tags$a(href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC56889/", "effective"),
                           ' in reducing mortality and admission to institutional
                           long-term care for the elderly and frail.',
                           style = 'font-size: 120%'),
                    tags$br(),
                    tags$p('However, as evident in the CMS Quality ',
                           tags$a(
                             href="https://www.cms.gov/medicare/quality-initiatives-patient-assessment-instruments/homehealthqualityinits", 
                             "indicators"),
                           ', there are large discrepancies in the quality of care
                           provided by different agencies. There are also very 
                           dramatic geographic',
                           tags$a(
                             href="https://www.nejm.org/doi/full/10.1056/NEJM199608013350506", 
                             "variation"),
                             'in home healthcare utilization.',
                           style = 'font-size: 120%')
                ),
                tags$img(src='Pexels Home Health.png',width = 600, height = 350)
                ),
              #ROW 2 - Analysis Statement
              fluidRow(
                box(width = 12, solidHeader = TRUE, background = 'black',
                    title = p('Using home health agency data from the Centers 
                    for Medicare and Medicaid, the project explored factors 
                    associated with patient health outcomes through EDA and 
                    statistical analysis', 
                              style = 'color: #CCAC00; font-weight: 500;
                              font-size:130%'))
              ),
              fluidRow(),
              fluidRow()),
      # TAB 2 - Agency Density and Cost Maps
      tabItem(tabName = 'maps',
              # LEFT COL
              column(5,
                     #ROW 1
                     fluidRow(box(width = NULL, solidHeader = TRUE, 
                                  title = p('Home Health Agency Geographic Variation',
                                            style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                                  background = 'navy',
                                  tags$p('More than 25 years ago, there was dramatic 
                                     geographic variation in provision of Home Health.
                                     TN, MS, LA, AL, and GA had the highest concentrations 
                                     of home visits, while MN, HI, and SD had the lowest.',
                                         tags$a(
                                           href="https://www.nejm.org/doi/full/10.1056/NEJM199608013350506", 
                                           "(source)"),
                                         style = 'font-size: 120%'),
                                  img(src='1993 HHA map.png', width = 400, height = 280),
                                  tags$br(),
                                  tags$br(),
                                  tags$p('What does it look it today?',
                                         style = 'font-weight: 500; font-size: 140%')
                                  )
                              ),
                     fluidRow(box(width = NULL, solidHeader = TRUE, 
                                  title = p('Costs differences among Agencies',
                                            style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                                  background = 'navy',
                                  tags$p('Agency costs also differed drastically. In the CMS data,
                                     individual agency cost figures ranged from 0.5 to 2.0 
                                     (as a ratio vs. the national average)',
                                         style = 'font-size: 120%'),
                                  tags$br(),
                                  tags$p('Do costs influence patient clinical outcomes?',
                                         style = 'font-weight: 500; font-size: 140%')
                                  )
                              ),
                     ),
              # RIGHT COL
              column(6, 
                     #ROW 1
                     fluidRow(
                       column(12,
                              selectizeInput(inputId='maptype',
                                             label='Select Map Information',
                                             choices=c('Agency vs Seniors',
                                                       'Agency vs Disabled',
                                                       'Cases vs Seniors',
                                                       'State Costs',
                                                       'Private Agency Percentage',
                                                       'Pop. Density of Seniors')
                                             ))
                       ),
                     #ROW 2
                     fluidRow(
                       column(12,h4(textOutput("selected_map")))
                     ),
                     #ROW 3
                     fluidRow(
                       column(12, leafletOutput("map_1"))
                     ),
                     fluidRow(
                       column(12, plotOutput("tb_ranks"))
                     )
              )
      ),
      # TAB 3 - Basic EDA (Comparison of Star Rating and Ownership Type)
      tabItem(tabName = 'charts',
              fluidRow(
                column(6, offset = 0.5,
                       selectizeInput(inputId='startype',
                             label='Select Star Rating Comparison',
                             choices=c('Distribution',
                                       'Average Costs',
                                       'Acute Care Admissions',
                                       'Discharge to Community',
                                       'Potentially Preventable Readmissions',
                                       'Drug Consultation',
                                       'Improved Mobility',
                                       'Getting Out of Bed',
                                       'Better at Bathing',
                                       'Better Breathing',
                                       'Patient Experience - Professionalism',
                                       'Patient Experience - Communication')
              )),
                column(6, h4(textOutput("selected_star")) )
              ),
              fluidRow(
                column(6, offset = 0.5, 
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('Star Rating Comparisons',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           tags$p('Distribution',
                                  style = 'font-weight: 600; font-size: 120%'),
                           tags$p('The CMS uses a curved rating system, where 
                           only top performers in its 9 measurements of quality can 
                                  receive high ratings. Only 15% of agencies
                                  nationwide received 4.5 or 5 stars.'),
                           tags$p('Agency Cost',
                                  style = 'font-weight: 600; font-size: 120%'),
                           tags$p("Agency costs are lower for lower rated agencies,
                                  though the effect isn't large"),
                           tags$p('DTC Rate',
                                  style = 'font-weight: 600; font-size: 120%'),
                           tags$p("For agencies with a 3-star rating or better,
                                  the Discharge to Community rate is equal (~80%).
                                  However, outcomes start to become worse for poorly
                                  rated agencies."),
                           tags$p('Patient Experience Surveys',
                                  style = 'font-weight: 600; font-size: 120%'),
                           tags$p("We observe a steep drop in Patient Experience
                                  survey results for poorly rated agencies"),
                           tags$p('Overall, the rating system from the CMS is robust,
                                  and correlates well with patient experience and 
                                  outcome measures (measures not considered in 
                                  star-rating computation)',
                                  style = 'color: #CCAC00; font-size: 120%')
                           )
                       ),
                column(6, plotOutput("starbar")
              )),
              fluidRow(
                column(6, offset = 0.5, 
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('Analysis on Agency Ownership',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           tags$p('Distribution',
                                  style = 'font-weight: 600; font-size: 120%'))
                       )
                )
      ),
              
      tabItem(tabName = 'stats','statistics'),
      #------------------------------------------------------------------------
      tabItem(tabName = 'data', 
              h3("Home Health Agencies in Your City"),
              fluidRow(
                column(9, dataTableOutput('table')),
                column(3, box(width = 12, solidHeader = TRUE, 
                              title = '★ Star Ratings ★',
                              background = 'navy',
                              tags$p('The Star Rating is a summary measure of a home health agency’s 
performance based on how well it provides patient care.'),
                              tags$p('Visit the Centers for Medicare & Medicaid for more information'),
                              tags$a(
                                href="https://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HomeHealthQualityInits/Downloads/QoPC-Fact-Sheet-For-HHAs_UPDATES-7-24-16-2.pdf", 
                                "CMS.gov"))
                       )
              ),
              fluidRow(
                valueBoxOutput("DTbox1"),
                valueBoxOutput("DTbox2"),
                valueBoxOutput("DTbox3")
              )
              )
    )
  )
)