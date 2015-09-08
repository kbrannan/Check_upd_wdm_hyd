# Folder for PEST executables
dir.PEST <- "C:\\pest;C:\\pest\\swutils"

# add PEST folder to system path
Sys.setenv(PATH=paste(Sys.getenv("PATH"),dir.PEST,sep=";"))

# folder for pest application
dir.app <- "M:\\Models\\Bacteria\\HSPF\\HydroCal201506\\R_projs\\Check_upd_wdm_hyd;M:\\Models\\Bacteria\\HSPF\\HydroCal201506\\R_projs\\Check_upd_wdm_hyd\\model"
Sys.setenv(PATH=paste(Sys.getenv("PATH"),dir.app,sep=";"))

# get uci file
str.uci <- scan(file=paste0(getwd(),"/model/bigelk.uci"),what="character",sep="\n")
num.WDM2 <- grep("^WDM2       26",str.uci)

# set the meterorological input file for original
str.org.wdm <- "bigelk_in.wdm"
str.uci[num.WDM2] <- gsub("bigelk.*\\.wdm$",str.org.wdm,str.uci[num.WDM2])
cat(str.uci,file=paste0(getwd(),"/model/bigelk.uci"),sep="\n")

# run pest and make copy of output
shell(cmd=paste0("cscript ",getwd(),"/run_control/RunPEST.vbs"))
shell(cmd=paste0("copy ",getwd(),"/model/model.out ",getwd(),"/model/model_org.out"))

# set the meterorological input file for original
str.upd.wdm <- "bigelkwqupdt.wdm"
str.uci[num.WDM2] <- gsub("bigelk.*\\.wdm$",str.upd.wdm,str.uci[num.WDM2])
cat(str.uci,file=paste0(getwd(),"/model/bigelk.uci"),sep="\n")


