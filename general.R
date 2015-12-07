# get functions
source(file="read_model_out_func.R")
source(file="read_model_out_table_func.R")

# Folder for PEST executables
dir.PEST <- "C:\\pest;C:\\pest\\swutils"

# add PEST folder to system path
Sys.setenv(PATH=paste(Sys.getenv("PATH"),dir.PEST,sep=";"))

# folder for pest application
dir.app <- "M:\\Models\\Bacteria\\HSPF\\HydroCal201506\\R_projs
              \\Check_upd_wdm_hyd;
            M:\\Models\\Bacteria\\HSPF\\HydroCal201506\\R_projs
                \\Check_upd_wdm_hyd\\model"
Sys.setenv(PATH=paste(Sys.getenv("PATH"),dir.app,sep=";"))

# get uci file
str.uci <- scan(file=paste0(getwd(),"/model/bigelk.uci"),what="character",
                sep="\n")
num.WDM2 <- grep("^WDM2       26",str.uci)

# set the meterorological input file for original
str.org.wdm <- "bigelk_in.wdm"
str.uci[num.WDM2] <- gsub("bigelk.*\\.wdm$",str.org.wdm,str.uci[num.WDM2])
cat(str.uci,file=paste0(getwd(),"/model/bigelk.uci"),sep="\n")

# run pest and make copy of output
shell(cmd=paste0("cscript.exe //nologo ",getwd(),"/run_control/RunPEST.vbs"))
file.copy(from=paste0(getwd(),"/model/model.out"),
          to=paste0(getwd(),"/model/model_org.out"),
          overwrite=TRUE)

# get data and info for model_org.out file
lst.out.org <- modelout(str.file=paste0(getwd(),"/model/model_org.out"))

# create output data.frame
df.out.org <- do.call(rbind,lapply(1:(length(lst.out.org$df.info$name)-1),
                                 modelout_table,lst.in=lst.out.org))

# set the meterorological input file for original
str.upd.wdm <- "bigelkwqupdt.wdm"
str.uci[num.WDM2] <- gsub("bigelk.*\\.wdm$",str.upd.wdm,str.uci[num.WDM2])
cat(str.uci,file=paste0(getwd(),"/model/bigelk.uci"),sep="\n")

# run pest and make copy of output
shell(cmd=paste0("cscript.exe //nologo ",getwd(),"/run_control/RunPEST.vbs"))
file.copy(from=paste0(getwd(),"/model/model.out"),
          to=paste0(getwd(),"/model/model_upd.out"))

# get data and info for model_upd.out file
lst.out.upd <- modelout(str.file=paste0(getwd(),"/model/model_upd.out"))

# create output data.frame
df.out.upd <- do.call(rbind,lapply(1:(length(lst.out.upd$df.info$name)-1),
                             modelout_table,lst.in=lst.out.upd))

# quick compare of output data.frames
summary((df.out.org == df.out.upd))

