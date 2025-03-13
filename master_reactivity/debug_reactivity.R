library(shiny)

ui <- fluidPage(
  selectInput("species", "Choose Species:", choices = unique(iris$Species)),
  actionButton("update", "Update Data"),
  tableOutput("filtered_data")
)

server <- function(input, output, session) {
  filtered <- reactive({
    iris[iris$Species == input$species, ]
  })
  
  filtered_event <- eventReactive(input$update, {
    filtered()
  })
  
  output$filtered_data <- renderTable({
    filtered_event()
  })
}

shinyApp(ui, server)
