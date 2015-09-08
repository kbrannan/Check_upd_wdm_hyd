
strCur = "M:\Models\Bacteria\HSPF\HydroCal201506\R_projs\Check_upd_wdm_hyd\model"
strPEST = "control.pst"

num_err = StartHostPEST(strCur,strPEST) 



WScript.Quit



Function StartHostPEST(strCurPath, strPESTFile)

'	strJunk = Split(LCase(strCurPath),"c$") ' get R path for Source
'	strCurDir = "C:" & strJunk(1)
    strCurDir = strCurPath
	On Error Resume Next
	Set objPESTStop = WScript.CreateObject ("WScript.shell")
	Return = objPESTStop.run ("cmd /K title PEST Stop Window & pushd " & strCurDir,7,FALSE)
	Set objPESTStop = Nothing
	
	Set objPESTCommand = WScript.CreateObject ("WScript.shell")
	Return = objPESTCommand.run ("cmd /K title PEST Command Window & pushd " & strCurDir & " & c:\pest\pest.exe " & strPESTFile,1,FALSE)
	Set objPESTCommand = Nothing
	
	StartHostPEST = Err.Number
	On Error Goto 0
End Function
