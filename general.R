# Folder for PEST executables
dir.PEST <- "C:\\pest;C:\\pest\\swutils"
# add PEST folder to system path
Sys.setenv(PATH=paste(Sys.getenv("PATH"),dir.PEST,sep=";"))
# folder for pest application
dir.app <- "M:\\Models\\Bacteria\\HSPF\\HydroCal201506\\R_projs\\Check_upd_wdm_hyd;M:\\Models\\Bacteria\\HSPF\\HydroCal201506\\R_projs\\Check_upd_wdm_hyd\\model"
Sys.setenv(PATH=paste(Sys.getenv("PATH"),dir.app,sep=";"))

