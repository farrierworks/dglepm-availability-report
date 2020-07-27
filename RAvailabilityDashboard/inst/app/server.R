library(shiny)
library(shinydashboard)
library(RAvailabilityDashboard)
library(DT)
library(data.table)
library(readr)


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
        setnames(lookup_platform, c("equipment_object_type","platform"), c("EOT", "Platform"))
        return(lookup_platform)

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
        lookup_table <- get_lookup_file_platform()

        selected_disposed_user_status <- input$userStatus
        selected_disposed_codes <- input$disposalCodes

        pt <- build_pivot_table(bex_data, IE36_data, depot_data, selected_disposed_codes, selected_disposed_user_status, lookup_table)
        return(pt)
    })



    output$bex_table_text <- renderText({
        print("Bex raw data")
    })

    output$ie36_table_text <- renderText({
        print("IE36 raw data")
    })

    output$depot_table_text <- renderText({
        print("Depot raw data")
    })

    output$platform_table_text <- renderText({
        print("Platform raw data")
    })


    observeEvent(input$create_pivot_table, {

        pt_DT <- create_pivot_tables()


        output$bex_table_raw <- renderDataTable({
            datatable(get_bex_data())
        })

        #This concept can be applied to add dispoal column
        output$IE36_table_raw <- renderDataTable({
            datatable(get_IE36_data())
        })



        output$depot_table_raw <- renderDataTable({
            datatable(get_depot_data())
        })

        output$platform_table_raw <- renderDataTable({
            datatable(get_lookup_file_platform())
        })



        output$pivot_table <- renderDataTable({
            datatable(pt_DT)
        })


        fileName <- paste0(Sys.Date(),"-Avalability_report.xlsx")

        output$download_pivot_t <- downloadHandler(filename = fileName,content = function(file) {
            write_excel_csv(pt_DT, file)
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




}
