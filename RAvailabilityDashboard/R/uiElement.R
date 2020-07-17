box <- function(...){
  shinydashboard::box(...)
}

panelTitle <- function(sideBarWidth) {
  dashboardHeader(
    title = "DGLEPM Availability Report",
    titleWidth = sideBarWidth
  )
}

panelSelectInput <- function(buttonWidth) {
  wellPanel(
    fileInput("bex", "Upload BeX file in csv format"),
    fileInput("IE36", "Upload IE36 file in csv format"),
    fileInput("Depot", "Upload Depot file in csv format"),
    actionButton("create_pivot_table", "Create Report"),
    actionButton("plot_availability", "Plot Availability"),
    downloadButton("download_pivot", label = "Download Pivot Table"),
    downloadButton("download_CRTD", label = "Download CRTD")
    ,
    style = "color:black"
  )
}

pivot_table <- function() {
  tagList(
    h4("Availability Report"),
    box(
      width =  12,
      infoBoxOutput("table")
    )
  )
}

availability_plot <- function() {
  tagList(
    h4("Availability Plot"),
    box(width = 12,
        plotOutput("plot"))
  )
}

