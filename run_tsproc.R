# had to modify tsproc.bat from how Cadmus had it set up. 
# this doest not work from R: tsproc.exe < tsproc.in > null
# for some reason the redirect for input "<" would not work
# I used the commands:
# cd M:\Models\Bacteria\HSPF\HydroCal201506\R_projs ...
#       \Check_upd_wdm_hyd\model
# type tsproc.in | tsproc.exe
# the pipe "|" of the output from "type" to tsproc.exe works
shell(cmd="tsproc.bat")