Dim arrFolder(), arrFiles(), intSize

' pass control file as a command line argument
' Note use full path name including machine name for control file
strCtlFile = Wscript.Arguments(0)

' read control file
' function readControlFile
Set dctRunInfo = readControlFile(strCtlFile)
' get keys from run info dictionary
aryKeys = dctRunInfo.keys()
' get PEST control file
strPESTfile = dctRunInfo("PEST_control_file")
WScript.Echo "Pest control fie is: " & strPESTFile & vbCrLf
' get source folder as file system object
strSPath = dctRunInfo("Host_folder")
strJunk = Split(strSPath,"c$") ' get R path for Source
strSMch = RTrim(LTrim(Replace(strJunk(0),"\",""))) ' machine name		
strSRDir = "c:" & dctRunInfo("Host_R_folder")
WScript.Echo "Source path of run files is: " & strSPath & vbCrLf
intStartHost = StartHostPEST(strSPath,strPESTfile)
On Error Resume Next
' loop for each client
For intC = 1 To dctRunInfo("N_Clients")
	ReDim arrFolders(0)
	ReDim arrFiles(0)
	intSize = 0
	strTPath = dctRunInfo("Client_"& CStr(intC) & "_folder")
	strTRDir = "c:" & dctRunInfo("Client_"& CStr(intC) & "_R_folder")
	strJunk = Split(strTPath,"c$")
	strMch = Replace(strJunk(0),"\","") ' machine name
	WScript.Echo "Processing files for Client: " & strMch
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	' get rid of previous run
	If objFSO.FolderExists(strTPath) = True Then 
		objFSO.DeleteFolder strTPath, True
	End If
	' create folder for current run
	objFSO.CreateFolder(strTPath)
	' copy folders and files from host to client
	objFSO.CopyFolder strSPath & "\*.*", strTPath, True
	objFSO.CopyFile   strSPath & "\*.*", strTPath, True
	' clear FSO
	Set objFSO = Nothing
	' change paths on clients for local enviroment
	rep_junk = repAllPaths(strSPath, strTPath, strSRDir, strTRDir)
	' start beopest on client
	lngClient = StartClientPEST(strTPath,strPESTfile)
	' spacer line
	WScript.Echo vbCrLf
Next
On Error Goto 0

' start beopest on host (have a pest running window and a pest stop window


WScript.Quit

''''''''''''''''''''''''''''''Functions and Procedures''''''''''''''''''''''''
Function readControlFile(strCnt)
' reads the run control file for the beopest setup
' and returns a dictionary object contatining the PEST
' control file name, source folder/host, and client folders
' the machine names along with the folders where "rscript.exe" 
' is located on the host and each of the clients are 
' included in all of the folder names
	Dim objFSO, strRunInfo, lstRunInfo, dctRunInfo, arrLine, intClient
	' run control file
	'strCnt = "\\wq100255-kbrann.deq.state.or.us\C$\temp\pest\bigelkpest\case00control.txt"
	' create generic FileSystemmObject
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	' read run control file
	Set objFile = objFSO.GetFile(strCNT).OpenAsTextStream
	strRunInfo = objFile.ReadAll
	objFile.Close
	' create array where each element is a line from the control file
	lstRunInfo = Filter(Split(strRunInfo,vbCrLf),":")
	' create dictionary
	Set dctRunInfo = CreateObject("Scripting.Dictionary")
	' start loop to populate dictonary with run info
	intClient = 0
	For Each item In lstRunInfo
		arrLine = Split(item,":",-1,1)
		If UBound(arrLine) >= 1 Then
			strCur = arrLine(0)
			Select Case strCur
				Case "PEST control file"
					dctRunInfo.Add Replace(arrLine(0)," ","_"), RTrim(LTrim(LCase(arrLine(1))))
				Case "Host"
					dctRunInfo.Add "Host_folder", RTrim(LTrim(LCase(arrLine(1))))
					dctRunInfo.Add "Host_R_folder", RTrim(LTrim(LCase(arrLine(2))))
				Case "Client"
					intClient = intClient + 1
					dctRunInfo.Add "Client_"& CStr(intClient) & "_folder", RTrim(LTrim(LCase(arrLine(1))))
					dctRunInfo.Add "Client_"& CStr(intClient) & "_R_folder", RTrim(LTrim(LCase(arrLine(2))))					
			End Select
		End If
	Next
	dctRunInfo.Add "N_Clients",intClient
	' return the run info
	Set readControlFile = dctRunInfo
End Function

Function repAllPaths(strSPath,strTPath,strSRDir,strTRDir)
' replaces all occurances of source paths with target specfic paths
' file "filescopied.csv" from copySrc2Tar and getFiles functions is used 
' by this function
' The paths are:
'	strSPath is the path where the source files are
'	strTPath is the path where the source files are to be copied to
'	strSRDir is the path where R is location on the source machine
'	strTRDir is the path where R is location on the target machine
' Note: this function calls the getExt and repPath functions
	'create array
	Dim intSize, arrFolders, arrFiles 
	intSize = 1
	arrFolders = Array(strTPath)
	strTemp = strTPath
	' get list of files that were copied to client
'	GetSubFolders strTPath, intSize, arrFolders
	GetSubFolders strTemp
	arrFiles = GetListFiles(arrFolders) ' get a list of the files copied to client
	' create local paths for source and client machines
	junk = Split(LCase(strSPath),"c$")
	strSDir = "c:" & junk(1)
	junk = Split(LCase(strTPath),"c$")
	strTDir = "c:" & junk(1)
	
	' replace paths where needed
	For Each iLine In arrFiles
		strExt = getExt(iLine)
		If Not (LCase(strExt) = "wdm") And Not (LCase(strExt) = "exe") And Not (LCase(strExt) = "rdata") And Not (LCase(strExt) = "csv") Then
			junk = repPath(strSDir,strTDir,iLine)
			junk = repPath(strSRDir,strTRDir,iLine)
		End If 
		strExt = ""
	Next
	' dummy respnse
	repAllPaths = "done"
End Function

Function getExt(strFile)
' gets the extention of the strFile
    junk = Split(strFile, "\")
    morejunk = Split(junk(UBound(junk)),".")
    getExt = morejunk(UBound(morejunk))
End Function

Function repPath(strSrcDir,strTarDir,strFile)
' replaces all occurances of source paths with target specfic paths
' in strFile (this valiable needs the complete path of the file including machine name)
' The paths are:
'	strSrcDir is the path where the source files are
'	strTarDir is the path where the source files are to be copied to
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.GetFile(strFile)
	If Right(strSrcDir,1) = "\" Then strSrcDir = Left(strSrcDir,Len(strSrcDir)-1)
	If Right(strTarDir,1) = "\" Then strTarDir = Left(strTarDir,Len(strTarDir)-1)
	If objFile.size > 0 Then
		junk = LCase(objFile.Name)
		Set fileCur = objFile.OpenAsTextStream(1, 0)
		strOrg = fileCur.ReadAll
		fileCur.Close
		' use R folder seperators
		strSrcDirR = Replace(strSrcDir,"\","/",1)
		strTarDirR = Replace(strTarDir,"\","/",1)
		' make all paths lower case
		strOrg = Replace(strOrg,strSrcDir,LCase(strSrcDir),1,-1,1)
		strOrg = Replace(strOrg,strSrcDirR,LCase(strSrcDirR),1,-1,1)
		' replace source path with client path
		strSrcDir = LCase(strSrcDir)
		strTarDir = LCase(strTarDir)
		strNew = Replace(strOrg,strSrcDir,strTarDir,1)
		strNew = Replace(strNew,strSrcDirR,strTarDirR,1)
		If strNew <> strOrg Then 
			Set fileCur = objFile.OpenAsTextStream(2, 0)
			fileCur.Write strNew
			fileCur.Close
		End If
		strOrg = ""
		strNew = ""
	End If
	' dummy response
	repPath = "done"
End Function

'Sub GetSubFolders(byval strFolderName,byref intSize, byref arrFolders)
Sub GetSubFolders(strFolderName)
' gets list of paths for all of the sub-folders and sub-sub-folders and
' sub-sub-sub-...folders in strFolderName. This is done recussively,
' so, this procedure calls itself
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set colSubfolders2 = objFSO.GetFolder(strFolderName)
	If colSubfolders2.SubFolders.Count > 0 Then
	    For Each objFolder2 in colSubfolders2.SubFolders
	        strFolderName = objFolder2.Path
	        ReDim Preserve arrFolders(intSize)
	        arrFolders(intSize) = strFolderName
	        intSize = intSize + 1
	        'GetSubFolders strFolderName, intSize, arrFolders
	        GetSubFolders(strFolderName)
	    Next
    End If
End Sub

Function GetListFiles(arrFolders)
' this function gets the paths of all of the files in each of the paths
' list in arrFolders. Use procedures "GetSubFolders" to get the input 
' array for this function
	Dim intSize, arrFiles()
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	For Each strFolder In arrFolders
		Set objFolder = objFSO.GetFolder(strFolder)
		If objFolder.Files.Count > 0 Then
			For Each objFile In objFolder.Files
				ReDim Preserve arrFiles(intSize)
				arrFiles(intSize) = objFile.Path
				intSize = intSize + 1
			Next
		End If 
	Next
	GetListFiles = arrFiles
End Function

Function StartHostPEST(strCurPath, strPESTFile)

	strJunk = Split(LCase(strCurPath),"c$") ' get R path for Source
	strCurDir = "C:" & strJunk(1)
	On Error Resume Next
	Set objPESTStop = WScript.CreateObject ("WScript.shell")
	Return = objPESTStop.run ("cmd /K title PEST Stop Window & cd " & strCurDir,7,FALSE)
	Set objPESTStop = Nothing
	
	Set objPESTCommand = WScript.CreateObject ("WScript.shell")
	Return = objPESTCommand.run ("cmd /K title BeoPEST Command Window & cd " & strCurDir & " & beopest32 " & strPESTFile & " /H :4004",1,False)
	Set objPESTCommand = Nothing
	
	StartHostPEST = Err.Number
	On Error Goto 0
End Function

Function StartClientPEST(strPath, strPESTFile)
    Const MIN_WINDOW = 7
	strJunk = Split(LCase(strPath),"c$")
	strMch = Replace(strJunk(0),"\","")
	strDir = "c:" & strJunk(1)
	strBatFile = "RunClient.bat"
	
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set flRunSlave = objFSO.CreateTextFile(strPath & "\" & strBatFile, True)
	flRunSlave.WriteLine("beopest32 " & strPESTFile & " /H WQ100255-KBRANN:4004")
	flRunSlave.Close
	
	Set objWMIService = getobject("winmgmts://"& strMch & "/root/cimv2")

	Set objStartup = objWMIService.Get("Win32_ProcessStartup")
	Set objConfig = objStartup.SpawnInstance_
	objConfig.ShowWindow = MIN_WINDOW
	
	Set objProcess = objWMIService.Get("Win32_Process")
	strCMD = "cmd /K cd " & strDir & " & " & strBatFile & " & exit"
	lngReturn = objProcess.Create(strCMD, strDIR, null, objConfig, intPID)

	If lngReturn = 0 Then
	    Wscript.Echo "Client " & strPath & " started. PID: " & intPID
	Else
	    Wscript.Echo "Fail Client " & strPath & vbcrlf & "Error: " & lngReturn
	    StartClientPEST = lngReturn
	End If
End Function
