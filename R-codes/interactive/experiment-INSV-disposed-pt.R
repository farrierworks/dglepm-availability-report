library(readxl)
library(data.table)
library(dplyr)

INSV_disposed <- read.csv("interactive/INSV_disposed.csv") %>% 
  select("EqptName","EQUIPMENTNUMBER","ALLOCATIONCODE", "USERSTATUS", "ARMY", "ADM.MAT.",
         "NAVY", "RCAF", "CJOC","VCDS", "DRDC", "MILPERS", "DISPOSED", "NOTASSIGNED") %>% 
  as.data.table() %>% 
  setkey("EQUIPMENTNUMBER")
depot <- read.csv("interactive/depot.csv") %>% 
  select("EQUIPMENTNUMBER", "Depot") %>% 
  as.data.table() %>% 
  setkey("EQUIPMENTNUMBER")

INSV_disposed_202 <- depot[INSV_disposed] %>% 
  setnames(c("ADM.MAT.", "EqptName"), c("ADM(MAT)", "EOT"))

INSV_disposed_202[INSV_disposed_202$Depot == 1,(c("ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF", 
                                        "CJOC", "DRDC", "VCDS", "NOTASSIGNED", "DISPOSED")) := NA]
pt_data <- INSV_disposed_202[, c("EOT", "ARMY", "NAVY", "MILPERS", "ADM(MAT)", "RCAF","CJOC", "DRDC", "VCDS", "NOTASSIGNED", "DISPOSED")]

View(pt_data[,lapply(.SD, sum, na.rm = TRUE), by = EOT])
