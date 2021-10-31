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
  # Reactive CHOSEN STAR RATING COMPARISON
  chosen_star <- reactive({
    switch(
      input$startype,
      'Distribution' = 3,
      'Average Costs'= 4,
      'Acute Care Admissions' = 5,
      'Discharge to Community' = 6,
      'Potentially Preventable Readmissions' = 7,
      'Patient Experience - Professionalism' = 8,
      'Patient Experience - Communication' = 9,
      'Patient Experience - Recommendation' = 10,
      'Percent Privately Owned' = 11)
  })

  #-------------------------------------------------------------------------
  # Outputs
  # SELECTION TEXT for MAP
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
  
  # STAR RATING COMPARISON BARCHARTS
  output$starbar <- renderPlot(
    star_data %>% mutate(c = ifelse(Star_rating=='Unrated','yes','no')) %>% 
      ggplot(aes(x = .[[chosen_star()]], y = Star_rating)) +
      geom_col(aes(fill = c), color = 'black', show.legend = FALSE) +
      scale_fill_manual(values = c('yes' = '#3D3877', 'no' = '#CCAC00')) +
      ylab('Star Rating') + xlab('')
  )
  # SELECTION TEXT for MAP
  output$selected_star <- renderText({ 
    switch(chosen_star()-2,
           'Distribution of Star ratings (%)',
           'Average Costs (as ratio vs National rate)',
           'Average Acute Care Admissions rate',
           'Average Discharge to Community rate',
           'Average Potentially Preventable Readmissions rate',
           'Average % for High Ratings on Professional Care',
           'Average % for High Ratings on Communication of Care',
           'Average % for Willing to Recommend Agency',
           'Percent Privately Owned vs. Govt or Non-profit'
    )
  })
  
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
                           str_sub(Phone,7,10),sep='-')
             ),
    options = list(pageLength = 10)
  )
  
  #-Data Table companion text boxes---------------------------------------------
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
            icon = icon("code-branch")
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