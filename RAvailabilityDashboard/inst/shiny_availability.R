#TODO: extract only DEACT or HARD
#TODO: rename variables
#TODO: function to reduce redunancy
#TODO: delete commented out functions


# Packages ----------------------------------------------------------------

library(shiny)
library(data.table)
library(reshape2)
library(tibble)
library(tidyverse)
library(DT)


ui <- fluidPage(
  tabsetPanel(
    tabPanel("Pivot Table",
      sidebarLayout(
        sidebarPanel(
          fileInput("bex", "Upload BeX file in csv format"),
          fileInput("IE36", "Upload IE36 file in csv format"),
          fileInput("Depot", "Upload Depot file in csv format"),
          actionButton("create_pivot_table", "Create Report"),
          actionButton("plot_availability", "Plot Availability"),
          downloadButton("download_pivot", label = "Download Pivot Table"),
          downloadButton("download_CRTD", label = "Download CRTD")
        ),
        mainPanel(
          DTOutput("pivot_table"),
          br(),
          plotOutput("plot_availability")
        )
      )
    ),


# Error panel -------------------------------------------------------------

    tabPanel("Error",

# Error - sidebarPanel ----------------------------------------------------
             sidebarPanel(
               actionButton("INSV_disposed", "Fleet INSV with Disposed allocation code"),
               br(),
               actionButton("WO_allocation_code", "Fleet without allocation code"),
               downloadButton("download_full_report", label = "Download Full Report"),
               downloadButton("download_data_pivot", "Download Pivot Table")
             ),

# Error - mainPanel -------------------------------------------------------
             mainPanel(
               dataTableOutput("table_INSV_disposed"),
               br(),
               dataTableOutput("table_INSV_disposed_FE"),
               dataTableOutput("table_temp"), #TODO: delete afterwards
               dataTableOutput("table_temp2"),
               textOutput("text_temp"),
               textOutput("text_temp2")
             )
             )
  )

)


# Server ------------------------------------------------------------------


