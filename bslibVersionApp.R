library(shiny)
library(tidyverse)
library(DT)
library(bslib)

# Load the dataset
spotify_data <- read.csv("data/SpotifyFeatures.csv")

# Ensure release year column is numeric (if applicable)
if ("release_year" %in% colnames(spotify_data)) {
  spotify_data$release_year <- as.numeric(spotify_data$release_year)
} else {
  spotify_data$release_year <- sample(2000:2023, nrow(spotify_data), replace = TRUE)  # Dummy data if missing
}

ui <- page_sidebar(
  title = "🎵 Spotify Music Explorer",
    
    sidebar = sidebar(
      selectInput("genre", "Choose a Genre:", 
                  choices = c("All", unique(spotify_data$genre)),  
                  selected = "All"),
      
      selectInput("artist", "Choose an Artist:", 
                  choices = c("All", unique(spotify_data$artist_name)),  
                  selected = "All")
    ),
    
    body = navset_tab(
      nav_panel(title = "Danceability vs Energy", plotOutput("scatterPlot", height = "400px")),
      nav_panel(title = "Artist Timeline", plotOutput("timelinePlot", height = "400px")),
      nav_panel(title = "Songs Table", DTOutput("songTable"))
    ),
    
    theme = bs_theme(bootswatch = "minty")  # Apply a modern theme
  )


# Define Server
server <- function(input, output, session) {
  
  # Update artist choices dynamically based on selected genre
  observeEvent(input$genre, {
    filtered_artists <- spotify_data %>%
      filter(genre == input$genre | input$genre == "All") %>%
      pull(artist_name) %>%
      unique()
    
    updateSelectInput(session, "artist", choices = c("All", filtered_artists), selected = "All")
  })
  
  # Filter data based on genre selection
  filtered_data <- reactive({
    if (input$genre == "All") {
      spotify_data
    } else {
      spotify_data %>% filter(genre == input$genre)
    }
  })
  
  # Scatter plot: Danceability vs Energy
  output$scatterPlot <- renderPlot({
    ggplot(filtered_data(), aes(x = danceability, y = energy, color = genre)) +
      geom_point() +
      labs(title = paste("Danceability vs. Energy for", input$genre),
           x = "Danceability", y = "Energy") +
      theme_minimal()
  })
  
  # Filter data based on artist selection
  artist_data <- reactive({
    if (input$artist == "All") {
      spotify_data
    } else {
      spotify_data %>% filter(artist_name == input$artist)
    }
  })
  
  # Artist timeline: Popularity over time
  output$timelinePlot <- renderPlot({
    ggplot(artist_data(), aes(x = release_year, y = popularity, label = track_name)) +
      geom_line(color = "blue", size = 1) +
      geom_point(color = "red", size = 2) +
      labs(title = ifelse(input$artist == "All", "Popularity Timeline for All Artists", paste("Popularity Timeline for", input$artist)),
           x = "Year", y = "Popularity") +
      theme_minimal()
  })
  
  # Table of Songs
  output$songTable <- renderDT({
    datatable(filtered_data()[, c("track_name", "artist_name", "popularity", "danceability", "energy")])
  })
}

# Run App
shinyApp(ui = ui, server = server)