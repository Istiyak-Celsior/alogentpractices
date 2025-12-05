<%    
	Dim fsoLog
    Set fsoLog = CreateObject("Scripting.FileSystemObject")
    
	' NOTE: Set debugFlag to 'true' to create a debug log file for audit.
	' This should be reset to false when done debugging.
	'
    Dim debugLog, debugFlag
	debugFlag = false
	
	if debugFlag then
		if Not fsoLog.FolderExists(Session("serverPath") & "logs") then
			fsoLog.CreateFolder(Session("serverPath") & "logs")
		end if
		
		' Creates/appends to existing file in ASCII mode
		'
    	Set debugLog = fsoLog.OpenTextFile( Session("serverPath") & "logs\debuglog.txt", 8, true, 0)
    end if
	
	' Array of log start (Ta), End (Tb) and Delta (Tdelta) holders
	'
	Dim logTa(10), logTb(10), logTdelta(10), logTlabel(10)
	
	
	function calculateDelta( timeStart, timeEnd)
		dim result
		'result = (timeEnd-timeStart) * 1000
		result = DateDiff("s", timeStart, timeEnd)
		calculateDelta = result
	end function
	
	sub writeDebugLog(str)
		if debugFlag then
			debugLog.writeLine str
			'debugLog.flush
		end if
	end sub	
%>

