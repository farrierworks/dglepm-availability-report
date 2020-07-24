bex <- data.table(bex)
colnames(bex) <- c("EQUIPMENTNUMBER", "EOT", "USERSTATUS","ARMY", "ADM(MAT)", "NAVY", "RCAF", "CJOC", "DRDC", "MILPERS", "VCDS", "NOTASSIGNED")

ie36 <- ie36[,  c("Equipment", "Vehicle Type", "User status", "Allocation Code")]
ie36 <- data.table(ie36)
colnames(ie36) <- c("EQUIPMENTNUMBER", "EOT", "USERSTATUS.IE36", "ALLOCATIONCODE")

setkey(bex, "EQUIPMENTNUMBER")
setkey(ie36, "EQUIPMENTNUMBER")

ie36[bex]
