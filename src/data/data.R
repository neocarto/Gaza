# In R language
library(sf)
download.file("https://unosat.org/static/unosat_filesystem/3904/OCHA_OPT-015_UNOSAT_GazaStrip_OPT_CDA_06July2024_GDB.zip", "rawdata" )
unzip("rawdata")
x <- st_read(dsn = "UNOSAT_GazaStrip_CDA_06July2024.gdb", layer= "Damage_Sites_GazaStrip_20240706")
cols <- c("EventCode","Municipality",
          "SensorDate", "SensorDate_2", "SensorDate_3",
          "SensorDate_4", "SensorDate_5", "SensorDate_6",   
          "SensorDate_7", "SensorDate_8",   
          "Main_Damage_Site_Class", "Main_Damage_Site_Class_2",
          "Main_Damage_Site_Class_3","Main_Damage_Site_Class_4",
          "Main_Damage_Site_Class_5","Main_Damage_Site_Class_6",
          "Main_Damage_Site_Class_7","Main_Damage_Site_Class_8",
         "Damage_Status_2", "Damage_Status_3",
          "Damage_Status_4","Damage_Status_5","Damage_Status_6",
          "Damage_Status_7","Damage_Status_8")
x <- cbind(id = rownames(x), x[,cols], st_coordinates(x)) %>% st_drop_geometry()
write.csv(x, "data.csv", row.names = FALSE)
file.remove("rawdata")
unlink("UNOSAT_GazaStrip_CDA_06July2024.gdb", recursive = TRUE) 
