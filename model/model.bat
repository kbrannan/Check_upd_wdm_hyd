@echo off
cd M:\Models\Bacteria\HSPF\HydroCal201506\R_projs\Check_upd_wdm_hyd\model
C:\PEST\par2par.exe p2p_bigelk.dat > nul
C:\BASINS41\models\HSPF\bin\WinHspfLt.exe -1 -1 bigelk.uci
C:\PEST\swutils\tsproc.exe < tsproc.in > null
