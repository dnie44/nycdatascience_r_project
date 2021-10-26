function(input, output) {
  chosen <- reactive({
    pop %>%
      filter(
        STNAME == input$state
      )
  })
  
  output$map_1 <- renderLeaflet(mapshow(usmap$per_SEN,pal_1))
  
  output$delay <- renderPlot(
    chosen() %>%
      ggplot(
        aes(x = STNAME, y = POP)
      ) +
      geom_col() +
      ggtitle("TEST")
  )
  
  
  #-Data Table------------------------------------------------------------------
  output$table <- renderDataTable(
    pop # %>% filter(
      #origin == input$origin,
      #dest == input$dest
      #month == input$month
    #)
  )
  
  #-Other Modals----------------------------------------------------------------
  output$author <- renderUser({
    dashboardUser(
      name = "Daniel Nie", 
      image = "https://nycdsa-blog-files.s3.us-east-2.amazonaws.com/2021/10/daniel-nie/img-7927.jpg-000761-eN23fWDz-150x150.jpg", 
      title = "R Project",
      subtitle = "NYC Data Science Academy", 
      footer = p("Cohort: BDS027 - 2021", class = "text-center"),
      fluidRow(
        dashboardUserItem(
          width = 4,
          socialButton(
            href = "https://www.linkedin.com/in/danielnie/",
            icon = icon("linkedin")
          )
        ),
        dashboardUserItem(
          width = 4,
          socialButton(
            href = "https://github.com/dnie44/nycdatascience_r_project",
            icon = icon("github")
          )
        ),
        dashboardUserItem(
          width = 4,
          socialButton(
            href = "https://dnie44.github.io/",
            icon = icon("user-secret")
          )
        )
      )
    )
  })
  
}