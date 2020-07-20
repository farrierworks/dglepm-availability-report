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
library(DT)
library(data.table)

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
server <- function(input, output, session) {

    get_bex_data <- reactive({
        req(input$bex_file)
        bex_data <- fread(input$bex_file$datapath, drop = c("V2", "V4"))
        colnames(bex_data) <- c("EQUIPMENTNUMBER", "EOT", "USERSTATUS","ARMY", "ADM(MAT)", "NAVY", "RCAF", "CJOC", "DRDC", "MILPERS", "VCDS", "NOTASSIGNED")
        bex_data <- bex_data[USERSTATUS != "CRTD",]
        return(bex_data)

    })


    observeEvent(input$create_pivot_table, {

        bex_data <- get_bex_data()

        output$table <- renderDataTable({
            datatable(bex_data)
        })
    })

    observe({
        updateCheckboxGroupInput(session, "userStatus",
                          choices = unique(get_bex_data()$USERSTATUS))
    })

    output$plot <- renderPlot({
        plot(mtcars$mpg, mtcars$cyl)
    })


}

# Run the application
shinyApp(ui = ui, server = server)
