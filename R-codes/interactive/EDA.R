library(data.table)
library(reshape2)
library(pivottabler)
library(tibble)
library(tidyverse)


# Optimization ------------------------------------------------------------

  #TODO: warning on duplicates
#TODO: Error value (data quality)
#TODO: REGEX []
#TODO: error checking for required column
#TODO: remove NAs in the pivot table
#TODO: MEG from Access? 

disposed_user_status <- c("CBAL", "OBSO", "DLTD", "MONU", "QUAR")
disposal_codes <- c("MD", "MF", "MZ", "MM", "ME")

EOT <- c("EV0309", "EV0B94", "EV0J31", "EV0J06", "EV0J46", "EV0J07", "EV0J08",
         "EV0J83", "EV0J82", "EV0J81", "EV0B82", "EV0B97", "EV0J44", "EV0J38",
         "EV0J36", "EV0J35", "EV0J37", "EV0B54", "EV0B68", "EV0B80")

EqptName <- c("M777", "AHSVS", "M113A3", "Bison", "LAV 6.0", "Coyote", "LAV 3.0",
              "Leo 2",  "Leo 2",  "Leo 2",  "LUVW SMP", "MSVS SMP", "TAPV", "M113A3",
              "M577A3", "M113A3", "TLAV MT", "LSVW", "MLVW", "HLVW")

lookup <- data.table(EOT = EOT, EqptName = EqptName) %>% 
  setkey("EOT")

bex <- fread(paste0(getwd(),"/Data/Bex.csv"), drop = c("V2", "V4")) %>% 
  `colnames<-`(c("EQUIPMENTNUMBER", "EOT", "USERSTATUS","ARMY", "ADM(MAT)", "NAVY", "RCAF", "CJOC", "DRDC", "MILPERS", "VCDS", "NOTASSIGNED" )) %>% 
  setkey("EQUIPMENTNUMBER")

CRTD <- bex[USERSTATUS == "CRTD",]
bex <- bex[USERSTATUS != "CRTD",]


IE36 <- fread(paste0(getwd(),"/Data/IE36.csv"), select = c("Equipment", "Vehicle Type", "User status", "Allocation Code")) %>% 
  `colnames<-`(c("EQUIPMENTNUMBER", "EOT", "USERSTATUS.IE36", "ALLOCATIONCODE")) %>% 
  setkey("EQUIPMENTNUMBER")

data_202 <- fread(paste0(getwd(),"/Data/202.csv"), select = "Equipment") %>% 
  `colnames<-`("EQUIPMENTNUMBER") %>% 
  na.omit() %>% 
  distinct(EQUIPMENTNUMBER) %>% 
  mutate(Depot = 1) %>% 
  as.data.table() %>% 
  setkey("EQUIPMENTNUMBER")

IE36_bex <- IE36[bex] %>% 
  mutate(DISPOSED = NA) %>% 
  as.data.table()

user_status_in_bex <- unique(IE36_bex$USERSTATUS)

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

disposed_user_status_extracted <- find_pattern(disposed_user_status, user_status_in_bex)

IE36_bex$DISPOSED[IE36_bex$USERSTATUS %in% disposed_user_status_extracted] <- 1

IE36_bex$DISPOSED[IE36_bex$ALLOCATIONCODE %in% disposal_codes] <- 1
#TODO: some equipment dont have allocation codes

IE36_bex[IE36_bex$DISPOSED == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", 
                                   "RCAF", "CJOC", "DRDC", "VCDS", "NOTASSIGNED")) := NA] %>% 
  setkey("EQUIPMENTNUMBER") 

IE36_bex_202 <- data_202[IE36_bex] %>% 
  setkey("EOT")

IE36_bex_202[IE36_bex_202$Depot == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF", "CJOC", "DRDC", "VCDS", "NOTASSIGNED", "DISPOSED")) := NA]

IE36_bex_202 <- IE36_bex_202[lookup] %>% 
  select("EqptName","ARMY", "CJOC", "RCAF", "MILPERS",
         "VCDS", "NAVY", "ADM(MAT)", "DRDC", "Depot", "DISPOSED", "NOTASSIGNED")

pt_DT <- IE36_bex_202[,lapply(.SD, sum, na.rm = TRUE), by = EqptName] %>% 
  setnames("EqptName", "EOT")

pt_DT[, available_subtotal := rowSums(.SD), .SDcols = c("ARMY", "CJOC", "RCAF", "MILPERS",
                                                        "VCDS", "NAVY", "ADM(MAT)")] 
pt_DT[, unavailable_subtotal := rowSums(.SD), .SDcols = c("DRDC", "Depot", "DISPOSED")]

pt_DT[, Total := available_subtotal + unavailable_subtotal]

pt_DT[, Availability := round(available_subtotal/Total, 4)*100] %>% 
  setcolorder(c("EOT", "Total" ,"Availability", "ARMY", "CJOC", "RCAF", "MILPERS",
                "VCDS", "NAVY", "ADM(MAT)", "available_subtotal", "DRDC", "Depot", "DISPOSED",
                "unavailable_subtotal", "NOTASSIGNED")) %>% 
  setnames(c("available_subtotal", "unavailable_subtotal"), c("Available Subtotal", "Unavailable Subtotal")) %>% 
  setorder()

filename <- paste0(Sys.Date(),"-Avalability_report.xlsx")

write_excel_csv(pt_DT, filename)
  

# Plot --------------------------------------------------------------------


pt_DT %>% 
  select(c("EOT", "ARMY", "CJOC", "RCAF", "MILPERS", "VCDS", "NAVY", "ADM(MAT)", "DRDC", "Depot", "DISPOSED", "NOTASSIGNED")) %>% 
  melt(id.vars = "EOT") %>% 
  ggplot(aes(x = EOT, y = value, fill = variable)) +
  geom_bar(stat="identity", position=position_dodge())
