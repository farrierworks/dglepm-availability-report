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
            tabPanel("Input Variables", value = "tab1",
                     checkboxGroupInput("userStatus","Select disposal user status", ""),
                     checkboxGroupInput("disposalCodes","Select disposal allocation codes", "")

                     ),
            tabPanel(
                "Report", value = "tab2",
                fluidRow(pivot_table()),
                fluidRow(availability_plot())
            ),
            tabPanel("Raw Data", value = "tab3",
            dataTableOutput("IE36_table_raw"),
            dataTableOutput("bex_table_raw"),
            dataTableOutput("depot_table_raw"))
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

    get_crtd_data <- reactive({
        req(input$bex_file)
        bex_data <- fread(input$bex_file$datapath, drop = c("V2", "V4"))
        colnames(bex_data) <- c("EQUIPMENTNUMBER", "EOT", "USERSTATUS","ARMY", "ADM(MAT)", "NAVY", "RCAF", "CJOC", "DRDC", "MILPERS", "VCDS", "NOTASSIGNED")
        crtd_data <- bex_data[USERSTATUS == "CRTD",]
        return(crtd_data)
    })

    get_lookup_file_platform <- reactive({
        req(input$lookup_file_platform)
        lookup_platform <- fread(input$lookup_file_platform$datapath)

    })

    get_IE36_data <- reactive({
        req(input$IE36_file)
        IE36_data <- fread(input$IE36_file$datapath, select = c("Equipment", "Vehicle Type", "User status", "Allocation Code"))
        colnames(IE36_data) <- c("EQUIPMENTNUMBER", "EOT", "USERSTATUS.IE36", "ALLOCATIONCODE")
        return(IE36_data)
    })


    get_depot_data <- reactive({
        req(input$depot_file)
        data_202 <- fread(input$depot_file$datapath, select = "Equipment")
        data_202 <- clean_data_202(data_202)
        return(data_202)
    })

    create_pivot_tables <- reactive({
        bex_data <- get_bex_data()
        IE36_data <- get_IE36_data()
        depot_data <- get_depot_data()

        selected_disposed_user_status <- input$userStatus
        selected_disposed_codes <- input$disposalCodes

        pt <- build_pivot_table(bex_data, IE36_data, depot_data, selected_disposed_codes, selected_disposed_user_status)
        return(pt)
    })






    observeEvent(input$create_pivot_table, {


        output$bex_table_raw <- renderDataTable({
           datatable(get_bex_data())

        })

        #This concept can be applied to add dispoal column
        output$IE36_table_raw <- renderDataTable({
            selected_disposal_codes <- input$disposalCodes
            IE36_data <- get_IE36_data()
            temp <- IE36_data[IE36_data$ALLOCATIONCODE %in% selected_disposal_codes,]
            datatable(temp)
        })

        output$depot_table_raw <- renderDataTable({
            datatable(get_depot_data())
        })

        output$pivot_table <- renderDataTable({
            datatable(create_pivot_tables())
        })
    })



# Input variables ---------------------------------------------------------

    observe({
        updateCheckboxGroupInput(session, "userStatus",
                          choices = sort(unique(get_bex_data()$USERSTATUS)))
    })


    observe({
        updateCheckboxGroupInput(session, "disposalCodes",
                                 choices = sort(unique(get_IE36_data()$ALLOCATIONCODE)))
    })


    #TODO: Delete
    output$text <- renderText({
        print(getwd())
    })

    output$plot <- renderPlot({
        plot(mtcars$mpg, mtcars$cyl)
    })


}

# Run the application
shinyApp(ui = ui, server = server)
