#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library("shiny")
library("shinydashboard")
library(RAvailabilityDashboard)

buttonWidth <- 220
sideBarWidth <- 350


# Define UI for application that draws a histogram
ui <- dashboardPage(
    skin = "red",
    header = panelTitle(sideBarWidth),

    sidebar = dashboardSidebar(
        width = sideBarWidth,
        shinyjs::useShinyjs(),
        panelSelectInput(buttonWidth)
    ),
    body = dashboardBody(
        tags$head(
            tags$link(
                rel = "stylesheet",
                type = "text/css",
                href = "styleDefinitions.css"
            )),
        div(class = "span", tabsetPanel(
            id = "Reiter",
            tabPanel(
                "Report", value = "tab1",
                fluidRow(pivot_table()),
                fluidRow(availability_plot())
            ),
            tabPanel("Raw Data", value = "tab2", DT::DTOutput("rawDataOverview"))
        ))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$table <- renderTable({
        head(mtcars)
    })

    output$plot <- renderPlot({
        plot(mtcars$mpg, mtcars$cyl)
    })


}

# Run the application
shinyApp(ui = ui, server = server)
