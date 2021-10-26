###### ui.R ######

library(shiny)
library(shinydashboard)
library(dashboardthemes)

dashboardPage(
  dashboardHeader(title = span("How Caring is ",
                          span("Home Healthcare?",
                              style = 
                              "font-weight: 600; 
                              color: SteelBlue; 
                              font-size: 26px")),
                  titleWidth = 390,
                  tags$li(actionLink("aboutlink",
                                     label = " About", 
                                     icon = icon("info")),
                          class = "dropdown")
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
      menuItem("Plots", tabName = "plots", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))
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
      tabItem(tabName = 'plots',
              fluidRow(
                column(6, leafletOutput("map_1")),
                column(6, plotOutput("delay"))
              )),
      tabItem(tabName = 'data', dataTableOutput('table'))
    )
  ),
)