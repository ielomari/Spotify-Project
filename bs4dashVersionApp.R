library(shiny)
library(tidyverse)
library(DT)
library(bs4Dash)

# Load the dataset
spotify_data <- read.csv("data/SpotifyFeatures.csv")
sampled_data <- spotify_data[sample(nrow(spotify_data), 200), ]


# Ensure release year column is numeric (if applicable)
if ("release_year" %in% colnames(sampled_data)) {
  sampled_data$release_year <- as.numeric(sampled_data$release_year)
} else {
  sampled_data$release_year <- sample(2000:2023, nrow(sampled_data), replace = TRUE)  # Dummy data if missing
}

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Spotify Music Explorer 🎵"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Danceability vs Energy", tabName = "scatter", icon = icon("music")),
      menuItem("Artist Timeline", tabName = "timeline", icon = icon("chart-line")),
      menuItem("Song Table", tabName = "table", icon = icon("table"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "scatter", box(plotOutput("scatterPlot"), width = 12)),
      tabItem(tabName = "timeline", box(plotOutput("timelinePlot"), width = 12)),
      tabItem(tabName = "table", box(DTOutput("songTable"), width = 12))
    )
  )
)

# Define Server
server <- function(input, output, session) {
  
  # Update artist choices dynamically based on selected genre
  observeEvent(input$genre, {
    filtered_artists <- sampled_data %>%
      filter(genre == input$genre | input$genre == "All") %>%
      pull(artist_name) %>%
      unique()
    
    updateSelectInput(session, "artist", choices = c("All", filtered_artists), selected = "All")
  })
  
  # Filter data based on genre selection
  filtered_data <- reactive({
    if (input$genre == "All") {
      sampled_data
    } else {
      sampled_data %>% filter(genre == input$genre)
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
      sampled_data
    } else {
      sampled_data %>% filter(artist_name == input$artist)
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
