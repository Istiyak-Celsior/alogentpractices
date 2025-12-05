<%
  Dim db
  Dim dbAccuDoc
  Dim strconn
  Dim strconnAccuDoc
  Dim rptConn
  Dim accessdb
  Dim xmlNode
  

  Set dbAccuDoc = NOTHING
  if session("strconn") = "" then
    dim xmlDoc
    set xmlDoc=Server.CreateObject("Microsoft.XMLDOM")
    xmlDoc.async=false
    xmlDoc.load server.mappath("xml/config.xml")
    dim xmlconfiglist
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("connection")
    for each xmlNode in xmlconfiglist
       strconn = xmlNode.text
       Session("strconn") = strconn
    next
	
	' Get the AccuDoc string connection if available
	'
    set xmlconfiglist=xmlDoc.getElementsByTagName("AccuDocConnection")
    for each xmlNode in xmlconfiglist
       strconnAccuDoc = xmlNode.text
       Session("strconnAccuDoc") = strconnAccuDoc
    next
	
    Session("rptConn") = ""
    set xmlconfiglist=xmlDoc.getElementsByTagName("ReportConnection")
    for each xmlNode in xmlconfiglist
       rptConn = xmlNode.text
       Session("rptConn") = rptConn     
    next
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("fullPath")
    for each xmlNode in xmlconfiglist
       Session("fullPath") = xmlNode.text   
    next
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("serverPath")
    for each xmlNode in xmlconfiglist
       Session("serverPath") = xmlNode.text   
    next
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("relativePath")
    Session("relativePath") = "scanned_images/"   'Default
    for each xmlNode in xmlconfiglist
       Session("relativePath") = xmlNode.text   
    next    
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("uploadPath")
    Session("uploadPath") = "upload/"   'Default
    for each xmlNode in xmlconfiglist
       Session("uploadPath") = xmlNode.text   
    next    
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("logPath")
    Session("logPath") = "logs/"   'Default
    for each xmlNode in xmlconfiglist
       Session("logPath") = xmlNode.text   
    next    

    set xmlconfiglist=xmlDoc.getElementsByTagName("database")
    for each xmlNode in xmlconfiglist
       Session("database") = xmlNode.text   
    next    
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("databaseVersion")
    for each xmlNode in xmlconfiglist
       Session("databaseVersion") = xmlNode.text   
    next     
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("useGUID")
    for each xmlNode in xmlconfiglist
       Session("useGUID") = xmlNode.text   
    next     
    
    'Only used for Auditor's Module
    set xmlconfiglist=xmlDoc.getElementsByTagName("auditPath")
    Session("auditPath") = "audit/"
    for each xmlNode in xmlconfiglist
       Session("auditPath") = xmlNode.text   
    next     
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("dbScanHistory")
    for each xmlNode in xmlconfiglist
       Session("dbScanHistory") = xmlNode.text   
    next     
    
    'Configuration property to allow barcode scanning.
    'NOTE: Requires use of AccuScanPro to utilize this function.
    set xmlconfiglist=xmlDoc.getElementsByTagName("barcodeScanYN")
    for each xmlNode in xmlconfiglist
       Session("barcodeScanYN") = xmlNode.text   
    next     
    
    'Configuration property for enabling Microsoft Windows Security.
    ' NOTE: 'Y' uses windows security to log the user in instead of AccuAccount's security.
    ' If the flag is set 'Y' then you _must_ include the security domain for MS to look
    ' up the user's profile.
    ' 'N' sets the login to AccuAccount login/password
    set xmlconfiglist=xmlDoc.getElementsByTagName("enableWindowsSecurityYN")
    for each xmlNode in xmlconfiglist
       Session("enableWindowsSecurityYN") = UCase(xmlNode.text)
    next     
    
    'Configuration property for the site domain.
    ' NOTE: This is only used if enableWindowsSecurityYN is set to 'Y' otherwise
    ' the value is ignored.
    set xmlconfiglist=xmlDoc.getElementsByTagName("securityDomain")
    for each xmlNode in xmlconfiglist
       Session("securityDomain") = xmlNode.text   
    next     
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("externalDocs") ' for external docs folder
    for each xmlNode in xmlconfiglist 
       if mid(xmlNode.text,1,2) = "\\" then
           if mid(xmlNode.text,len(xmlNode.text),1) <> "\" then
              Session("externalDocs") = xmlNode.text & "\"     
           else
              Session("externalDocs") = xmlNode.text      
           end if
       else
           if mid(xmlNode.text,len(xmlNode.text),1) <> "/" then
              Session("externalDocs") = xmlNode.text & "/"     
           else
              Session("externalDocs") = xmlNode.text      
           end if
       end if     
    next
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("VirtualShareDir")
    for each xmlNode in xmlconfiglist
       Session("VirtualShareDir") = UCase(xmlNode.text)
    next  
    
    set xmlconfiglist=xmlDoc.getElementsByTagName("UseBranchSecurity")
    for each xmlNode in xmlconfiglist
       Session("UseBranchSecurity") = xmlNode.text   
    next
	
	if Session("UseBranchSecurity") = "" then
		Session("UseBranchSecurity") = "N"
	end if 
    
		' Get EMail server settings
		'
		Set xmlconfiglist=xmlDoc.getElementsByTagName("sendUsing")
		for each xmlNode in xmlconfiglist
       Session("email.sendUsing") = xmlNode.text   
    next
		
		Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpPickupDirectory")
		for each xmlNode in xmlconfiglist
       Session("email.smtpPickupDirectory") = xmlNode.text   
    next

		Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpServer")
		for each xmlNode in xmlconfiglist
       Session("email.smtpServer") = xmlNode.text   
    next

		Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpPort")
		for each xmlNode in xmlconfiglist
       Session("email.smtpPort") = xmlNode.text   
    next
		
	' Get extended EMail server settings
	'
    Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpUseDefaultCredentials")
	for each xmlNode in xmlconfiglist
        If xmlNode.text = "" Then
            Session("email.smtpUseDefaultCredentials") = false
        Else
            Session("email.smtpUseDefaultCredentials") = CBool(xmlNode.text)
        End If
    next

    Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpEnableSsl")
	for each xmlNode in xmlconfiglist
        If xmlNode.text = "" Then
            Session("email.smtpEnableSsl") = false
        Else
            Session("email.smtpEnableSsl") = CBool(xmlNode.text)
        End If        
    next

    Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpSender")
	for each xmlNode in xmlconfiglist
       Session("email.smtpSender") = xmlNode.text   
    next

    Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpUserName")
	for each xmlNode in xmlconfiglist
       Session("email.smtpUserName") = xmlNode.text   
    next

    Set xmlconfiglist=xmlDoc.getElementsByTagName("smtpPassword")
	for each xmlNode in xmlconfiglist
       Session("email.smtpPassword") = xmlNode.text   
    next


		' Get Loan Approval configuration flag
		'
		Set xmlconfiglist=xmlDoc.getElementsByTagName("enableLoanApprovalsYN")
		for each xmlNode in xmlconfiglist
       Session("enableLoanApprovalsYN") = xmlNode.text   
    next
		if Session("enableLoanApprovalsYN") = "" then
			Session("enableLoanApprovalsYN") = "N"
		end if
		
		
  else
     strconn = Session("strconn")
	 strconnAccuDoc = Session("strconnAccuDoc")
  end if
	
	
	' Open the AccuAccount db connection
	'
	Set db = Server.CreateObject("ADODB.Connection")
	db.Open strconn
	
	
	' Open the AccuDoc db connection if available
	'
	if strconnAccuDoc <> "" then
		Set dbAccuDoc = Server.CreateObject("ADODB.Connection")
		dbAccuDoc.Open strconnAccuDoc
	end if

    ' ### Load all properties into Session if they have not been loaded yet. ###
    'IF NOT Session("acculoanPropertiesLoaded") THEN
        Dim accusystemsPropertiesRS : Set accusystemsPropertiesRS = Server.CreateObject("ADODB.RecordSet")
        Dim accusystemsPropertiesQuery : accusystemsPropertiesQuery = _
            "SELECT propertyKey, propertyValue FROM accusystemsProperties"
        accusystemsPropertiesRS.Open accusystemsPropertiesQuery, db, adOpenForwardOnly, adLockReadOnly

        DO UNTIL accusystemsPropertiesRS.EOF
            Session(accusystemsPropertiesRS("propertyKey")) = accusystemsPropertiesRS("propertyValue")
            accusystemsPropertiesRS.MoveNext
        LOOP

        accusystemsPropertiesRS.Close

        Session("acculoanPropertiesLoaded") = false

		IF Session("UseBranchSecurity") = "N" THEN
			Session("bankSecurity") = "XX"
		ELSE
			Session("bankSecurity") = Session("acculoan.branchSecurity.level")
		END IF
    'END IF
%>