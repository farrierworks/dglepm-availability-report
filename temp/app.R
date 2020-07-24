#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)
library(temp)




# Define UI for application that draws a histogram
ui <- fluidPage(



  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
    ),

    # Show a plot of the generated distribution
    mainPanel(
      dataTableOutput("table")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  output$table <- renderDataTable({
    data <- data.table(mtcars)
    data <- zero_cols(data)
    return(data)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
