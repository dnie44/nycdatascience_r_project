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
      menuItem("Conclusions", tabName = "end", icon = icon("flag-checkered")),
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
                                  tags$p('Home healthcare costs for each state have been shown to be
                                         highly affected by state regulations called Certificate of
                                         Need Laws (CON). These laws require providers to obtain
                                         permission before expanding services. Home healthcare typically
                                         cost more in states with CON laws.',
                                         tags$a(
                                           href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7166169/", 
                                           "(source)"),
                                         style = 'font-size: 120%'),
                                  img(src='CON laws.png', width = 500, height = 280),
                                  tags$br(),
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
              #ROW 1, bar chart selectors
              fluidRow(
                column(6, offset = 0.5,
                       selectizeInput(inputId='startype',
                             label='Select Star Rating Comparison',
                             choices=c('Distribution',
                                       'Average Costs',
                                       'Acute Care Admissions',
                                       'Discharge to Community',
                                       'Potentially Preventable Readmissions',
                                       'Patient Experience - Professionalism',
                                       'Patient Experience - Communication',
                                       'Patient Experience - Recommendation',
                                       'Percent Privately Owned')
              )),
                column(6, h4(textOutput("selected_star")) )
              ),
              #ROW 2, Star Rating EDA
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
                           tags$p("We observe a slight drop in Patient Experience
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
              #ROW 3, Ownership Type EDA
              fluidRow(
                column(6, offset = 0.5, 
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('Analysis on Agency Ownership',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           tags$p('Interestingly, Agencies with both high and low
                                  star ratings are mostly privately owned, while those
                                  with medium ratings are not.'),
                           tags$p('How does type of agency ownership affect costs 
                                  and patient outcomes?',
                                  style = 'font-weight: 600; font-size: 120%'),
                           tags$p('The variance of costs differed significantly
                                  between types of ownership. Private and Govt owned
                                  agency costs varied greatly, while Non-profit agency
                                  costs ranged closer to 1.0. The Kruskal-Wallis test
                                  showed means were significanly different, and Private
                                  agencies typically cost more.'),
                           tags$p('The discharge to community rate means also differed
                                  significantly. Non-profit agencies typically performed
                                  better.'),
                           tags$p('Acute care admissions rate means between agency types were
                                  significanly different. Private agencies performed better.')
                           )
                       ),
                column(6, 
                       tabBox(title = p('Ridgeline Charts',
                                        style = 'color: white; font-weight: 500'),
                              tabPanel("Cost",
                                       tags$p('Ownership vs Cost of Visit',
                                              style = 'color: white; font-weight: 500'),
                                       img(src = '1_Cost_ridges.png',
                                           width = 650, height = 400),
                                       tags$p('Std.Dev: ', tags$em('Private 0.135, 
                                              Non-Profit 0.101, 
                                              Government 0.117')),
                                       tags$p('Bartlett test: ', tags$em('p-value < 0.01')),
                                       tags$p('Kruskal-Wallis chi-squared: ', tags$em('p-value < 0.01')),
                                       icon = icon('donate')),
                              tabPanel("DTC",
                                       tags$p('Ownership vs Discharge to Community rates 
                                              (x^3 transformed data)',
                                              style = 'color: white; font-weight: 500'),
                                       img(src = '2_DTC_ridges.png',
                                           width = 650, height = 400),
                                       tags$p('Std.Dev: ', tags$em('Private 15.7, 
                                              Non-Profit 9.80, 
                                              Government 11.5')),
                                       tags$p('Bartlett test: ', tags$em('p-value < 0.01')),
                                       tags$p('Kruskal-Wallis chi-squared: ', tags$em('p-value < 0.01')),
                                       icon = icon('city')),
                              tabPanel("Admissions",
                                       tags$p('Ownership vs Acute Care Admissions',
                                              style = 'color: white; font-weight: 500'),
                                       img(src = '3_Adm_ridges.png',
                                           width = 650, height = 400),
                                       tags$p('Std.Dev: ', tags$em('Private 3.97, 
                                              Non-Profit 3.43, 
                                              Government 4.78')),
                                       tags$p('Bartlett test: ', tags$em('p-value < 0.01')),
                                       tags$p('Kruskal-Wallis chi-squared: ', tags$em('p-value < 0.01')),
                                       icon = icon('h-square')),
                              width = 12)
                       )
                )
      ),
      # TAB 4 - Linear Regression Attempts
      tabItem(tabName = 'stats',
              # Row 1, intro
              fluidRow(
                column(11, offset = 0.5,
                       tags$p('I would like to determine factors associated with
                              home health agency patient outcomes, specifically',
                              tags$em('acute care admissions rate',
                                     style = 'color: #CCAC00'),
                              'and',
                              tags$em('discharge to community rate',
                                     style = 'color: #CCAC00'),
                              'using linear regression.',
                              style = 'color: white; font-weight: 500; font-size:120%'),
                       tags$p('However, using nation-wide datapoints resulted in
                              extremely low R-squares. Perhaps the regulatory environment
                              and other factors are too different between states. Instead,
                              I ran regressions for data from individual states. I chose',
                              tags$em('Texas',
                                      style = 'color: #CCAC00'),
                              'as it had the most agencies (1400+), and ',
                              tags$em('Florida',
                                      style = 'color: #CCAC00'),
                              ', the state with the 3rd most agencies (~800), and known 
                              for its high senior population density.',
                              style = 'color: white; font-weight: 500; font-size:120%'),
                       tags$ol('*Stepwise feature selection (Forward BIC) was used to find
                              appropriate independent variables for each model.',
                              style = 'color: grey'),
                       tags$ol('**If star-rating was included as an independent variable,
                              other features that went into star-rating calculation were
                              excluded, and vice versa.',
                              style = 'color: grey')
                )),
              # LEFT Column
              column(5,
                     fluidRow(
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('Texas',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           tags$p('Model: ',tags$em('Admissions <~ Cost',
                                  style = 'font-weight: 600; font-size: 120%')),
                           tags$li('Intercept: ',tags$em('8.366 ***',
                                  style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B1 (Cost): ',tags$em('6.590 ***',
                                  style = 'font-weight: 500; font-size: 110%')),
                           tags$li('R-squared: ',tags$em('0.036',
                                  style = 'font-weight: 600; font-size: 110%')),
                           tags$br(),
                           tabBox(title = p('Regression & Residual Plots',
                                            style = 'color: white; font-weight: 500'),
                                  tabPanel("Regr",
                                           img(src = 'TX_reg1.png',
                                               width = 575, height = 400)),
                                  tabPanel("Fit",
                                           img(src = 'TX_plot1.png',
                                               width = 575, height = 400)),
                                  tabPanel("Q-Q",
                                           img(src = 'TX_plot2.png',
                                               width = 575, height = 400)),
                                  tabPanel("Scale",
                                           img(src = 'TX_plot3.png',
                                               width = 575, height = 400)),
                                  tabPanel("Lev",
                                           img(src = 'TX_plot4.png',
                                               width = 575, height = 400)),
                                  width = 12),
                           tags$br(),
                           tags$p('Model: ',tags$em('DTC rate <~ Breathe_better +Medication 
                           +Communication +Drug_edu +Bed_better +Drug_better +Flu_shots +Timely_meds',
                                                    style = 'font-weight: 600; font-size: 120%')),
                           tags$li('Intercept: ',tags$em('29.88 ***',
                                                         style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B1 (Breathe): ',tags$em('0.191 ***',
                                                         style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B2 (Medication): ',tags$em('-0.632 ***',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B3 (Communication): ',tags$em('0.427 ***',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B4 (Drug Education): ',tags$em('0.195 **',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B5 (In & Out of Bed): ',tags$em('0.262 ***',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B6 (Drug Better): ',tags$em('-0.185 ***',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B7 (Flu Shots): ',tags$em('0.089 ***',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B8 (Timely Meds): ',tags$em('0.104 ***',
                                                            style = 'font-weight: 500; font-size: 110%')),
                           tags$li('R-squared: ',tags$em('0.2912',
                                                         style = 'font-weight: 600; font-size: 110%')),
                           tags$br(),
                           tabBox(title = p('Residual Plots',
                                            style = 'color: white; font-weight: 500'),
                                  tabPanel("Fit",
                                           img(src = 'TX_plot5.png',
                                               width = 575, height = 400)),
                                  tabPanel("Q-Q",
                                           img(src = 'TX_plot6.png',
                                               width = 575, height = 400)),
                                  tabPanel("Scale",
                                           img(src = 'TX_plot7.png',
                                               width = 575, height = 400)),
                                  tabPanel("Lev",
                                           img(src = 'TX_plot8.png',
                                               width = 575, height = 400)),
                                  width = 12),
                           tags$li('VIFs: ',tags$em('none above 5.0',
                                                         style = 'font-size: 110%'))
                           ),
                       
                       )
                     ),
              # GAP Column
              column(1, ''),
              # RIGHT Column
              column(5, 
                     fluidRow(
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('Florida',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           tags$p('Model: ',tags$em('Admissions <~ Cost + Communication',
                                      style = 'font-weight: 600; font-size: 120%')),
                           tags$li('Intercept: ',tags$em('8.755 ***',
                                      style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B1 (Cost): ',tags$em('10.15 ***',
                                      style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B2 (Comm): ',tags$em('-0.055 **',
                                      style = 'font-weight: 500; font-size: 110%')),
                           tags$li('R-squared: ',tags$em('0.1224',
                                      style = 'font-weight: 500; font-size: 110%')),
                           tags$br(),
                           tabBox(title = p('Regression & Residual Plots',
                                            style = 'color: white; font-weight: 500'),
                                  tabPanel("Regr",
                                           img(src = 'FL_reg1.png',
                                               width = 575, height = 400)),
                                  tabPanel("Fit",
                                           img(src = 'FL_plot1.png',
                                               width = 575, height = 400)),
                                  tabPanel("Q-Q",
                                           img(src = 'FL_plot2.png',
                                               width = 575, height = 400)),
                                  tabPanel("Scale",
                                           img(src = 'FL_plot3.png',
                                               width = 575, height = 400)),
                                  tabPanel("Lev",
                                           img(src = 'FL_plot4.png',
                                               width = 575, height = 400)),
                                  width = 12),
                           tags$br(),
                           tags$p('Model: ',tags$em('DTC rate <~ Cost +Bed_better',
                                                    style = 'font-weight: 600; font-size: 120%')),
                           tags$li('Intercept: ',tags$em('96.46 ***',
                                                         style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B1 (Cost): ',tags$em('-28.84 ***',
                                                         style = 'font-weight: 500; font-size: 110%')),
                           tags$li('B2 (In & Out of Bed): ',tags$em('0.240 **',
                                                         style = 'font-weight: 500; font-size: 110%')),
                           tags$li('R-squared: ',tags$em('0.2506',
                                                         style = 'font-weight: 500; font-size: 110%')),
                           tags$br(),
                           tabBox(title = p('Regression & Residual Plots',
                                            style = 'color: white; font-weight: 500'),
                                  tabPanel("Regr",
                                           img(src = 'FL_reg2.png',
                                               width = 575, height = 400)),
                                  tabPanel("Fit",
                                           img(src = 'FL_plot5.png',
                                               width = 575, height = 400)),
                                  tabPanel("Q-Q",
                                           img(src = 'FL_plot6.png',
                                               width = 575, height = 400)),
                                  tabPanel("Scale",
                                           img(src = 'FL_plot7.png',
                                               width = 575, height = 400)),
                                  tabPanel("Lev",
                                           img(src = 'FL_plot8.png',
                                               width = 575, height = 400)),
                                  width = 12),
                           tags$li('VIFs: ',tags$em('none above 5.0',
                                                    style = 'font-size: 110%'))
                           )
                       
                       )
                     )
              ),
      # TAB 5 - Conclusions
      tabItem(tabName = 'end',
              # Row 1 Conclusions
              fluidRow(
                column(5, 
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('For the Centers for Medicare & Medicaid Services',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           img(src='unsplash_doc.jpg', width = 610, height = 'auto'),
                           tags$br(),
                           tags$br(),
                           tags$li('Although costs vary widely state-to-state, 
                                   within-state analysis showed more expensive
                                   agencies correlated with higher acute care 
                                   admissions and lower DTC rates. This means
                                   at-risk patients with complicated illnesses
                                   pay more, and may be using home health as an
                                   alternative to institutional long-term care
                                   (This is desired).', 
                                   style = 'font-size: 120%'),
                           tags$li('Patient experience survey results on caregiver
                                   communication correlated with lower acute care
                                   admissions. Home healthcare teams should emphasize
                                   better communication with patients and households.', 
                                   style = 'font-size: 120%'),
                           tags$li("Heathcare teams should focus on improving 
                           patients' ability to get in and out of bed as this 
                           factor was correlated with better discharge to 
                           community rates", 
                                   style = 'font-size: 120%')
                           )
                       ),
                column(5, 
                       box(width = NULL, solidHeader = TRUE, 
                           title = p('For Home Health Agency Patients and Family',
                                     style = 'color: #CCAC00; font-weight: 500;
                                        font-size:120%'),
                           background = 'navy',
                           img(src='unsplash_old.jpg', width = 610, height = 'auto'),
                           tags$br(),
                           tags$br(),
                           tags$li('Agency Star Ratings are given by the CMS and 
                           not by patients. It correlates well with quality of care. 
                           Patients should always find an agency with at least a 
                           Star Rating of 3 or higher.',
                                   style = 'font-size: 120%'),
                           tags$li('Patients and family members should make sure
                                   agency caregivers spend time to communicate with
                                   you regarding your illness, pain, and medication.
                                   If you feel disatisfied, ask your agency or doctor
                                   if you can replace your home health team.',
                                   style = 'font-size: 120%')
                           )
                       )
                ),
              # Row 2 Limitations & Further Analysis
              fluidRow(
                column(10, 
                       h3('Limitations & Further Analysis'),
                       p('Regression analysis did not yield strong results,
                         this could be due to missing detailed agency data, such
                         as: (1) the exact number of home health staff or teams,
                         (2) team composition, e.g. skilled nurses, home aides, etc.
                         (3) agency patient case-mix.',
                         style = 'font-size: 120%'),
                       p('As next steps to the study, if agency patient case-mix
                         information was available, studying agency features against
                         patient outcomes for ', tags$em('specific diseases'), 
                         ' could yield valuable results.',
                         style = 'font-size: 120%')
                       )
                )
              ),
      
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
                valueBoxOutput("DTbox2")
              )
              )
    )
  )
)