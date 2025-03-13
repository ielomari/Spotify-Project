library(shiny)

ui <- fluidPage(
  titlePanel("Score Tracker"),
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Enter your name:"),
      actionButton("add_score", "Add Score"),
      actionButton("reset_score", "Reset Score")
    ),
    mainPanel(
      textOutput("display_name"),
      textOutput("display_score")
    )
  )
)

server <- function(input, output, session) {
  # Reactive values to store user name and score
  user_data <- reactiveValues(name = "", score = 0)
  
  # Update name only if non-empty
  observeEvent(input$name, {
    if (input$name != "") {
      user_data$name <- input$name
    }
  })
  
  # Increase score when button is clicked
  observeEvent(input$add_score, {
    user_data$score <- user_data$score + 1
  })
  
  # Reset score when reset button is clicked
  observeEvent(input$reset_score, {
    user_data$score <- 0
  })
  
  # Render outputs
  output$display_name <- renderText({
    paste("Player:", user_data$name)
  })
  
  output$display_score <- renderText({
    paste("Score:", user_data$score)
  })
}

shinyApp(ui, server)
