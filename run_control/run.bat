REM clean up directory from previous runs
"C:\Program Files\R\R-3.0.1\bin\x64\Rscript.exe" --vanilla C:\Temp\PEST\BigElkPEST\rprojs\general_pest\delete_files_clean.R
REM run beopest and start clients
cscript runbeopest.vbs c:\temp\pest\bigelkpest\casecontrol.txt 