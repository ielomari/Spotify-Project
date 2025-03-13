library(shiny)

ui <- fluidPage(
  titlePanel("Reactive Iris Filter"),
  sidebarLayout(
    sidebarPanel(
      selectInput("species", "Choose Species:", choices = unique(iris$Species)),
      sliderInput("sepal_length", "Select Sepal Length Range:", 
                  min = min(iris$Sepal.Length), max = max(iris$Sepal.Length),
                  value = c(min(iris$Sepal.Length), max(iris$Sepal.Length))),
      actionButton("filter", "Filter Data")
    ),
    mainPanel(
      tableOutput("filtered_data")
    )
  )
)

server <- function(input, output, session) {
  # Reactive expression to filter based on species (updates instantly)
  species_filtered <- reactive({
    iris[iris$Species == input$species, ]
  })
  
  # Event reactive to filter data only when button is clicked
  filtered_data <- eventReactive(input$filter, {
    subset(species_filtered(), Sepal.Length >= input$sepal_length[1] & Sepal.Length <= input$sepal_length[2])
  })
  
  # Observe species selection and log to console
  observe({
    cat("Species selected:", input$species, "\n")
  })
  
  # Render table output
  output$filtered_data <- renderTable({
    filtered_data()
  })
}

shinyApp(ui, server)
