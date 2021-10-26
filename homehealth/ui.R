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
                                 color: SteelBlue; 
                                 font-size: 16px"),
                     subtitle = span("by Daniel Nie    ",
                                     style = "color: SteelBlue"),
                     image = 'https://dnie44.github.io/assets/img/wave.png'),
    
    sidebarMenu(
      menuItem("Motivation", tabName = "motiv", icon = icon("heartbeat")),
      menuItem("HHA Coverage", tabName = "maps", icon = icon("globe-americas")),
      menuItem("Data", tabName = "data", icon = icon("layer-group"))
      ),
    
    selectizeInput(inputId='state',label='Select State',
                   choices=unique(pop$STNAME)),
    
    ###HTML Tag Code###
    # Fixes user-Panel color issue between shiny-dashboard and leaflet
    tags$head(
      tags$style(
        HTML("
        .skin-blue .main-sidebar .sidebar .user-panel {
        background-color: #202022; 
        }
        .skin-blue .main-sidebar .sidebar .user-panel .pull-left{
        background-color: #202022;
        }
        ")
      ))
    
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
              fluidRow(
                column(6, plotOutput("delay"))
                ),
              fluidRow(
                column(6, leafletOutput("map_1"))
                )              
              ),
      tabItem(tabName = 'data', dataTableOutput('table'))
    )
  )
)