
ur = "Administrator"
pw = "VgDmc(5G!P"

strMch = "AWS-PEST00"


'Wscript.StdOut.Write "Please enter your user name:"
'strUser = Wscript.StdIn.ReadLine 
'Set objPassword = CreateObject("ScriptPW.Password")
'Wscript.StdOut.Write "Please enter your password:"
'strPassword = objPassword.GetPassword()



junk = StartPESTAWS(strMch,pw,ur)

Function StartPESTAWS(strMch,wp,ru)
    Const MIN_WINDOW = 7
	strDir = "c:\temp\pest\bigelkpest\host"
	
	Set objSWbemLocator = CreateObject("WbemScripting.SWbemLocator") 
    Set objWMIService = objSWbemLocator.ConnectServer(strMch, "root\cimv2", ru, wp)
	
	'Set objWMIService = getobject("winmgmts://"& strMch & "/root/cimv2", ru, wp)

	Set objStartup = objWMIService.Get("Win32_ProcessStartup")
	Set objConfig = objStartup.SpawnInstance_
	objConfig.ShowWindow = MIN_WINDOW
	
	Set objProcess = objWMIService.Get("Win32_Process")
	strCMD = "cmd /K cd " & strDir & " & " & "pest bigelkwq.pst" & " & exit"
	lngReturn = objProcess.Create(strCMD, strDIR, null, objConfig, intPID)

	If lngReturn = 0 Then
	    Wscript.Echo "Client " & strPath & " started. PID: " & intPID
	Else
	    Wscript.Echo "Fail Client " & strPath & vbcrlf & "Error: " & lngReturn
	    StartClientPEST = lngReturn
	End If
End Function

