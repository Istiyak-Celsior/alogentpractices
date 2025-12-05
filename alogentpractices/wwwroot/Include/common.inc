<!-- #include file="AuditFunctions.asp" -->
<%
Class ErrorNotification
    Private errNo
    Private errDescr

    Public Property Get ErrorNumber()
        ErrorNumber = errNo
    End Property

    Public Property Let ErrorNumber(value)
        errNo = value
    End Property

    Public Property Get ErrorDescription()
        ErrorDescription = errDescr
    End Property

    Public Property Let ErrorDescription(value)
        errDescr = value
    End Property
End Class


SUB ExecuteCommand(sql, timeout)
    Dim command : Set command = Server.CreateObject("ADODB.Command")

    command.activeConnection = db
    command.commandType = adCmdText
    command.commandText = sql
    command.commandTimeout = timeout
    command.execute

    Set command = Nothing
END SUB


FUNCTION MailMessage(from, recipients, subject, body)
	Dim httpRequest, url, data
	
	SET httpRequest = Server.CreateObject("WinHttp.WinHttpRequest.5.1")

	url = Session("acculoan.serverURL") & "/mail/message"

	data		= "{" & _
				  "	""From"": """ & from & """," & _
				  " ""Recipients"": " & recipients & "," & _
				  " ""Subject"": """ & Replace(subject, """", "\""") & """," & _
				  " ""Body"": """ & Replace(body, """", "\""") & """" & _
				  "}"

	On Error Resume Next
	WITH httpRequest
		Call .Open("POST", url, False)
		Call .SetRequestHeader("Content-Type", "application/json")
		Call .SetAutoLogonPolicy(0)
		Call .Send(data)
	END WITH

	SET MailMessage = httpRequest
END FUNCTION

FUNCTION MailDocument(from, recipients, subject, body, documentId)
	Dim httpRequest, url, data
	
	SET httpRequest = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
	
	url  = Session("acculoan.serverURL") & "/document(" & FormatGuid(documentId) & ")/mail"
	data = BuildXMLMailMessage(from, recipients, subject, body)

	On Error Resume Next
	WITH httpRequest
		Call .Open("POST", url, False)
		Call .SetRequestHeader("Content-Type", "application/xml")
		Call .SetRequestHeader("Accept", "application/xml")
		Call .SetAutoLogonPolicy(0)
		Call .Send(data)
	END WITH

	SET MailDocument = httpRequest
END FUNCTION

FUNCTION BuildXMLMailMessage(from, recipients, subject, body)
	Dim message

	message =	"<MailRequest>" & _
				"	<From>" & from & "</From>" & _
				BuildXMLRecipientList(recipients) & _
				"   <Subject>" & subject & "</Subject>" & _
				"   <Body>" & StringToHtmlString(body) & "</Body>" & _
				"</MailRequest>"

	BuildXMLMailMessage = message
END FUNCTION

FUNCTION BuildXMLRecipientList(sendTo)
	Dim i
	Dim formattedList : formattedList = ""
	Dim adjustedList  : adjustedList  = Replace(sendTo, ",", ";")

	adjustedList = Split(adjustedList, ";")

	FOR i = lBound(adjustedList) TO uBound(adjustedList) 
		IF formattedList = "" THEN
			formattedList = "<string>" & adjustedList(i) & "</string>"
		ELSE
			formattedList = formattedList & "<string>" & adjustedList(i) & "</string>"
		END IF
	NEXT

	BuildXMLRecipientList = "<Recipients>" & formattedList & "</Recipients>"
END FUNCTION

FUNCTION BuildRecipientList( sendTo)
	Dim i
	Dim formattedList : formattedList = ""
	Dim adjustedList  : adjustedList  = Replace(sendTo, ",", ";")

	adjustedList = Split(adjustedList, ";")

	FOR i = lBound(adjustedList) TO uBound(adjustedList) 
		IF formattedList = "" THEN
			formattedList = """" & adjustedList(i) & """"
		ELSE
			formattedList = formattedList & ", """ & adjustedList(i) & """"
		END IF
	NEXT

	BuildRecipientList = "[" & formattedList & "]"
END FUNCTION

    Function IsEmptyArray(arr)
        Dim isempty : isempty = false

        On Error Resume Next
        Dim arraySize : arraySize = UBound(arr)
        
        If Err.Number <> 0 Then
            isempty = true
        End If 

        On Error Goto 0

        IsEmptyArray = isempty
    End Function ' IsEmptyArray

	Function IsDuplicateBarcodeKey(keyValue)
		Dim result : result = false
		Dim barcodeQuery, barcodeRS
		Set barcodeRS = Server.CreateObject("ADODB.RecordSet")
		
		barcodeQuery = "SELECT COUNT(*) AS cnt FROM documentDefinitions WHERE barcodeKey = " & keyValue
		barcodeRS.Open barcodeQuery, db, adOpenStatic, adCmdText
		
		if barcodeRS("cnt") > 0 then
			result = true
		end if
		
		barcodeRS.Close
		
		IsDuplicateBarcodeKey = result
	End Function

	
	' Function to put double quotes around a string to avoid having to write escape
	' syntax constantly.
	'
	Function GetQuotedString(value)
		GetQuotedString = Chr(34) & value & Chr(34)
	End Function
	
	Function EmptyRecordSetArray()
		Dim a(0,0)
		EmptyRecordSetArray = a
	End Function
	
	Function FormatFileSize(size)
		Dim result, label
		result = "Unknown"
		
		if IsNumeric(size) then
			label = "Kb"
			if size >= 100 then
				size = size / 1000.0
				label = "Mb"
				
				if size >= 100 then
					size = size / 1000.0
					label = "Gb"
				end if
			end if
			
			result = FormatNumber(size,2) & " " & label
		end if
		
		FormatFileSize = result
	End Function 'FormatFileSize()
	
	Function FormatFilenameTimestamp(timestamp)
		Dim result
	
		result = Replace(timestamp, " ", "_")
		result = Replace(result, "/", "-")
		result = Replace(result, ":", "-")
	
		FormatFilenameTimestamp = result
	End Function ' FormatFilenameTimestamp()
	
	Function GetCurrentUploadDirectory(requestArg)
		Dim uploadDir
		uploadDir = ""
		
		' Check to see if uploadDir is a requested argument
		'
		if requestArg <> "" then
			uploadDir = Request(requestArg)
		end if
		
		' Check for blank request value
		'
		if uploadDir = "" then
			' If request arg is blank then check session
			'
			uploadDir = Session("currentUploadDir")
		end if
		
		' Check for blank session value
		'
		if uploadDir = "" then
			' If session is blank then check cookie
			'
			uploadDir = Request.Cookies("acculoan.uploadDir")
		end if
		
		' Check for blank cookie value or root folder
		'
		if uploadDir = "" or Trim(uploadDir) = "\" then
			' If cookie blank then use default
			'
			uploadDir = RemoveTrailingSlash(Session("uploadPath"))
			uploadDir = "\" & uploadDir & "\" & Session("userLogin")
		end if
		
		GetCurrentUploadDirectory = uploadDir
	End Function ' GetCurrentUploadDirectory()

	Function SetCurrentUploadDirectory(directory)
	    Session("currentUploadDir") = directory
		Response.Cookies("acculoan.uploadDir") = directory
		Response.Cookies("acculoan.uploadDir").expires = DateSerial(Year(Date), Month(Date)+1, Day(Date))
	End Function
	
	Function GetDataTypeLabel(dataTypeName)
		Dim result
		
		if dataTypeName = "bit" then
			result = "Boolean"
		elseif dataTypeName = "decimal" then
			result = "Decimal"
		elseif dataTypeName = "int" then
			result = "Integer"
		elseif dataTypeName = "datetime" then
			result = "Date/Time"
		elseif dataTypeName = "varchar" then
			result = "Text"
		elseif dataTypeName = "money" then
			result = "Currency"
		elseif dataTypeName = "choice" then
			result = "Choice List"
		end if
		
		GetDataTypeLabel = result
	End Function
	
	
	'---------------------------------------------------------------------
	' File and Folder manipulation functions
	' 
	' These functions assume that folder paths have been normalized to use
	' backslashes.
	'
	
	' Create a global FileSystemObject for use
    Dim g_fso
    Set g_fso = CreateObject("Scripting.FileSystemObject")
	
	FUNCTION IsFolderBlocked(path)
        On Error Resume Next

        Dim mapPath			: mapPath = Server.MapPath("Scanned_Images\" & path)
        Dim newMapPath		: newMapPath = mapPath & "-renamed"
        Dim changeTypeError : changeTypeError = false

		IF g_fso.FolderExists(mapPath) THEN
			g_fso.MoveFolder mapPath, newMapPath

			IF Err.number <> 0 THEN
				changeTypeError = true          
			END IF

			' Change folder back if there was no IO blocks
			IF NOT changeTypeError THEN
				g_fso.MoveFolder newMapPath,  mapPath
			END if

			' Turn error handling back on
			On Error Goto 0
		ELSE
			changeTypeError = false
		END if

		IsFolderBlocked = changeTypeError
	End FUNCTION

	Sub EnsureFolderExists(path)
		if Not g_fso.FolderExists(path) then
			g_fso.CreateFolder(path)
		end if
	End Sub
	
	Function TrimLeadingSlash(path)
		Dim result
		
		result = path
		if Left(result,1) = "\" Or Left(result,1) = "/" then
			result = Right(result, Len(result)-1)
		end if
		
		TrimLeadingSlash = result
	End Function
	
	Function TrimTrailingSlash(path)
		Dim result
		result = path
		if Right(result, 1) = "\" Or Right(result, 1) = "/" then
			result = Left(result, Len(result) - 1)
		end if
		TrimTrailingSlash = result
	End Function ' TrimTrailingSlash
	
	Function BuildFolderPath(rootPath, filePath)
		Dim result, checkFolder
		
		' Check root folder for existence and create if necessary
		'
		checkFolder = TrimTrailingSlash(rootPath)
		if Not g_fso.FolderExists(checkFolder) then
			g_fso.CreateFolder(checkFolder)
		end if
		
		' Check the folders of the filePath for existence and create if neccessary
		'
		Dim folders, folder
		folders = Split(TrimLeadingSlash(TrimTrailingSlash(filePath)), "\")
		for each folder in folders
			checkFolder = checkFolder & "\" & folder
			
			if Not g_fso.FolderExists(checkFolder) then
				g_fso.CreateFolder(checkFolder)
			end if
		next
		
		' Check for folder existance in case error occurred in building the path
		'
		result = g_fso.FolderExists(rootPath & filePath)
		BuildFolderPath = result
	End Function
	
	Function GetFilePath(fullPath)
		Dim result
		result = Left(fullPath, InStrRev(fullPath, "\") - 1)
		GetFilePath = result
	End Function
	
	Function IsGuid(id)
		' NOTE: this only does a simple test against the character count, including
		' dashes, but minus the curly braces.
		'
		Dim result, str
		str = id
		str = Replace(str, "{", "")
		str = Replace(str, "}", "")
		
		result = false
		if Len(str) = 36 then
			result = true
		end if
		
		IsGuid = result
	End Function ' IsGuid()
	
	' Formats a GUID values so that there is no curly braces and is upper case.
	FUNCTION FormatGuid(id)
		Dim result : result = LCase(id)
		result = RemoveCurlyBrackets(result)

		FormatGuid = result
	END FUNCTION

	Function GetPaddedCollateralSequence(sequenceNumber)
		IF Trim(sequenceNumber & "") = "" THEN EXIT FUNCTION
		Dim paddedCollateralSequence, padSize, padding
		Dim x
		
		If IsNumeric(Session("accuaccount.collateralPadSize")) then
			padSize = CInt(Session("accuaccount.collateralPadSize"))
		else
			padSize = 0
		end if
		
		if padSize > 0 and len(CStr(sequencenumber)) < padsize then
			' build a string of zeroes equal to the pad size
			'
			padding = ""
			for x = 1 to padSize
				padding = padding & "0"
			next
			
			' pad the collateral sequence with zeroes and then take a number
			' of characters from the right equal to the pad size
			'
			paddedCollateralSequence = padding & CStr(sequenceNumber)
			paddedCollateralSequence = Right(paddedCollateralSequence, padSize)
		else
			paddedCollateralSequence = CStr(sequenceNumber)
		end if
		
		GetPaddedCollateralSequence = paddedCollateralSequence
	End Function
	
	'
	' Utility function that returns a boolean value as to whether a given folder
	' and its children contain any files. NOTE: A valid file for this purpose
	' does not include the following extensions:
	'	.db (for thumbs.db instances)
	'	.xml (due to aquaforest trails)
	'	.~psfldr (due to synchronization files left behind at Nodaway)
	'
	Function FolderContainsFiles(fso, folder)
		Dim hasFiles
		hasFiles = false
		
		if fso.FolderExists(folder) then
			Dim objFolder, objFile, subFolder
			Set objFolder = fso.GetFolder(folder)
			
			for each subFolder in objFolder.SubFolders
				hasFiles = FolderContainsFiles(fso, subFolder)
				
				' short circuit loop as we found a file.
				'
				if hasFiles then
					exit for
				end if
			next
			
			' Only check for files if none found yet.
			'
			if Not hasFiles then 
				for each objFile in objFolder.Files
					Dim filename, extension
					filename = Right(objFile.Path, (Len(objFile.Path) - InStrRev(objFile.Path, "\") + 1))
					extension = LCase(GetFileExtension(filename))
					
					' If the folder contains any file other than an .xml, .db, or .~psfldr then
					' flag the folder as having files and exit loop.
					'
					if Not (extension = ".xml" Or extension = ".db" Or extension = ".~psfldr") then
						hasFiles = true
						exit for
					end if
					
				next
			end if
		end if
		
		FolderContainsFiles = hasFiles
	End Function

	'
	' Utility function to get the userId associated with a officerId from
	' the user table.
	'
	' Arguments
	' ---------
	' officerId = The officerId to lookup
	'
	' Returns
	' -------
	' userId that corresponds to the associated officerId in the
	' user table. If the officerId is not in the user table then
	' an empty string is returned.
	'
	Function GetUserIdByOfficerId(officerId)
		Dim uid
		uid = ""
		
		Dim userQuery, userRS
		Set userRS = Server.CreateObject("ADODB.RecordSet")
		
		userQuery = "SELECT userId FROM [user] WHERE loanOfficerId=" & dbFormatId(officerId)
		response.write "userQuery = " & userQuery & "<br><br>"
		userRS.Open userQuery, db, adOpenStatic, adCmdText
		
		if Not userRS.eof then
			uid = CheckForNull(userRS("userId"))
		end if
		
		userRS.Close
		
		GetUserIdByOfficerId = uid
	End Function
	
	Function GetActionTimerStatus( timeStart, timeEnd)
		Dim result
		
		result = 0	' Inactive Timer - no valid dates to calculate with
		
		' if the start time is valid but not the end time
		' then the timer is active and running, otherwise
		' return 0
		'
		if IsDate(timeStart) And Not IsDate(timeEnd) then
			result = 1	' Active Timer
		elseif IsDate(timeStart) And IsDate(timeEnd) then
			result = 2	' Stopped Timer
		end if
		
		GetActionTimerStatus = result
	End Function
	
 		
	FUNCTION GetActionTimerDays(d1, d2, countBusinessDays)
		Dim strDateOut : strDateOut = ""
		' ### Check for Valid Dates ###
		IF NOT (isDate(d1) AND isDate(d2)) THEN
			Response.Write "At least one date is invalid." 
			EXIT FUNCTION
		ELSE
			d1 = cDate(d1) : d2 = cDate(d2)
			IF d1 > d2 THEN
				EXIT FUNCTION
			END IF
		END IF
		
		IF cBool(countBusinessDays) THEN
			strDateOut = (CalculateBusinessDaysBetweenTwoDates(d1, d2) + 1)
		ELSE
			strDateOut = (DateDiff("d", d1, d2) + 1)
		END IF
		GetActionTimerDays = strDateOut
	END FUNCTION
	
' ----------------------------------------------------------------
' CalculateBusinessDaysBetweenTwoDates - Calculates the number of
' business days between to dates.
' Added: NOV|23|2015 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION CalculateBusinessDaysBetweenTwoDates(nStartDate, nEndDate)
	Dim dtCur
	Dim nBDays : nBDays = -1
	FOR dtCur = nStartDate TO nEndDate
		SELECT CASE Weekday(dtCur)
			CASE vbSunday, vbSaturday
			CASE ELSE
				nBDays = nBDays + 1
		END SELECT
	NEXT
	CalculateBusinessDaysBetweenTwoDates = nBDays
END FUNCTION
	
	function ParseHtmlPage(theUrl)
		dim webPage
		webPage = theUrl
		
		' Strip any arguments if any
		'
		if InStr(webPage, "?") then
			webPage = Left(webPage, InStr(webPage,"?"))
		end if
		
		' Remove the Site and path information
		'
		webPage = Right(webPage, Len(webPage)-InStrRev(webPage,"/"))
		
		ParseHtmlPage = webPage
	end function
	
	'-------------------------------------------------------------------------
	'	FUNCTION: RemoveTrailingSlash( path)
	'	Utility function removes trailing slashes (forward or back) from
	'	given path.
	'-------------------------------------------------------------------------
	function RemoveTrailingSlash(path)
		Dim newPath
		newPath = path
		
		' Check last character for forward/back slash and remove it.
		'
		if inStrRev(newPath, "/") = Len(newPath) Or inStrRev(newPath, "\") = Len(newPath) then
			newPath = Left(newPath, Len(newPath)-1)
		end if
		
		RemoveTrailingSlash = newPath
	end function
	
	
	'-------------------------------------------------------------------------
	'	FUNCTION:	GenerateGuid( tableName, fieldName)
	'	Generates a GUID unique to the (tableName, fieldName) pair.
	'-------------------------------------------------------------------------
	function GenerateGuid( tableName, fieldName)
		Dim idQuery, idRS
		Set idRS = Server.CreateObject("ADODB.RecordSet")
		
		Dim guidRS
		set guidRS = db.execute("SELECT newid()")
		
		Dim newId
		newId = guidRS(0)
		
		Dim isUnique
		isUnique = false
		do
			idQuery = "SELECT " & fieldName & " FROM " & tableName & " WHERE " & fieldName & " = " & dbFormatId(newId)
			idRS.Open idQuery, db, adOpenStatic, adCmdText
			if idRS.RecordCount = 0 then
				isUnique = true
			end if
			idRS.Close
		loop until isUnique
		
		GenerateGuid = newId
	End Function ' GenerateGuid()
	
	
	'-------------------------------------------------------------------------
	' The following are enhanced functions to pass a flag to allow a NULL formatted value.
	' If true and the string passed is empty, the string "NULL" is return unmodified. Otherwise
	' the string is formatted appropriately for type.
	'-------------------------------------------------------------------------
	function dbFormatText2(str, allowNull)
		dim result
		result = Trim(CheckForNull(str))
		if allowNull and result = "" then
			result = "NULL"
		else
			result = "'" & Replace(result, "'", "''") & "'"
		end if
		dbFormatText2 = result
	end function
	
	function dbFormatId2(strId, allowNull)
		dim result
		result = Trim(CheckForNull(strId))
		if allowNull and result = "" then
			result = "NULL"
		else
			result = "'" & Replace(result, "'", "''") & "'"
		end if
		dbFormatId2 = result
	end function
	
	function dbFormatDate2(strDate, allowNull)
		dim result
		result = Trim(CheckForNull(strDate))
		if allowNull and result = "" then
			result = "NULL"
		else
			result = "'" & Replace(result, "'", "''") & "'"
		end if
		dbFormatDate2 = result
	end function
	
	function dbFormatNumeric2(str, allowNull)
		dim result
		result = Trim(CheckForNull(str))
		if allowNull and Not IsNumeric(result) then
			result = "NULL"
		end if
		dbFormatNumeric2 = result
	end function
	
	function dbFormatBoolean2(strBool, allowNull)
		dim result
		result = CheckForNull(strBool)
		
		if result = "" then
			result = "NULL"
		elseif strBool then
			result = "1"
		else
			result = "0"
		end if
		
		dbFormatBoolean2 = result
	end function
	
	function dbFormatCurrency2(str, allowNull)
		dim result
		result = CheckForNull(str)
		
		if result = "" then
			result = "NULL"
		elseif isNumeric(str) then
			result = "'" & Replace(str, "'", "''") & "'"
		else
			result = "NULL"
		end if
		
		dbFormatCurrency2 = result
	end function
	
	
	'-------------------------------------------------------------------------
	' FUNCTION: GetFileExtension(filename)
	'
	' Returns the given file's extension, including the period. So abc.tif
	' would return ".tif"
	'-------------------------------------------------------------------------
	Function GetFileExtension(filename)
		Dim theExtension
		
		' Default is no extension
		'
		theExtension = ""
		
		' Ensure the "." is in filename before parsing.
		'
		if InStr(filename, ".") then
			theExtension = Right(filename, Len(filename) - InStrRev(filename, ".") + 1)
		end if
		
		GetFileExtension = theExtension
	End Function
	
	
	'-------------------------------------------------------------------------
	' FUNCTION: GetPropertyId()
	'-------------------------------------------------------------------------
	Function GetPropertyId(propertyKey)
		Dim propertyId, propertyQuery, propertyRS
		Set propertyRS = Server.CreateObject("ADODB.RecordSet")
		
		propertyQuery = "SELECT propertyId FROM accusystemsProperties WHERE propertyKey LIKE " & dbFormatText(propertyKey)
		propertyRS.Open propertyQuery, db, adOpenStatic, adCmdText
		
		propertyId = ""
		if Not propertyRS.eof then
			propertyId = propertyRS("propertyId")
		end if
		
		propertyRS.Close
		
		GetPropertyId = propertyId
	End Function

	'-------------------------------------------------------------------------
	' FUNCTION: GetDocumentHistoryInputId()
	'-------------------------------------------------------------------------
	Function GetDocumentHistoryInputId(inputKey)
		Dim inputId, inputQuery, inputRS
		Set inputRS = Server.CreateObject("ADODB.RecordSet")
		
		inputQuery = "SELECT documentHistoryInputId FROM documentHistoryInput WHERE inputKey LIKE " & dbFormatText(inputKey)
		inputRS.Open inputQuery, db, adOpenStatic, adCmdText
		
		inputId = ""
		if Not inputRS.eof then
			inputId = inputRS("documentHistoryInputId")
		end if
		
		inputRS.Close
		
		GetDocumentHistoryInputId = inputId
	End Function
	
	
	'// CheckForNull
	'//
	'// Checks for a NULL value and returns an empty string if it is NULL
	'//
	function CheckForNull( str)
		Dim returnValue
		
		if IsNull(str) then
			returnValue = ""
		else
			returnValue = str
		end if
		
		CheckForNull = returnValue
	end function	'// CheckForNull

%>

<%
Function ReplaceDuplicateCharacter(str, c)
	Dim tmpStr, prvStr
	tmpStr = str
	do
		prvStr = tmpStr
		tmpStr = Replace(tmpStr, (c & c), c)
	loop until prvStr = tmpStr
	ReplaceDuplicateCharacter = tmpStr
End Function ' ReplaceDuplicateCharacter(str, c)

function ReplaceNumericFirstCharacter(str)
	Dim tmpStr
	tmpStr = str
	if IsNumeric(Left(str,1)) then
		tmpStr = "fld_" & tmpStr
	end if
	
	ReplaceNumericFirstCharacter = tmpStr
end function ' ReplaceNumericFirstCharacter(tmpStr)

' This function used primarily for folder names and other strings
' that become problamatic with special characters.
' NOTE: The underscore '_' is note treated as a special character so is not replaced.
'
function replaceSpecialCharacters(str)
  Dim tmpStr
  tmpStr = str
  tmpStr = Replace(tmpStr, " ", "-")
  tmpStr = Replace(tmpStr, "!", "")
  tmpStr = Replace(tmpStr, "@", "")
  tmpStr = Replace(tmpStr, "#", "")
  tmpStr = Replace(tmpStr, "$", "")
  tmpStr = Replace(tmpStr, "%", "")
  tmpStr = Replace(tmpStr, "^", "")
  tmpStr = Replace(tmpStr, "&", "")
  tmpStr = Replace(tmpStr, "*", "")
  tmpStr = Replace(tmpStr, "(", "")
  tmpStr = Replace(tmpStr, ")", "")
  
  tmpStr = Replace(tmpStr, "/", "")
  tmpStr = Replace(tmpStr, "\", "")
  tmpStr = Replace(tmpStr, ":", "")
  tmpStr = Replace(tmpStr, ";", "")
  tmpStr = Replace(tmpStr, "{", "")
  tmpStr = Replace(tmpStr, "}", "")
  tmpStr = Replace(tmpStr, "[", "")
  tmpStr = Replace(tmpStr, "]", "")
  tmpStr = Replace(tmpStr, "|", "")
  tmpStr = Replace(tmpStr, "+", "")
  tmpStr = Replace(tmpStr, "=", "")
  tmpStr = Replace(tmpStr, "?", "")
  tmpStr = Replace(tmpStr, ",", "")
  tmpStr = Replace(tmpStr, ".", "")
  tmpStr = Replace(tmpStr, "~", "")
  tmpStr = Replace(tmpStr, "'", "")
  tmpStr = Replace(tmpStr, """", "")
  
  tmpStr = Replace(tmpStr, "<", "")
  tmpStr = Replace(tmpStr, ">", "")

  Dim result
  
  replaceSpecialCharacters = tmpStr
end function

' This functions used primarily for Flex Field names
function replaceSpecialCharactersForIdentifier(str)
  Dim tmpStr
  tmpStr = str
  tmpStr = Replace(tmpStr, " ", "")
  tmpStr = Replace(tmpStr, "!", "")
  tmpStr = Replace(tmpStr, "@", "")
  tmpStr = Replace(tmpStr, "#", "")
  tmpStr = Replace(tmpStr, "$", "")
  tmpStr = Replace(tmpStr, "%", "")
  tmpStr = Replace(tmpStr, "^", "")
  tmpStr = Replace(tmpStr, "&", "")
  tmpStr = Replace(tmpStr, "*", "")
  tmpStr = Replace(tmpStr, "(", "")
  tmpStr = Replace(tmpStr, ")", "")
  
  tmpStr = Replace(tmpStr, "/", "")
  tmpStr = Replace(tmpStr, "\", "")
  tmpStr = Replace(tmpStr, ":", "")
  tmpStr = Replace(tmpStr, ";", "")
  tmpStr = Replace(tmpStr, "{", "")
  tmpStr = Replace(tmpStr, "}", "")
  tmpStr = Replace(tmpStr, "[", "")
  tmpStr = Replace(tmpStr, "]", "")
  tmpStr = Replace(tmpStr, "|", "")
  tmpStr = Replace(tmpStr, "+", "")
  tmpStr = Replace(tmpStr, "=", "")
  tmpStr = Replace(tmpStr, "?", "")
  tmpStr = Replace(tmpStr, ",", "")
  tmpStr = Replace(tmpStr, ".", "")
  tmpStr = Replace(tmpStr, "~", "")
  tmpStr = Replace(tmpStr, "'", "")
  tmpStr = Replace(tmpStr, """", "")
  
  tmpStr = Replace(tmpStr, "<", "")
  tmpStr = Replace(tmpStr, ">", "")
  tmpStr = Replace(tmpStr, "-", "")
  tmpStr = Replace(tmpStr, "_", "")
  
  replaceSpecialCharactersForIdentifier = tmpStr
end function

function dbFormatText(str)
  dbFormatText = "'" & Replace(CheckForNull(str), "'", "''") & "'"
end function

function dbFormatId(strId)
	if Trim(strId) = "" then
		dbFormatId = "NULL"
	else
		dbFormatId = "'" & Trim(strId) & "'"
	end if
end function

function dbFormatDate(strDate)
  if Not IsDate(strDate) then
  	dbFormatDate = "NULL"
  elseif UCase(session("database"))= UCase("Access") then
    dbFormatDate = "#" & strDate & "#"
  elseif UCase(session("database"))=UCase("MSSQL") then
    dbFormatDate = "'" & strDate & "'"
  end if
end function

function dbFormatBoolean(strBool)
	if strBool = "1" then
		dbFormatBoolean = 1
	elseif strBool then
		dbFormatBoolean = 1
	else
		dbFormatBoolean = 0
	end if
end function

function positivedbvalue()
  if UCase(session("database"))= UCase("Access") then
    positivedbvalue = "True"
  elseif UCase(session("database"))=UCase("MSSQL") then
    positivedbvalue = "1"
  end if
end function
	
function ableToViewCustomer(maxBanks, bankSecurity, currentbankid, currentEmployeeFlag)
'
'  determines if the current user has access to view the current customer information
'
	dim i		' simple counting variable
	dim view	' result
	view = False
	
	' response.write ("maxBanks=" & maxbanks & "<br>")
	' response.write ("currentbankid=" & currentbankid & "<br>")
	' response.write ("currentEmployeeFlag" & currentemployeeflag & "<br>")
	' for i = 1 to maxbanks
	'    response.write("bankid=" & banksecurity(i,1) & " employeesecurity=" & banksecurity(i,2) & "<br>")
	' next
	
	if Not Session("isSuperUser") then  			' superusers have full access
		for i = 1 to maxBanks							' loop through all the available banks
			if bankSecurity(i,1) = currentbankid then	
				view = True
			end if
		next
	else
		view = true
	end if
	' response.write("result=" & view & "<br>")
	ableToViewCustomer = view

end function

function randomString(numChar)

dim strRdm : strRdm = ""
dim Count : count = 0

Randomize Timer

Do Until Count = NumChar
  Count = Count + 1
  strRdm = strRdm & GetRdm
Loop

randomString = strRdm

end function

Function GetRdm()   
dim fltRand
dim intRand  
dim intChar
fltRand = 36.0 * Rnd()
intRand = Fix(fltRand)   

If intRand < 0 Then
   intRand = 0
End If
If intRand > 35 Then
   intRand = 35
End if
If intRand < 10 Then
   intChar = 48 + intRand ' CHR(48) is character for number "0"
Else
   intRand = intRand - 10
   intChar = 65 + intRand ' CHR(65) is character for "A"
End If
GetRdm = Chr(intChar)
End function

Function GetFileInFolder(dirName)
	  Dim folder, filez, objFile, myFSO
    Dim mostRecentFile, mostRecentFilename
    
    Set myFSO = CreateObject("Scripting.FileSystemObject")
    if Not myFSO.FolderExists(dirName) then
      GetFileInFolder = ""
      exit function
    end if
    
    Set folder = myFSO.GetFolder(dirName)
    Set filez = folder.Files
	  
    firstTime = true
    For Each objFile In filez
      if LCase(objFile.Name) <> "thumbs.db"  then
        if firstTime then
          firstTime = false
          Set mostRecentFile = objFile
          mostRecentFilename = objFile.Name
        end if
        
        if objFile.DateLastModified > mostRecentFile.DateLastModified then
          Set mostRecentFile = objFile
          mostRecentFilename = objFile.Name
        end if
      end if
    next
	  
    Set objItem = Nothing
    Set Folder = Nothing
    Set myFSO = Nothing
    GetFileInFolder = mostRecentFilename
end function

  '====================================================================
  ' NOTE: This function will replace the previous so as not to create
  ' the File System Object for every call
  '====================================================================
  Function getFilename(inFSO, inDirName)
  	  Dim folder, filez, objFile
      Dim mostRecentFile, mostRecentFilename
      
      if Not inFSO.FolderExists(inDirName) then
        getFilename = ""
        exit function
      end if
      
      Set folder = inFSO.GetFolder(inDirName)
      Set filez = folder.Files
  	  
      firstTime = true
      For Each objFile In filez
        if LCase(Right(objFile.Name, 6)) = "psfldr" then
         'ignore sync notation file (*.~psfldr) extensions
        elseif LCase(Right(objFile.Name, 3)) = "xml" then
          'ignore xml file (*.xml) extensions
        elseif LCase(Right(objFile.Name, 2)) = "db" then
          'ignore db file (*.db) extensions
        else
          if firstTime then
            firstTime = false
            Set mostRecentFile = objFile
            mostRecentFilename = objFile.Name
          end if
          
          if objFile.DateLastModified > mostRecentFile.DateLastModified then
            Set mostRecentFile = objFile
            mostRecentFilename = objFile.Name
          end if
        end if
      next
 	  
      Set objItem = Nothing
      Set Folder = Nothing
      getFilename = mostRecentFilename
  end function

  Function ExtractFilename(filePath)
  	Dim filename
	filename = Replace(filePath, "/", "\")
	filename = Right(filename, Len(filename)-InStrRev(filename, "\"))
	ExtractFilename = filename
  End Function

  '### Gets a new filename and it ensures that doesn't exist in the destination folder.
  '### The new file's extension is based on the original filename that is being changed.
  FUNCTION GetNewFilename(dstPath, originalFilename)
	Dim fileExtension : fileExtension = GetFileExtension(originalFilename)
	Dim newFilename : newFilename = RandomString(32) & fileExtension
	Dim fileFound : fileFound = false
	DO
		IF g_fso.FileExists(dstPath & "\" & newFilename) THEN
			newFilename = RandomString(32) & fileExtension
		ELSE
			fileFound = true
		END IF
	LOOP UNTIL fileFound

	GetNewFileName = newFilename
  END FUNCTION


  Function GetBrowserOS()
  	Dim ServerVar
    ServerVar = (Trim(Request.ServerVariables("HTTP_USER_AGENT")))  
    Dim OS 
    ' get server variables 
    If ServerVar <> "" Then 
        If Instr(ServerVar, "Windows NT 5.1") Then 
            OS = "Windows XP" 
       ElseIf Instr(ServerVar,"Windows NT 5.0") Then 
            OS = "Windows 2000" 
      ElseIf Instr(ServerVar,"Windows 98") Then 
            If Instr(ServerVar,"Win 9x 4.90") Then 
                OS = "Windows ME" 
            Else 
                OS = "Windows 98" 
            End If 
        ElseIf Instr(ServerVar,"Windows 95") Then 
            OS = "Windows 95" 
        ElseIf Instr(ServerVar,"Windows NT 4") Then 
            OS = "Windows NT 4.0" 
        Else 
            OS = "Unknown" 
        End If 
    Else 
        OS = "Unknown" 
    End If 
     
    GetBrowserOS = OS 
     
  End Function 
%>

<%  ' DEBUG: output, stop!
    Function Break(n)
    	Response.Write("<pre>" & n & "</pre>")
    	Response.Flush()
    	Response.End()
    End Function
 %> 
 
<%  Function IIf(condition,value1,value2)
	     If condition Then IIf = value1 Else IIf = value2
    End Function %>


<%
function curPageURL()
 dim s, protocol, port

 if Request.ServerVariables("HTTPS") = "on" then 
   s = "s"
 else 
   s = ""
 end if  
 
 protocol = strleft(LCase(Request.ServerVariables("SERVER_PROTOCOL")), "/") & s 

 if Request.ServerVariables("SERVER_PORT") = "80" then
   port = ""
 else
   port = ":" & Request.ServerVariables("SERVER_PORT")
 end if  

 curPageURL = protocol & "://" & Request.ServerVariables("SERVER_NAME") &_ 
              port & Request.ServerVariables("SCRIPT_NAME")
end function

function strLeft(str1,str2)
 strLeft = Left(str1,InStr(str1,str2)-1)
end function


function randomString_test(numChar)
dim strRdm
strRdm = ""
dim Count2
count2 = 0

Randomize Timer

Do Until Count2 = NumChar
  Count2 = Count2 + 1
  strRdm = strRdm & GetRdm_test
Loop

randomString_test = strRdm
end function

Function GetRdm_test() 
dim fltRand
dim intRand  
dim intChar
fltRand = 36.0 * Rnd()
intRand = Fix(fltRand)  
If intRand < 0 Then
   intRand = 0
End If
If intRand > 35 Then
   intRand = 35
End if
If intRand < 10 Then
   intChar = 48 + intRand ' CHR(48) is character for number "0"
Else
   intRand = intRand - 10
   intChar = 65 + intRand ' CHR(65) is character for "A"
End If

GetRdm_test = Chr(intChar)
End function

FUNCTION GetExceptionTabCount(TabId, TabData)
    ' TabData = C (Customer) OR L (Loan)
    Dim exceptionCount : exceptionCount = 0
    IF TabData = "C" THEN
        loanExceptionQuery = _
            " SELECT " & _
            "   TOP 1 1 " & _
            " FROM " & _
            "   exception AS ex " & _
            " WHERE " & _
            "   ex.customerId = " & dbFormatId(TabId) & _
            "   AND ex.loanId IS NULL " & _
            "   AND ex.statusType = 'required' " & _
            "   AND (ex.exceptionState = 'Y' OR ex.exceptionState = 'P') "
    ELSE
        loanExceptionQuery = _
            " SELECT " & _
            "   TOP 1 1 " & _
            " FROM " & _
            "   exception AS ex " & _
            " WHERE " & _
            "   ex.loanId = " & dbFormatId(TabId) & _
            "   AND ex.statusType = 'required' " & _
            "   AND (ex.exceptionState = 'Y' OR ex.exceptionState = 'P') "
    END IF
    loanExceptionRS.Open loanExceptionQuery, db
    IF NOT loanExceptionRS.EOF THEN exceptionCount = 1
    loanExceptionRS.Close
    GetExceptionTabCount = exceptionCount
END FUNCTION

FUNCTION ProcDocHistUsername(nUserID)
	' ### The business rule for Document History Username is as follows, in this order:
    ' ### 1. UserName column in the documentHistory table should have a value of {FirstName} {LastName} (note the space), even if a first, or last name is not defined.
    ' ### 2. If both first and last name are null or empty values, the UserName column value should be set to the user's login name. 
    Dim strOutName : strOutName = ""
    Dim nFirstName, nLastName, nLogin
    Dim UserRS : Set UserRS = Server.CreateObject("ADODB.RecordSet")
    Dim UserSQL : UserSQL = _
		"SELECT" & _
		"	u.userFirstName AS nFirstName," & _
		"	u.userLastName AS nLastName," & _
		"	u.userLogin AS nLogin" & _
		" FROM" & _
		"	[user] AS u" & _
		" WHERE" & _
		"	u.userID = " & dbFormatId(nUserID)
	UserRS.Open UserSQL, db, adOpenStatic, adCmdText
	IF NOT UserRS.EOF THEN
		nFirstName = UserRS("nFirstName")
		nLastName = UserRS("nLastName")
		nLogin = UserRS("nLogin")
	END IF
	UserRS.Close
    IF Trim(nFirstName & "") = "" AND Trim(nLastName & "") = "" THEN
        strOutName = nLogin
    ELSE
        strOutName = nFirstName & " " & nLastName
    END IF
    ProcDocHistUsername = strOutName
END FUNCTION

' ----------------------------------------------------------------
' DocTabExists - Based on CustomerId, LoanId, and DocumentDefId
' Added: JUN|18|2014 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION DocTabExists(nCustomerId, nLoanId, nDocumentDefId)
    Dim nDocumentTabId : nDocumentTabId = ""
	Dim DocTabRS : Set DocTabRS = Server.CreateObject("ADODB.RecordSet")
    Dim DocTabQuery : DocTabQuery = _
        "SELECT" & _
        "    doc.documentTabId" & _
        " FROM" & _
        "    documentTab AS doc" & _
        " WHERE" & _
        "    doc.customerId = " & dbFormatId(nCustomerId) & _
		"    AND doc.documentDefId = " & dbFormatId(nDocumentDefId)
    IF Trim(nLoanId & "") <> "" THEN DocTabQuery = DocTabQuery & "    AND doc.loanId = " & dbFormatId(nLoanId)
    DocTabRS.Open DocTabQuery, db, adOpenStatic, adCmdText
    IF NOT DocTabRS.EOF THEN
        nDocumentTabId = DocTabRS("documentTabId")
    END IF
    DocTabRS.Close
    DocTabExists = nDocumentTabId
END FUNCTION

' ----------------------------------------------------------------
' GetLoanNumber - Based on LoanId
' Added: JUL|15|2014 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetLoanNumber(nLoanId)
    IF Trim(nLoanId & "") = "" THEN EXIT FUNCTION
    Dim LoanNumberRS : Set LoanNumberRS = Server.CreateObject("ADODB.RecordSet")
    Dim LoanNumberQuery : LoanNumberQuery = _
		"SELECT" & _ 
		"	l.loanNumber" & _
		" FROM" & _
		"   loan AS l" & _
		" WHERE" & _
		"   loanId = " & dbFormatId(nLoanId)
    LoanNumberRS.Open LoanNumberQuery, db, adOpenStatic, adCmdText
    IF NOT LoanNumberRS.EOF THEN
        Dim nLoanNumber : nLoanNumber = LoanNumberRS("loanNumber")
    END IF
    LoanNumberRS.Close
	GetLoanNumber = nLoanNumber
END FUNCTION

' ----------------------------------------------------------------
' LineCutOff - Cuts off string after given number of characters
' Added: AUG|26|2014 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION LineCutOff(orgString, orgStringLen, hasSpan, hasEllipsis)
	Dim pstrOut : pstrOut = ""
	Dim Dots : Dots = ""
	IF hasEllipsis THEN Dots = "..."
	IF LEN(orgString) > orgStringLen THEN
		pstrOut = Left(orgString, orgStringLen) & Dots
		If hasSpan THEN
			pstrOut = "<span title=""" & orgString & """>" & pstrOut & "</span>"
		END IF
	ELSE
		pstrOut = orgString
		If hasSpan THEN
			pstrOut = "<span>" & pstrOut & "</span>"
		END IF
	END IF
	LineCutOff = pstrOut
END FUNCTION


' ----------------------------------------------------------------
' RoundUp - Used to round up numbers
' Added: JUL|4|2014 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION RoundUp(num)
    num = CDbl(num)
    IF num = Fix(num) THEN
		RoundUp = num
    ELSE
		RoundUp = Fix(num) + 1
    END IF
END FUNCTION

' ----------------------------------------------------------------
' GetNextTabCount - A counter used for collapsible document functionality on the 
' customer page. Updates a global variable on the customer page when called
' Added: APR|8|2016 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetNextTabCount()
    Dim nextCount : nextCount = tabCount + 1
    tabCount = tabCount + 1
    IF Trim(groupChildren & "") = "" THEN
        groupChildren = nextCount
    ELSE
        groupChildren = groupChildren & "|" & nextCount
    END IF
    GetNextTabCount = nextCount
END FUNCTION

' ----------------------------------------------------------------
' GetNextGroupCount - A counter used for collapsible group functionality on the 
' customer page. Updates a global variable on the customer page when called
' Added: JUL|29|2016 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetNextGroupCount()
    Dim nextCount : nextCount = groupCount + 1
    groupCount = groupCount + 1
    GetNextGroupCount = nextCount
END FUNCTION

' ----------------------------------------------------------------
' GetPurgeStatusIcon - Display correct purge status icon based on the PurgeStatus boolean
' Added: AUG|31|2015 by Paul Jacobs
' NOTE: the blockPurge flag is determined primarily by the BlockPurge flag in the respective
' table, but for documents accounts for the documentStatus as well. We do not
' block on documents and their respective owners if the document purge rule is set to block
' on a document with no file (e.g. documentStatus=2). See corresponding cust_*docbody.inc
' include files for example of the SQL projection of the document BlockPurge state. -- MikeF
' ----------------------------------------------------------------
FUNCTION GetPurgeStatusIcon(purgeStatusIn, purgeStatusLocked, blockPurge)
    Dim altText : altText = "Marked for Deletion"
    Dim titleText : titleText = "Marked for Deletion"
    Dim purgeColor : purgeColor = " aa-color-danger"
    IF blockPurge = true OR (purgeStatusIn = false AND purgeStatusLocked = true) THEN 
        altText = "Blocked from Purge"
        titleText =  "Blocked from Purge"
        purgeColor = " aa-purge-blocked"
    END IF

    Dim purgeIcon : purgeIcon = "&nbsp;"
    IF purgeStatusIn = true OR blockPurge = true OR (purgeStatusIn = false AND purgeStatusLocked = true) THEN
        purgeIcon = "<i class=""aa-icon fas fa-fw fa-times-circle" & purgeColor & """ title=""" & titleText & """ aria-hidden=""true""></i>"
    ELSE
        purgeIcon = "&nbsp;"
    END IF
    GetPurgeStatusIcon = purgeIcon
END FUNCTION

' ----------------------------------------------------------------
' GetPurgeIcon - Display correct purge icon based on the PurgeControl integer
' Added: JUL|10|2014 by Paul Jacobs
' ----------------------------------------------------------------

FUNCTION GetPurgeIcon(accountPurgeControl, showNoIcon, isAdmin)
    IF Trim(accountPurgeControl & "") = "" THEN EXIT FUNCTION
	IF isAdmin THEN
		titleZero = "No Purge" : titleOne = "Manual Purge Control" : titleTwo = "Date Based Purge Rule"
	ELSE
		titleZero = "No Purge Set" : titleOne = "Set for Manual Purge" : titleTwo = "Set for Date Based Purge"
	END IF
    Dim purgeIcon : purgeIcon = ""
    IF Trim(accountPurgeControl & "") = 0 THEN
		IF showNoIcon THEN
			purgeIcon = "<i class=""fas fa-times"" title=""" & titleZero & """ aria-hidden=""true"" title=""Purge Blocked""></i>"
		ELSE
			purgeIcon = "<img src=""Content/Images/Nav/blank.gif"" style=""width:16px;height:16px;border:none""/>"
		END IF
    ELSEIF Trim(accountPurgeControl & "") = 1 THEN
        purgeIcon = "<i class=""fas fa-user"" title=""" & titleOne & """ aria-hidden=""true""></i>"
    ELSEIF Trim(accountPurgeControl & "") = 2 THEN
        purgeIcon = "<i class=""fas fa-calendar-alt fs16"" title=""" & titleTwo & """ aria-hidden=""true""></i>"
    END IF
    GetPurgeIcon = purgeIcon
END FUNCTION

' ----------------------------------------------------------------
' toCharBool - Convert any potential boolean values to a bit
' Added: JUL|11|2014 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION toCharBool(val)
    Dim pstrVal, pintOut
    pstrVal = Trim(val & "")
    SELECT CASE pstrVal
        CASE "","0","false","False",false,"off"
            pintOut = 0
        CASE "1",true,"True","true","on"
            pintOut = 1
        CASE ELSE
            pintOut = 1
    END SELECT
    toCharBool = pintOut
END FUNCTION

' --------------------------------------------------------------------------
' NormalizePath - This script normalizes all of the path slashes based
' on the type of path being passed, as indicated by the isFileSystemPath.
' Added: JAN|21|2015 by Paul Jacobs
' --------------------------------------------------------------------------
FUNCTION NormalizePath(path, isFileSystemPath)
    IF Trim(path & "") = "" THEN EXIT FUNCTION
	'### isFileSystemPath is a bit flag
	Dim pstrOut : pstrOut = ""
	IF isFileSystemPath THEN
        ' ### File system paths - replaces any forwards slashes with back slashes
        pstrOut = Replace(path, "/", "\")
    ELSE
        ' ### URL's - replaces any back slashes with forward slashes
        pstrOut = Replace(path, "\", "/")
    END IF
	NormalizePath = pstrOut
END FUNCTION

' --------------------------------------------------------------------------
' GetDocumentFilePath - This script constructs the path to a document based
' on the information taken from the document record.
' Added: MAR|11|2015 by Paul Jacobs
' --------------------------------------------------------------------------
FUNCTION GetDocumentFilePath(theDocumentId)
    Dim docRS : Set docRS = Server.CreateObject("ADODB.RecordSet")
    Dim docQuery : docQuery = _
		" SELECT" & _
		"	c.customerFolder," & _
		"	IsNull(l.loanFolder, '') AS loanFolder," & _
		"	d.loanFile," & _
		"	d.filename" & _
		" FROM" & _
		"	document AS d INNER JOIN customer AS c" & _
		"		ON d.customerId=c.customerId" & _
		"	LEFT OUTER JOIN loan AS l" & _
		"		ON l.loanId=d.loanId" & _
		" WHERE" & _
		"	d.documentId=" & dbFormatId(theDocumentId)
    docRS.Open docQuery, db, adOpenStatic, adCmdText
    IF NOT docRS.EOF THEN
        Dim resultPath : resultPath = docRS("customerFolder") & docRS("loanFolder") & docRS("loanFile") & "/" & docRS("filename")
    END IF
    docRS.Close
    GetDocumentFilePath = resultPath
END FUNCTION

' --------------------------------------------------------------------------
' RemoveCurlyBrackets - This script removes any curly brackets from a
' variable.
' Added: MAR|12|2015 by Paul Jacobs
' --------------------------------------------------------------------------
FUNCTION RemoveCurlyBrackets(pstrIn)
	IF Trim(pstrIn & "") = "" THEN EXIT FUNCTION
	Dim pstrOut : pstrOut = ""
	pstrOut = Replace(pstrIn, "{", "")
	pstrOut = Replace(pstrOut, "}", "")
	RemoveCurlyBrackets = pstrOut
END FUNCTION

' --------------------------------------------------------------------------
' GetDocumentTypeIcon - Identifies the file extension of a filename and
'                       displays the appropriate icon
' Added: MAY|29|2015 by Paul Jacobs
' --------------------------------------------------------------------------
FUNCTION GetDocumentTypeIcon(nFileName)
    IF Trim(nFileName & "") = "" THEN
        GetDocumentTypeIcon = "Content/Images/Icons/pixel.gif"
    ELSE
        Dim pstrOut : pstrOut = ""
        Dim fileNameAry : fileNameAry = Split(lCase(nFileName),".")
        Dim lastInArray : lastInArray = fileNameAry(uBound(fileNameAry))
        IF lastInArray = "ppt" OR lastInArray = "pptx" THEN
            pstrOut = "fa-file-powerpoint"
        ELSEIF lastInArray = "xls" OR lastInArray = "xlsx" OR lastInArray = "csv" THEN
            pstrOut = "fa-file-excel"
        ELSEIF lastInArray = "doc" OR lastInArray = "docx" THEN
            pstrOut = "fa-file-word"
        ELSEIF lastInArray = "txt" THEN
            pstrOut = "fa-file-alt"
        ELSEIF lastInArray = "xml" THEN
            pstrOut = "fa-file-code"
        ELSEIF lastInArray = "pdf" THEN
            pstrOut = "fa-file-pdf"
        ELSEIF lastInArray = "tif" OR lastInArray = "tiff" THEN
            pstrOut = "fa-file-image"
        ELSEIF lastInArray = "xsn" THEN
            pstrOut = "fa-file-code"
        ELSE
        	pstrOut = "fa-file"
        END IF
        GetDocumentTypeIcon = "aa-file-type-icon fad " & pstrOut & " fa-fw"
    END IF
END FUNCTION

' --------------------------------------------------------------------------
' ThisOrThat - Inline logical if else statement to work inside hard coded
' server code
' Added: NOV|27|2017 by Paul Jacobs
' --------------------------------------------------------------------------
FUNCTION ThisOrThat(LogicalExpression, ValueIfTrue, ValueIfFalse)
	IF LogicalExpression THEN
		ThisOrThat = ValueIfTrue
	ELSE
		ThisOrThat = ValueIfFalse
	END IF
END FUNCTION

' ----------------------------------------------------------------
' GetCustomerId - Based on LoanId
' Added: MAY|25|2016 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetCustomerId(nLoanId)
    IF Trim(nLoanId & "") = "" THEN EXIT FUNCTION
    Dim CustomerIdentRS : Set CustomerIdentRS = Server.CreateObject("ADODB.RecordSet")
    Dim CustomerIdentQuery : CustomerIdentQuery = _
        "SELECT" & _ 
        "   l.customerId" & _
        " FROM" & _
        "   loan AS l" & _
        " WHERE" & _
        "   loanId = " & dbFormatId(nLoanId)
    CustomerIdentRS.Open CustomerIdentQuery, db, adOpenStatic, adCmdText
    IF NOT CustomerIdentRS.EOF THEN
        Dim nCustomerIdent : nCustomerIdent = CustomerIdentRS("customerId")
    END IF
    CustomerIdentRS.Close
    GetCustomerId = nCustomerIdent
END FUNCTION

' ----------------------------------------------------------------
' GetCustomerNumber - Based on customerId
' Added: MAY|25|2016 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetCustomerNumber(nCustomerId)
    IF Trim(nCustomerId & "") = "" THEN EXIT FUNCTION
    Dim CustomerNumberRS : Set CustomerNumberRS = Server.CreateObject("ADODB.RecordSet")
    Dim CustomerNumberQuery : CustomerNumberQuery = _
        "SELECT" & _ 
        "   c.customerNumber" & _
        " FROM" & _
        "   customer AS c" & _
        " WHERE" & _
        "   customerId = " & dbFormatId(nCustomerId)
    CustomerNumberRS.Open CustomerNumberQuery, db, adOpenStatic, adCmdText
    IF NOT CustomerNumberRS.EOF THEN
        Dim nCustomerNumber : nCustomerNumber = CustomerNumberRS("customerNumber")
    END IF
    CustomerNumberRS.Close
    GetCustomerNumber = nCustomerNumber
END FUNCTION

' ----------------------------------------------------------------
' GetStatusIcon - Based on boolean status
' Added: JUN|6|2016 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetStatusIcon(status)
    Dim imgFile : imgFile = "Content/Images/Nav/icon_red.gif"
    IF status THEN imgFile = "Content/Images/Nav/icon_green.gif"
    GetStatusIcon = imgFile
END FUNCTION

' ----------------------------------------------------------------
' RemoveHTML - Remove HTML code from a string
' Added: JUL|14|2016 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION RemoveHTML(strText)
    IF Trim(strText & "") = "" THEN EXIT FUNCTION
    Dim RegEx : Set RegEx = New RegExp
    Dim pstrOut : pstrOut = ""

    RegEx.Pattern = "<[^>]*>"
    RegEx.Global = True
    pstrOut = RegEx.Replace(strText, "")
    RegEx.Pattern = "&lt;[^&gt;]*&gt;"
    RegEx.Global = True
    pstrOut = RegEx.Replace(pstrOut, "")
    pstrOut = replace(pstrOut,vbLf,"")
    pstrOut = replace(pstrOut,vbCrLf,"")
    pstrOut = replace(pstrOut,vbCr,"")
    pstrOUt = replace(pstrOut,"&nbsp;"," ")
    pstrOut = replace(pstrOut," & "," &amp; ")
    RemoveHTML = pstrOut
END FUNCTION

' ----------------------------------------------------------------
' CheckCustomFieldsExistance - Check for customerFields, if not available, insert them.
' Added: NOV|29|2016 by Paul Jacobs
' ----------------------------------------------------------------
SUB CheckCustomFieldsExistance(nCustomerId)
    Dim sqlQuery : sqlQuery = "SELECT COUNT(*) AS cnt FROM customerFields WHERE customerId=" & dbFormatId(nCustomerId)
    Dim result : Set result = db.Execute(sqlQuery)

    IF result("cnt") = 0 THEN
        db.Execute "INSERT INTO customerFields (customerId) VALUES (" & dbFormatId(nCustomerId) & ")"
    END IF
    result.Close()
END SUB

' ----------------------------------------------------------------
' RemoveCarriageReturns - Remove any inline vbCr or vbCrLf embedded
' characters from a string.
' Added: JAN|31|2017 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION RemoveCarriageReturns(strIn)
    IF Trim(strIn & "") = "" THEN EXIT FUNCTION
    Dim strOut : strOut = Trim(strIn)
    strOut = Replace(strOut, vbCrLf, "")
    strOut = Replace(strOut, vbCr, "")
    strOut = Replace(strOut, vbLf, "")
    RemoveCarriageReturns = strOut
END FUNCTION

' ----------------------------------------------------------------
' GetDecimalDetails - Retrieves the size and precision values from
' the fieldDefintiion table so it can be used for client side
' validation.
' When used the developer must ensure that a global variable for 
' "fieldSize" and "fieldPrecision" are on the page somewhere.
' Added: FEB|27|2017 by Paul Jacobs
' ----------------------------------------------------------------
SUB GetDecimalDetails(nFieldDefinitionId)
    IF Trim(nFieldDefinitionId & "") = "" THEN EXIT SUB
    Dim decimalPrecisionRS : Set decimalPrecisionRS = Server.CreateObject("ADODB.RecordSet")
    Dim decimalPrecisionQuery : decimalPrecisionQuery = _
        "SELECT" & _ 
        "   fd.fieldDefDataSize," & _
        "   fd.fieldDefDataPrecision" & _
        " FROM" & _
        "   fieldDefinition AS fd" & _
        " WHERE" & _
        "   fieldDefId = " & dbFormatId(nFieldDefinitionId)
    decimalPrecisionRS.Open decimalPrecisionQuery, db
    IF NOT decimalPrecisionRS.EOF THEN
        fieldSize = decimalPrecisionRS("fieldDefDataSize")
        fieldPrecision = decimalPrecisionRS("fieldDefDataPrecision")
    END IF
    decimalPrecisionRS.Close
END SUB

' ----------------------------------------------------------------
' CanAccessPurge - Establishes if the user has access to modify purge settings
' Added: MAR|7|2017 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION CanAccessPurge()
    Dim hasPermission : hasPermission = false
    IF Session("acculoan.enablePurge") = 1 AND (Session("isSuperUser") OR Session("allowPurgeModifications")) THEN hasPermission = True
    CanAccessPurge = hasPermission
END FUNCTION

' ----------------------------------------------------------------
' HasParticipationLoans - Returns the number of participation loans a customer has
' Added: APR|14|2017 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION HasParticipationLoans(nCustomerId)
    IF Trim(nCustomerId & "") = "" THEN EXIT FUNCTION
    Dim nCount : nCount = 0
    Dim participationLoanRS : Set participationLoanRS = Server.CreateObject("ADODB.RecordSet")
    Dim participationLoanQuery : participationLoanQuery = _
        "SELECT " & _
        "   COUNT(loanId) AS participationLoanCount " & _
        "FROM " & _
        "   loan " & _
        "WHERE " & _
        "   customerId = " & dbFormatId(nCustomerId) & _
        "   AND isParticipationLoan = 1"
    participationLoanRS.Open participationLoanQuery, db
    nCount = participationLoanRS("participationLoanCount")
    participationLoanRS.Close()
    HasParticipationLoans = nCount
END FUNCTION

FUNCTION StatusIconFlat(nColor, nTitle)
    IF Trim(nColor & "") = "" THEN EXIT FUNCTION
    Dim strOut : strOut = ""

    IF Trim(nTitle & "") <> "" THEN
        strOut = "<i class=""fas fa-circle fs8 m12"" style=""color:" & nColor & """ title=""" & nTitle & """ aria-hidden=""true""></i>"
    ELSE
        strOut = "<i class=""fas fa-circle fs8 m12"" style=""color:" & nColor & """ aria-hidden=""true""></i>"
    END IF
    StatusIconFlat = strOut
END FUNCTION

FUNCTION GetPropertyValue(propertyKey)
    IF Trim(propertyKey & "") = "" THEN EXIT FUNCTION
    Dim propertyValue : propertyValue = ""
    Dim propertyRS : Set propertyRS = Server.CreateObject("ADODB.RecordSet")
    Dim propertyQuery : propertyQuery = "SELECT propertyValue FROM accusystemsProperties WHERE propertyKey = " & dbFormatText(propertyKey)
    propertyRS.Open propertyQuery, db, adOpenStatic, adCmdText
    IF NOT propertyRS.EOF THEN propertyValue = propertyRS("propertyValue")
    propertyRS.Close
    GetPropertyValue = propertyValue
END FUNCTION

FUNCTION AddItem(arr, val)
    ReDim Preserve arr(uBound(arr) + 1)
    arr(UBound(arr)) = val
    AddItem = arr
END FUNCTION

' ### The following is a general purpose call to request an action via a WebAPI service call that passes 
' as JSON data object via POST. Users should pass the requested action via the apiRequest parameter.
' The subroutine will make sure the base url location is prepended to the action.
'
' This method is called primarily by Audit Logging service calls, but could potentially be used for 
' any web service requests that POST a JSON block of data. ###

SUB SendWebApiRequest(data, apiRequest)
    On Error Resume Next
    Dim objRequest
    Set objRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
        
    ' Server url needs to be fully qualified.
    Dim link : link = Session("acculoan.serverURL") & apiRequest

    Dim responseStatus
    WITH objRequest
	    .SetAutoLogonPolicy 0
        .Open "POST", link, False
        .SetRequestHeader "Content-Type", "application/json"
        .Send data

        responseStatus = .Status
    END WITH
    On Error Goto 0

    IF NOT (responseStatus = 200 OR responseStatus = 204 OR responseStatus = 1223) THEN
        Set objRequest = CreateObject("WinHttp.WinHttpRequest.5.1")
        WITH objRequest
		    .SetAutoLogonPolicy 0
            .Open "POST", link, False
            .SetRequestHeader "Content-Type", "application/json"
            .Send data

			Response.Write "An error occurred while submitting Audit Tracking information:  <BR>"
			Response.Write "Status Number: " & .Status & "<BR>"
			Response.Write "Detailed Message: " & .StatusText & "<BR><BR>"
        END WITH
    END IF
END SUB

FUNCTION ArrayToJSON(dataArray, dataFields, dataArrayName)
    IF NOT IsArray(dataArray) THEN EXIT FUNCTION
    ReDim arrObj(uBound(dataArray, 2) - 1)
    Dim i, j
    Dim pstrOut : pstrOut = ""
    FOR i = 0 TO uBound(dataArray, 2)
        pstrOut = pstrOut & "{"
        ReDim arrProp(uBound(dataArray, 1))
        FOR j = 0 TO uBound(dataArray, 1)
            pstrOut = pstrOut & """" & dataFields(j) & """:""" & EscapeCharactersJSON(dataArray(j, i)) & ""","
        NEXT
        pstrOut = Left(pstrOut, Len(pstrOut) - 1) & "},"
    NEXT
    IF Trim(dataArrayName & "") = "" THEN
        ArrayToJSON = "[" + Left(pstrOut,  Len(pstrOut) - 1) + "]"
    ELSE
        ArrayToJSON = "{""" & dataArrayName & """:[" + Left(pstrOut,  Len(pstrOut) - 1) + "]}"
    END IF
END FUNCTION

FUNCTION EscapeCharactersJSON(strIn)
    IF Trim(strIn & "") = "" THEN EXIT FUNCTION
    Dim strOut : strOut = ""
    strOut = Replace(strIn, "\", "\\")
    strOut = Replace(strOut, "{", "")
    strOut = Replace(strOut, "}", "")
	strOut = Replace(strOut, "'", "\'")
    EscapeCharactersJSON = strOut
END FUNCTION

FUNCTION ShowCheckmark(isTrueEvent, thisOnClick, idName)
    IF Trim(isTrueEvent & "") = "" THEN EXIT FUNCTION
    Dim pStrOut : pStrOut = ""

	Dim idAttr	: idAttr = ""
	IF Trim(idName + "") <> "" then
		idAttr = " id=""" & Trim(idName + "") & """"
	END IF

    IF Trim(thisOnClick & "") = "" THEN
        ' ### HAS NO ONCLICK EVENT ###
        IF isTrueEvent THEN
            pStrOut = "<i class=""aa-icon fas fa-check aa-color-success"" aria-hidden=""true""" & idAttr & "></i>"
        ELSE
            pStrOut = "&nbsp;"
        END IF
    ELSE
        ' ### HAS ONCLICK EVENT ###
        IF isTrueEvent THEN
            pStrOut = "<i class=""aa-icon fas fa-check aa-color-success"" onclick=""" & thisOnClick & """ aria-hidden=""true""" & idAttr & "></i>"
        ELSE
            pStrOut = "<i class=""aa-icon fa aa-tick"" onclick=""" & thisOnClick & """ aria-hidden=""true""" & idAttr & "></i>"
        END IF
    END IF
    ShowCheckmark = pStrOut
END FUNCTION

' ----------------------------------------------------------------
' requestOrSession - Check for existence of a request and if one exists it will set the session, but if not it will use the session variable
' Added: DEC|12|2018 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION requestOrSession(requestName, sessionName)
    IF Trim(requestName & "") = "" THEN EXIT FUNCTION
    IF Trim(sessionName & "") = "" THEN EXIT FUNCTION

    Dim pStrOut : pStrOut = ""
    IF Trim(Request(requestName) & "") = "" THEN
        pStrOut = Session(sessionName)
    ELSE
        pStrOut = Trim(Request(requestName))
        Session(sessionName) = pStrOut
    END IF
    requestOrSession = pStrOut
END FUNCTION

' ----------------------------------------------------------------
' htmlEncode - Provides a function to encode special characters seen in XML. <>'" and Line Feeds.
' Added: JAN|7|2019 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION htmlEncode(inStr)
    Dim outStr : outStr = inStr
    outStr = Replace(outStr, chr(60), "&lt;")
    outStr = Replace(outStr, chr(62), "&gt;")
    outStr = Replace(outStr, chr(34), "&quot;")
    outStr = Replace(outStr, chr(39), "&apos;")
    outStr = Replace(outStr, vbLf, "")
    htmlEncode = outStr
END FUNCTION

' ----------------------------------------------------------------
' GetDefaultClassificationId - Returns the default or top classification for either credit or loan
' Added: APR|10|2019 by Paul Jacobs
' ----------------------------------------------------------------
FUNCTION GetDefaultClassificationId(thisType)
    IF Trim(thisType & "") = "" THEN EXIT FUNCTION
    Dim defaultClassificationId : defaultClassificationId = ""
    Dim classificationRS : Set classificationRS = Server.CreateObject("ADODB.RecordSet")
    Dim classificationQuery : classificationQuery = _
        " SELECT TOP 1 classificationId FROM (" & _
        "   SELECT TOP 1 classificationId, 100 AS sortOrder FROM creditClassification WHERE type = '" & thisType & "' AND isDefault = 1" & _
        "   UNION ALL" & _
        "   SELECT TOP 1 classificationId, 200 AS sortOrder FROM creditClassification WHERE type = '" & thisType & "' ORDER BY classificationName" & _
        " ) AS v1" & _
        " ORDER BY v1.sortOrder"
    classificationRS.Open classificationQuery, db
    IF NOT classificationRS.EOF THEN
        defaultClassificationId = classificationRS("classificationId")
    END IF
    classificationRS.Close
    GetDefaultClassificationId = defaultClassificationId
END FUNCTION

FUNCTION GetPaddedDateString(inDate)
	Dim tmpDate : tmpDate = FormatDateTime(inDate, 2)
	Dim dateElements : dateElements = Split(tmpDate, "/")

	Dim dayPart : dayPart = Right(("00" & dateElements(0)),2)
	Dim monthPart : monthPart = Right(("00" & dateElements(1)),2)
	Dim yearPart : yearPart = dateElements(2)

	GetPaddedDateString = dayPart & "/" & monthPart & "/" & yearPart
END FUNCTION

FUNCTION hexConvert(hexCode)
    Dim color : color = Replace(hexCode, "#", "")
    Dim R : R = cInt("&H" & Mid(color,1,2))
    Dim G : G = cInt("&H" & Mid(color,3,2))
    Dim B : B = cInt("&H" & Mid(color,5,2))
    hexConvert = R & ", " & G & ", " & B
END FUNCTION

FUNCTION InsertCarriageReturns(inStr, cutAt)
    Dim nInsert : nInsert = cutAt
    DO WHILE nInsert < Len(inStr)
        Dim nBreak : nBreak = InStrRev(inStr, " ", nInsert)
        IF nInsert - nBreak > cutAt THEN
            inStr = Left(inStr, nInsert) & "<br/>" &  Mid(inStr, nInsert + 1)
        ELSE
            nInsert = nBreak
            inStr = Left(inStr, nInsert) & "<br/>" &  Mid(inStr, nInsert + 1)
        END IF
        nInsert = nInsert + cutAt + 2
    LOOP
    InsertCarriageReturns = inStr
END FUNCTION

'### Functions for building out URLs
'###

FUNCTION GetRequestUrlScheme()
	DIM scheme : scheme = "http"

	IF Request.ServerVariables("HTTPS") = "ON" THEN scheme = "https"

	GetRequestUrlScheme = scheme
END FUNCTION

FUNCTION CreateUrl(scheme, hostname, port, virtualPath)
	DIM url : url = scheme & "://" & hostname & ":" & port & "/" &virtualPath

	CreateUrl = url
END FUNCTION

Function GetDocumentFileViewUrl(documentId, userId)
	Dim url : url = "document(" & documentId & ")/file" & "?dispositionType=inline&userId=" & userId
	GetDocumentFileViewUrl = url
End Function

Function GetUploadFileViewUrl(path, filename, userId)
	Dim url : url = "uploads/file?path=" & Server.URLEncode(path) & "&name=" & Server.URLEncode(filename) & "&dispositionType=inline"
	GetUploadFileViewUrl = url
End Function

Function GetFileStorageViewUrl(path, filename, userId)
	Dim ulr : url = "api/storage/file?path=" & Server.URLEncode(path) & "&fileName=" & Server.URLEncode(filename) & "&dispositionType=inline&userId=" & userId
	GetFileStorageViewUrl = url
End Function

'### The following are functions are for injecting strings into various languages that are escaped properly
'###

FUNCTION EscapeJSStr(inStr)
    IF Trim(inStr & "") = "" THEN EXIT FUNCTION
    EscapeJSStr = Replace(inStr, "'", "\'")
END FUNCTION

FUNCTION StringToJSStringSQ(value)
    IF Trim(value & "") = "" THEN StringToJSStringSQ = value
    StringToJSStringSQ = Replace(value, "'", "\'")
END FUNCTION

FUNCTION StringToJSStringDQ(value)
    IF Trim(value & "") = "" THEN StringToJSStringDQ = value
    StringToJSStringDQ = Replace(value, """", "\""")
END FUNCTION

FUNCTION StringToSQLString(value)
	IF Trim(value & "") = "" THEN StringToSQLString = value
	StringToSQLString = dbFormatText(value)
END FUNCTION

FUNCTION StringToHtmlString(value)
	IF Trim(value & "") = "" THEN StringToHtmlString = value
	StringToHtmlString = Server.HTMLEncode(value)
END FUNCTION


'### Class for handling error responses.
'###
Class ErrorResponse
	Private m_status
	Private m_message
	Private m_errors
	
	Public Property Let Status(vData)
		m_status = vData
	End Property

	Public Property Get Status()
		Status = m_status
	End Property

	Public Property Let Message(vData)
		m_message = vData
	End Property

	Public Property Get Message()
		Message = m_message
	End Property

	Public Property Let Errors(vData)
		m_errors = vData
	End Property

	Public Property Get Errors
		Errors = m_errors
	End Property

	Public Sub ParseErrorResponse(httpRequest)
		Dim errorList() : ReDim errorList(-1)

		' ### Set defaults in case of non-ErrorResponse returned
		' ###
		Me.Status  = httpRequest.Status
		Me.Message = httpRequest.StatusText
		Me.Errors  = errorList

		IF InStr(httpRequest.ResponseText, "ErrorResponse") > 0 THEN
			Dim xmlResponse : SET xmlResponse = Server.CreateObject("MSXML2.DOMDocument.3.0") 
        
			xmlResponse.LoadXml(httpRequest.ResponseText)
        
			Me.Message = xmlResponse.selectSingleNode("ErrorResponse/ErrorMessage").Text

			Dim i : i = 0
			FOR EACH node IN xmlResponse.selectNodes("ErrorResponse/Errors/string")
				ReDim Preserve errorList(i)
				errorList(i) = node.Text
				i = i + 1
			NEXT

			Me.Errors = errorList
		END IF
	End Sub
End Class
%>