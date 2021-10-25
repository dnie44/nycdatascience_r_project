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
  observeEvent(input$aboutlink, {
    showModal(modalDialog(
      title = "Daniel Nie", 
      tags$div('',
               tags$a(href = 'https://dnie44.github.io/', "Author Website")
               )
      ))
  })

}