library(shiny)
library(shinydashboard)
library(RAvailabilityDashboard)
library(DT)
library(data.table)
library(readr)

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
                     fluidRow(
                         column(6, checkboxGroupInput("userStatus","Select disposal user status", "")),
                         column(6, checkboxGroupInput("disposalCodes","Select disposal allocation codes", ""))
                     )),
            tabPanel(
                "Report", value = "tab2",
                fluidRow(pivot_table()),
                downloadButton("download_pivot_t", label = "Download Pivot Table")
                #fluidRow(availability_plot())
            ),
            tabPanel("Raw Data", value = "tab3",
                     h1(textOutput("bex_table_text")),
                     dataTableOutput("bex_table_raw"),
                     h1(textOutput("ie36_table_text")),
                     dataTableOutput("IE36_table_raw"),
                     h1(textOutput("depot_table_text")),
                     dataTableOutput("depot_table_raw"),
                     h1(textOutput("platform_table_text")),
                     dataTableOutput("platform_table_raw"))
        ))
    )
)
