function(input, output, session) {
  #-------------------------------------------------------------------------
  # SQL querying
  # connect to server
  conn = dbConn(session, 'hh_data.sqlite')
  
  user_db <- reactive(dbGetData(conn,
                                tblname = 'hh_all',
                                st_name(input$state)))
  
  observeEvent(input$state, {
    choices = stringr::str_to_title(unique(user_db()[, City]))
    updateSelectizeInput(session, inputId = "city", choices = choices)
  })
  
  #-------------------------------------------------------------------------
  # Reactive CHOSEN STATE
  chosen_st <- reactive({
    pop %>%
      filter(
        STNAME == input$state
      )
  })
  # Reactive CHOSEN MAP
  chosen_map <- reactive({
    switch(
      input$maptype,
      'Agency vs Seniors' = 7,
      'Agency vs Disabled'= 8,
      'Cases vs Seniors' = 9,
      'State Costs' = 10,
      'Private Agency Percentage' = 11,
      'Pop. Density of Seniors' = 12)
  })
  
  #-------------------------------------------------------------------------
  # Outputs
  # SELECTION TEXT
  output$selected_map <- renderText({ 
    switch(chosen_map()-6,
           'Number of Agencies per 100,000 Seniors',
           'Number of Agencies per 100,000 Disabled',
           'Number of Cases handled per 100,000 Seniors',
           'Average Agency Costs (as a ratio vs. National average)',
           'Percentage of Agencies that are Private',
           'Population Density of Seniors (Seniors per Square Mile)'
           )
  })
  
  # US MAPS
  output$map_1 <- renderLeaflet(mapshow(usmap[[chosen_map()]],pal_1))
  
  # STATE RANKINGS
  top_bott <- function(n) {
    # function takes in target column parameter (n == column index)
    # and returns the top and bottom 5 ranked states
    usmap %>%
      filter(dense_rank(.[[n]]) <= 5 | dense_rank(desc(.[[n]])) <= 5) %>% 
      arrange(.[[n]]) %>% 
      transmute(NAME=factor(NAME, levels=NAME),VAL=.[[n]])
  }
  
  output$tb_ranks <- renderPlot(
    # converts spatial DF to regular DF then plots
    as.data.frame(top_bott(chosen_map())) %>% ggplot(aes(VAL, NAME)) + 
      geom_segment(aes(xend=0 ,yend = NAME), size = 1.2) +
      geom_point( size=5, color="#004885") +
      ylab("") + xlab("") + 
      geom_hline(aes(yintercept=5.5),color ='#004885',linetype=2)
  )
  
  output$delay <- renderPlot(
    chosen_st() %>%
      ggplot(
        aes(x = STNAME, y = POP)
      ) +
      geom_col() +
      ggtitle("TEST")
  )
  
  #-Data Table------------------------------------------------------------------
  output$table <- renderDataTable(
    user_db() %>% 
      filter(City == stringr::str_to_upper(input$city)) %>%
      # Better formatted
      mutate(Name = stringr::str_to_title(Name),
             Address = stringr::str_to_title(Address),
             City = stringr::str_to_title(City),
             Phone = paste(str_sub(Phone,1,3),
                           str_sub(Phone,4,6),
                           str_sub(Phone,7,10),sep='-'),
             Star_rating = recode(as.character(Star_rating),
                                  '1'   = paste0('★ ','(',Star_rating,')'),
                                  '1.5' = paste0('★☆ ','(',Star_rating,')'),
                                  '2'   = paste0('★★ ','(',Star_rating,')'),
                                  '2.5' = paste0('★★☆ ','(',Star_rating,')'),
                                  '3'   = paste0('★★★ ','(',Star_rating,')'),
                                  '3.5' = paste0('★★★☆ ','(',Star_rating,')'),
                                  '4'   = paste0('★★★★ ','(',Star_rating,')'),
                                  '4.5' = paste0('★★★★☆ ','(',Star_rating,')'),
                                  '5'   = paste0('★★★★★ ','(',Star_rating,')')
             )),
    options = list(pageLength = 10)
  )
  
  #-Data Table companion text boxes---------------------------------------------
  output$DTstar <- renderInfoBox({
    valueBox(
      value = '★★',
      subtitle = "NOTE:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
      icon = icon("star-half-alt"), color = 'maroon', width = 12
    )
  })
  
  output$DTbox1 <- renderValueBox({
    valueBox(
      value = 'XXXX',
      subtitle = "Total downloads",
      icon = icon("landmark"), color = 'olive', width = NULL
    )
  })
  
  output$DTbox2 <- renderValueBox({
    valueBox(
      value = 'XXXX',
      subtitle = "Total downloads",
      icon = icon("landmark"), color = 'olive', width = NULL
    )
  })
  
  output$DTbox3 <- renderValueBox({
    valueBox(
      value = 'XXXX',
      subtitle = "Total downloads",
      icon = icon("landmark"), color = 'olive', width = NULL
    )
  })
  
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