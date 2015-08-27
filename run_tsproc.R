
shell.exec(cat("tsproc ",getwd(),"/model/trproc.dat", "\n n \n n"))
Sys.getenv("PATH")
shell("tsproc")
shell("pest")

shell(cmd=paste0(getwd(),"/model/model.bat"), shell="cmd", translate=TRUE)

shell.exec(paste0(getwd(),"/model/model.bat"))

shell(cmd="model.bat",shell="cmd")

shell(cmd=paste0(getwd(),"/model/tsproc.bat > NULL"))

getwd()

shell(cmd="cmd /c M:\Models\Bacteria\HSPF\HydroCal201506\R_projs\Check_upd_wdm_hyd\model\\\model.bat")

shell.exec("tsproc.exe")

shell(cmd=paste0("tsproc.exe ", paste0(getwd(),"/model/tsproc.dat")," n n"))

shell(cmd="tsproc.bat")
shell(cmd="path")
