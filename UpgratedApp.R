library(shiny)
library(tidyverse)
library(DT)
library(bslib)
library(shinyWidgets)
library(shinyalert)  

# Load the dataset
spotify_data <- read.csv("data/SpotifyFeatures.csv")
sampled_data <- spotify_data[sample(nrow(spotify_data), 5000), ]

# Ensure release year column is numeric (if applicable)
if ("release_year" %in% colnames(sampled_data)) {
  sampled_data$release_year <- as.numeric(sampled_data$release_year)
} else {
  sampled_data$release_year <- sample(2000:2023, nrow(sampled_data), replace = TRUE)  # Dummy data if missing
}

# Define UI
ui <- page_sidebar(
  title = "🎵 Spotify Music Explorer",
  sidebar = sidebar(
    actionButton("show_alert", "ℹ️ Show Info", class = "btn-primary"),  # Button to trigger alert
    
    pickerInput("genre", "Choose a Genre:", 
                choices = c("All", unique(sampled_data$genre)),  
                selected = "All",
                options = list(`live-search` = TRUE)),
    
    pickerInput("artist", "Choose an Artist:", 
                choices = c("All", unique(sampled_data$artist_name)),  
                selected = "All",
                options = list(`live-search` = TRUE)),
    
    sliderInput("popularity", "Filter by Popularity:", 
                min = min(sampled_data$popularity, na.rm = TRUE), 
                max = max(sampled_data$popularity, na.rm = TRUE), 
                value = c(min(sampled_data$popularity, na.rm = TRUE), 
                          max(sampled_data$popularity, na.rm = TRUE)))
  ),
  
  navset_tab(
    nav_panel(title = "Danceability vs Energy", plotOutput("scatterPlot", height = "400px")),
    nav_panel(title = "Artist Timeline", plotOutput("timelinePlot", height = "400px")),
    nav_panel(title = "Songs Table", DTOutput("songTable"))
  ),
  
  theme = bs_theme(bootswatch = "minty")  # Apply a modern theme
)

# Define Server
server <- function(input, output, session) {
  
  # Initialize shinyalert when app starts
  observe({
    shinyalert(
      title = "Welcome to Spotify Music Explorer! 🎶",
      text = "Use the filters in the sidebar to explore songs based on genre, artist, and popularity.",
      type = "info",
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      showConfirmButton = TRUE
    )
  })
  
  # Show alert when button is clicked
  observeEvent(input$show_alert, {
    shinyalert(
      title = "How to Use the App 📌",
      text = "1️⃣ Select a genre and artist.\n2️⃣ Adjust popularity to filter songs.\n3️⃣ View song details, popularity trends, and energy levels.",
      type = "success",
      closeOnEsc = TRUE,
      closeOnClickOutside = TRUE,
      showConfirmButton = TRUE
    )
  })
  
  # Update artist choices dynamically based on selected genre
  observeEvent(input$genre, {
    filtered_artists <- sampled_data %>%
      filter(genre == input$genre | input$genre == "All") %>%
      pull(artist_name) %>%
      unique()
    
    updatePickerInput(session, "artist", choices = c("All", filtered_artists), selected = "All")
  })
  
  # Filter data based on genre and popularity selection
  filtered_data <- reactive({
    data <- sampled_data
    if (input$genre != "All") {
      data <- data %>% filter(genre == input$genre)
    }
    data <- data %>% filter(popularity >= input$popularity[1] & popularity <= input$popularity[2])
    return(data)
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
    data <- filtered_data()
    if (input$artist != "All") {
      data <- data %>% filter(artist_name == input$artist)
    }
    return(data)
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
