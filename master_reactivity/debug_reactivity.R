library(shiny)

ui <- fluidPage(
  selectInput("species", "Choose Species:", choices = unique(iris$Species)),
  actionButton("update", "Update Data"),
  tableOutput("filtered_data")
)

server <- function(input, output, session) {
  # Fix 1: Use reactiveValues() to store filtered data persistently
  rv <- reactiveValues(filtered_data = iris[iris$Species == unique(iris$Species)[1], ])
  
  # Fix 2: Use observeEvent() instead of eventReactive() for updating data on button click
  observeEvent(input$update, {
    rv$filtered_data <- iris[iris$Species == input$species, ]
  })
  
  # Render the updated table
  output$filtered_data <- renderTable({
    rv$filtered_data
  })
}

shinyApp(ui, server)
