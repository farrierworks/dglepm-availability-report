#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Define UI for application that draws a histogram
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

