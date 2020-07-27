#' @export
box <- function(...){
  shinydashboard::box(...)
}

#' @export
panelTitle <- function(sideBarWidth) {
  dashboardHeader(
    title = "DGLEPM Availability Report",
    titleWidth = sideBarWidth
  )
}

#' @export
panelSelectInput <- function(buttonWidth) {
  wellPanel(
    fileInput("bex_file", "Upload BeX file in csv format"),
    fileInput("IE36_file", "Upload IE36 file in csv format"),
    fileInput("depot_file", "Upload Depot file in csv format"),
    fileInput("lookup_file_platform", "Upload EOT-Vehicle file in csv format"),
    actionButton("create_pivot_table", "Create Report")
#    actionButton("plot_availability", "Plot Availability"),
#    downloadButton("download_pivot", label = "Download Pivot Table"),
#    downloadButton("download_CRTD", label = "Download CRTD")
    ,
    style = "color:black"
  )
}

#' @export
pivot_table <- function() {
  tagList(
    h4("Availability Report"),
    box(
      width =  12,
      dataTableOutput("pivot_table")
    )
  )
}


#' @export
availability_plot <- function() {
  tagList(
    h4("Availability Plot"),
    box(width = 12,
        plotOutput("plot"))
  )
}



