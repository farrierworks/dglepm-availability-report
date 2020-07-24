#' @export

clean_data_202 <- function(data) {
  data <- na.omit(data)
  data <- unique(data)
  data <- data.table(data)
  colnames(data) <- "EQUIPMENTNUMBER"
  data$Depot <- 1
  return(data)
}

#' @export

join_ie36_bex <- function(bex_data, IE36_data) {
  setkey(bex_data, "EQUIPMENTNUMBER")
  setkey(IE36_data, "EQUIPMENTNUMBER")
  IE36_bex <- merge.data.table(IE36_data, bex_data)
  IE36_bex$DISPOSED <- NA
  IE36_bex$EOT.y <- NULL
  IE36_bex$USERSTATUS.IE36 <- NULL
  setnames(IE36_bex, "EOT.x", "EOT")
  IE36_bex <- as.data.table(IE36_bex)
  return(IE36_bex)
}

#' @export
add_disposed_column <- function(disposal_codes, user_status, ie36_bex){

  ie36_bex$DISPOSED[ie36_bex$USERSTATUS %in% user_status] <- 1
  ie36_bex$DISPOSED[ie36_bex$ALLOCATIONCODE %in% disposal_codes] <- 1
  #TODO: some equipment dont have allocation codes

  ie36_bex[ie36_bex$DISPOSED == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF", "CJOC", "DRDC", "VCDS", "NOTASSIGNED", "Depot")) := NA]

  return(ie36_bex)
}

#' @export
join_ie36_depot <- function(ie36_bex, depot_data) {
  setkey(ie36_bex, "EQUIPMENTNUMBER")
  setkey(depot_data, "EQUIPMENTNUMBER")
  ie36_bex_depot <- merge.data.table(ie36_bex, depot_data, all.x = TRUE)
  ie36_bex_depot[ie36_bex_depot$Depot == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF", "CJOC", "DRDC", "VCDS", "NOTASSIGNED")) := NA]

  return(ie36_bex_depot)
}


#' @export
build_pivot_table <- function(bex_data, IE36_data, depot_data, disposal_codes, user_status) {
  ie36_bex <- join_ie36_bex(bex_data, IE36_data)
  ie36_bex <- join_ie36_depot(ie36_bex, depot_data)
  pt <- add_disposed_column(disposal_codes, user_status, ie36_bex)

  return(pt)
}