server <- function(input,output) {

# Setup values ------------------------------------------------------------

  values <- reactiveValues(data = NULL)

  values$disposed_user_status <- c("CBAL", "OBSO", "DLTD", "MONU", "QUAR")
  values$disposal_codes <- c("MD", "MF", "MZ", "MM", "ME")


  # Reactive functions ------------------------------------------------------


  lookupTable <- reactive({
    EOT <- c("EV0309", "EV0B94", "EV0J31", "EV0J06", "EV0J46", "EV0J07", "EV0J08",
             "EV0J83", "EV0J82", "EV0J81", "EV0B82", "EV0B97", "EV0J44", "EV0J38",
             "EV0J36", "EV0J35", "EV0J37", "EV0B54", "EV0B68", "EV0B80")

    EqptName <- c("M777", "AHSVS", "M113A3", "Bison", "LAV 6.0", "Coyote", "LAV 3.0",
                  "Leo 2",  "Leo 2",  "Leo 2",  "LUVW SMP", "MSVS SMP", "TAPV", "M113A3",
                  "M577A3", "M113A3", "TLAV MT", "LSVW", "MLVW", "HLVW")

    lookup <- data.table(EOT = EOT, EqptName = EqptName) %>%
      setkey("EOT")
  })

  bex_read_csv <- reactive({
    bex <- fread(input$bex$datapath, drop = c("V2", "V4")) %>%
      `colnames<-`(c("EQUIPMENTNUMBER", "EOT", "USERSTATUS","ARMY", "ADM(MAT)", "NAVY", "RCAF", "CJOC", "DRDC", "MILPERS", "VCDS", "NOTASSIGNED" )) %>%
      setkey("EQUIPMENTNUMBER")

    values$CRTD <- bex[USERSTATUS == "CRTD",]
    bex <- bex[USERSTATUS != "CRTD",]
    return(bex)
  })

  IE36_read_csv <- reactive({
    IE36 <- fread(input$IE36$datapath, select = c("Equipment", "Vehicle Type", "User status", "Allocation Code")) %>%
      `colnames<-`(c("EQUIPMENTNUMBER", "EOT", "USERSTATUS.IE36", "ALLOCATIONCODE")) %>%
      setkey("EQUIPMENTNUMBER")
    return(IE36)
  })

  depot_read_csv <- reactive({
    data_202 <- fread(input$Depot$datapath, select = "Equipment") %>%
      `colnames<-`("EQUIPMENTNUMBER") %>%
      na.omit() %>%
      distinct(EQUIPMENTNUMBER) %>%
      mutate(Depot = 1) %>%
      as.data.table() %>%
      setkey("EQUIPMENTNUMBER")

    return(data_202)
  })

  IE36_bex_left_join <- reactive({
    IE36 <- values$IE36
    bex <- values$bex

    IE36_bex <- IE36[bex] %>%
      mutate(DISPOSED = NA) %>%
      as.data.table()

    return(IE36_bex)
  })

  INSV_disposed <- reactive({
    IE36_bex <- values$IE36_bex
    lookup <- values$lookup
    disposal_codes <- values$disposal_codes
    INSV_disposed <- IE36_bex[IE36_bex$ALLOCATIONCODE %in% disposal_codes & IE36_bex$USERSTATUS == "INSV",] %>%
      setkey("EOT")

    INSV_disposed <- lookup[INSV_disposed] #%>%
      #select("EqptName", "USERSTATUS", "ALLOCATIONCODE")

    return(INSV_disposed)
  })

  add_disposed_column <- reactive({

    IE36_bex <- values$IE36_bex
    disposal_codes <- values$disposal_codes

    disposed_user_status <- values$disposed_user_status

    user_status_in_bex <- unique(IE36_bex$USERSTATUS)

    disposed_user_status_extracted <- find_pattern(disposed_user_status, user_status_in_bex)

    IE36_bex$DISPOSED[IE36_bex$USERSTATUS %in% disposed_user_status_extracted] <- 1

    IE36_bex$DISPOSED[IE36_bex$ALLOCATIONCODE %in% disposal_codes] <- 1
    #TODO: some equipment dont have allocation codes

    IE36_bex[IE36_bex$DISPOSED == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF", "CJOC", "DRDC", "VCDS", "NOTASSIGNED")) := NA] %>%
      setkey("EQUIPMENTNUMBER")

    return(IE36_bex)
  })

  add_202_column <- reactive({

    IE36_bex <- values$IE36_bex
    data_202 <- values$data_202
    lookup <- values$lookup

    IE36_bex_202 <- data_202[IE36_bex] %>%
      setkey("EOT")

    IE36_bex_202[IE36_bex_202$Depot == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF", "CJOC", "DRDC", "VCDS", "NOTASSIGNED", "DISPOSED")) := NA]

    IE36_bex_202 <- IE36_bex_202[lookup] %>%
      select("EqptName","ARMY", "CJOC", "RCAF", "MILPERS",
             "VCDS", "NAVY", "ADM(MAT)", "DRDC", "Depot", "DISPOSED", "NOTASSIGNED")

    return(IE36_bex_202)
  })

  find_pattern <- function(pattern, status) {
    temp <- c()
    pattern <- toupper(pattern)
    status <- toupper(status)
    for (i in 1:length(pattern)) {
      posn <- grep(pattern[i], status)
      temp <- c(temp,posn)
    }
    status <- status[unique(temp)]
    return(status)
  }

  pivot_table <- reactive({

    IE36_bex_202 <- values$IE36_bex_202

    pt_DT <- IE36_bex_202[,lapply(.SD, sum, na.rm = TRUE), by = EqptName] %>%
      setnames("EqptName", "EOT")

    pt_DT[, available_subtotal := rowSums(.SD), .SDcols = c("ARMY", "CJOC", "RCAF", "MILPERS",
                                                            "VCDS", "NAVY", "ADM(MAT)")]
    pt_DT[, unavailable_subtotal := rowSums(.SD), .SDcols = c("DRDC", "Depot", "DISPOSED")]

    pt_DT[, Total := available_subtotal + unavailable_subtotal]

    pt_DT <- pt_DT[, Availability := round(available_subtotal/Total, 4)*100] %>%
      setcolorder(c("EOT", "Total" ,"Availability", "ARMY", "CJOC", "RCAF", "MILPERS",
                    "VCDS", "NAVY", "ADM(MAT)", "available_subtotal", "DRDC", "Depot", "DISPOSED",
                    "unavailable_subtotal", "NOTASSIGNED")) %>%
      setnames(c("available_subtotal", "unavailable_subtotal"), c("Available Subtotal", "Unavailable Subtotal")) %>%
      setorder()

    return(pt_DT)
  })


# Observe event - create pivot table --------------------------------------

  observeEvent(input$create_pivot_table, {
    #TODO: break down the functions


    values$lookup <- lookupTable()

    values$bex <- bex_read_csv()

    values$IE36 <- IE36_read_csv()

    values$data_202 <- depot_read_csv()

    values$IE36_bex <- IE36_bex_left_join()

    values$INSV_disposed <- INSV_disposed()

    values$IE36_bex <- add_disposed_column()

    values$IE36_bex_202 <- add_202_column()

    values$pt_DT <- pivot_table()

    output$pivot_table <- renderDataTable({
      datatable(values$pt_DT, editable = "cell")
    })

    fileName <- paste0(Sys.Date(),"-Avalability_report.xlsx")

    output$download_pivot <- downloadHandler(filename = fileName,content = function(file) {
      write_excel_csv(values$pt_DT, file)
    })

    output$download_CRTD <- downloadHandler(filename = "CRTD.xlsx",content = function(file) {
      write_excel_csv(values$CRTD, file)
    })



  })


# Observe event - create plot ---------------------------------------------

  observeEvent(input$plot_availability, {
    output$plot_availability <- renderPlot({
      values$pt_DT %>%
        select(c("EOT", "ARMY", "CJOC", "RCAF", "MILPERS", "VCDS", "NAVY", "ADM(MAT)", "DRDC", "Depot", "DISPOSED", "NOTASSIGNED")) %>%
        melt(id.vars = "EOT") %>%
        ggplot(aes(x = EOT, y = value, fill = variable)) +
        geom_bar(stat="identity", position=position_dodge())
    })
  })


# Observe event - error table ---------------------------------------------


  observeEvent(input$INSV_disposed, {
    output$table_INSV_disposed <- renderDataTable({

      if(is.null(values$INSV_disposed)) {
        values$lookup <- lookupTable()

        values$bex <- bex_read_csv()

        values$IE36 <- IE36_read_csv()

        values$data_202 <- depot_read_csv()

        values$IE36_bex <- IE36_bex_left_join()

        values$INSV_disposed <- INSV_disposed()

        #TODO: delete afterwards
        #write.csv(INSV_disposed, "INSV_disposed.csv")
        #write.csv(values$data_202, "depot.csv")

        values$INSV_disposed[,.N, by = EqptName]

      } else {
        INSV_disposed <- values$INSV_disposed
        INSV_disposed[,.N, by = EqptName]
      }
    })

    output$table_INSV_disposed_FE <- renderDataTable({
      INSV_disposed <- values$INSV_disposed %>%
        select("EqptName","EQUIPMENTNUMBER","ALLOCATIONCODE", "USERSTATUS", "ARMY", "ADM(MAT)",
             "NAVY", "RCAF", "CJOC","VCDS", "DRDC", "MILPERS", "DISPOSED", "NOTASSIGNED") %>%
        setkey("EQUIPMENTNUMBER") %>%
        setnames("EqptName", "EOT")

      data_202 <- values$data_202 %>%
        as.data.table() %>%
        setkey("EQUIPMENTNUMBER")

      #TODO: covert this to a function - supply any data with EQUIPMENTNUMBER
      INSV_disposed_202 <- data_202[INSV_disposed]

      INSV_disposed_202[INSV_disposed_202$Depot == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF",
                                                        "CJOC", "DRDC", "VCDS", "NOTASSIGNED", "DISPOSED")) := NA]


      values$INSV_disposed_202 <- INSV_disposed_202 %>%
        setcolorder(c("EQUIPMENTNUMBER", "EOT", "USERSTATUS", "ALLOCATIONCODE", "ARMY",	"ADM(MAT)",
                      "NAVY",	"RCAF",	"CJOC",	"VCDS",	"DRDC",	"MILPERS", "Depot", "DISPOSED", "NOTASSIGNED"))



      pt_data <- INSV_disposed_202[, c("EOT", "ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF","CJOC", "DRDC", "VCDS", "NOTASSIGNED", "DISPOSED")]

      values$pt_data <- pt_data[,lapply(.SD, sum, na.rm = TRUE), by = EOT]

      values$pt_data
    })

    })

  fileName_INSV_disposed_202 <- paste0(Sys.Date(),"-allocation_code_userstat_full.xlsx")
  fileName_INSV_disposed_202_pt <- paste0(Sys.Date(),"-allocation_code_userstat_pivot_table.xlsx")

  output$download_full_report <- downloadHandler(filename = fileName_INSV_disposed_202,content = function(file) {
    write_excel_csv(values$INSV_disposed_202, file)
  })

  output$download_data_pivot <- downloadHandler(filename = fileName_INSV_disposed_202_pt, content = function(file){
    write_excel_csv(values$pt_data, file)
  })


}



shinyApp(ui = ui, server = server)
