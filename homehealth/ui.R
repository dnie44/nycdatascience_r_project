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
                                           message = 'Last Updated: 10-25-2021',
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
      menuItem("HHA Coverage", tabName = "maps", icon = icon("globe-americas")),
      menuItem("Data", tabName = "data", icon = icon("layer-group"))
      ),
    
    selectizeInput(inputId='state',label='Select State',
                   choices=unique(pop$STNAME)),
    
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
        ")
      ))
    #------------HTML Tag Code------------
    ),
  
  # Body -------------------------------------------------------------------
  dashboardBody(
    ### change theme
    shinyDashboardThemes(
      theme = "grey_dark"
    ),
    tabItems(
      tabItem(tabName = 'motiv', 
              fluidRow()),
      tabItem(tabName = 'maps',
              h3("CMS Certified Home Health Agency Coverage"),
              # ROW 1
              fluidRow(
                column(6, offset = 0.2,
                       selectizeInput(inputId='maptype',
                                      label='Select Map Information',
                                      choices=c('Agency vs Seniors',
                                                'Agency vs Disabled',
                                                'Cases vs Seniors',
                                                'State Costs',
                                                'Pop. Density of Seniors')
                                        )
                ),
                column(6,h4(textOutput("selected_map")),
                )
              ),

              #ROW 2 & 3
              fluidRow(
                column(6, leafletOutput("map_1"))
              ),
              fluidRow(
                column(6, plotOutput("tb_ranks"))
              )
              ),
      tabItem(tabName = 'data', dataTableOutput('table'))
    )
  )
)