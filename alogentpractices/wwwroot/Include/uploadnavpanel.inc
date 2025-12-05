<!-- #include file="directPrintStringFunctions.inc" -->
<!-- #include file="getDocumentUpload.inc" -->
<%
' ### DECLARE AND ASSIGN VARIABLES ###
Dim uploadNavCurrentPage : uploadNavCurrentPage = Trim(Request.ServerVariables("URL"))
uploadNavCurrentPage = Right(uploadNavCurrentPage, Len(uploadNavCurrentPage)-InStrRev(uploadNavCurrentPage,"/"))

Dim uploadDir : uploadDir = GetCurrentUploadDirectory("uploadDir")

SetCurrentUploadDirectory(uploadDir)

Dim fso : Set fso = Server.CreateObject("Scripting.FileSystemObject")
Dim serverPath : serverPath = RemoveTrailingSlash(Session("serverPath"))
serverPath = Replace(serverPath, "/", "\")
Dim uploadPath, parentPath

IF uploadDir <> "" THEN
    uploadPath = uploadDir
ELSE
    Dim userFolderName : userFolderName = "\" & Session("userLogin")
    uploadPath = "\" & RemoveTrailingSlash(Session("uploadPath")) & userFolderName
    IF NOT fso.FolderExists( serverPath & uploadPath) THEN fso.CreateFolder(serverPath & uploadPath)
END IF
uploadPath = RemoveTrailingSlash(uploadPath)

' ### ENSURE THERE IS A LEADING SLASH
IF Left(uploadPath,1) <> "\" THEN
    uploadPath = "\" & uploadPath
END IF

uploadPath = Replace(uploadPath, "/", "\")
Dim panelId : panelId = ""
IF Trim(Request("count") & "") <> "" THEN
    panelId = "panel-" & Request("count")
    Session("uploadPanelId") = panelId
ELSE
    panelId = Session("uploadPanelId")
END IF

Dim f
Dim uploadFolder : Set uploadFolder = fso.GetFolder( RemoveTrailingSlash(serverPath) & uploadPath)
Set parentFolder = uploadFolder.parentFolder
Dim parentFolder : parentPath = Left(uploadPath, InStrRev(uploadPath, "\")-1)
Dim maxColumns : maxColumns = 4
IF uploadNavMode = 1 THEN maxColumns = 5
IF uploadNavShowDetails = 1 THEN maxColumns = 8 ' ### CHANGE THIS TO INCLUDE EXTRA COLUMNS ###

Dim parentLink, childLink
IF parentPath <> "" THEN 
    IF uploadNavMode = 0 THEN
        parentLink = uploadNavCurrentPage & "?uploadDir=" & parentPath
    ELSEIF documentTabId <> "" THEN
        ' ### LINK FOR EXISTING DOCUMENTTAB RECORDS ###
        parentLink = uploadNavCurrentPage & "?documentTabId=" & documentTabId & "&extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & parentPath
    ELSEIF targetAccountId <> "" THEN
        ' ### LINK FOR NO ACCOUNT/COLLATERAL DOCUMENTTAB
        parentLink = uploadNavCurrentPage & "?customerId=" & customerId & "&loanId=" & targetAccountId & "&targetAccountId=" & targetAccountId & "&documentDefId=" & documentDefId & "&extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & parentPath
    ELSE
        ' ### LINK FOR NO CREDIT DOCUMENTTAB
        parentLink = uploadNavCurrentPage & "?customerId=" & customerId & "&loanId=" & targetAccountId & "&documentDefId=" & documentDefId & "&extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & parentPath
    END IF
    IF dash = "y" THEN
        parentLink = "include/dashpanels/" & parentLink
    END IF
    %>
    <table class="aa-upload-folder">
        <tr class="no-header">
            <% IF dash = "y" THEN %>
            <td><a href="javascript:void(0);" onclick="loadPanel('<%=Replace(parentLink, "\", "\\")%>', '<%=panelId%>')"><i class="aa-icon fas fa-arrow-up" aria-hidden="true" title="Move to Parent"></a></td>
            <% ELSE %>
            <td><a href="<%=parentLink%>"><i class="aa-icon fas fa-arrow-up" aria-hidden="true" title="Move to Parent"></a></td>
            <% END IF %>
            <td><i class="aa-icon fas fa-folder-open" aria-hidden="true"></i></td>
            <td colspan="<%=maxColumns-2%>"><%=uploadFolder.Name%></td>
        </tr>
    </table>
    <% END IF %>
    <table class="aa-upload-nav-table">
        <tr class="header">
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <% IF uploadNavMode = 1 THEN %>
            <td>&nbsp;</td>
            <% END IF %>
            <td>File Details</td>
            <% IF uploadNavShowDetails = 1 THEN %>
            <td>Type</td>
            <td>Date</td>
            <td>Size</td>
            <td>Uploaded By</td>
            <% END IF %>
        </tr>
        <%
        Dim i, filename, customerName, customerNumber, loanNumber, documentUploadId, documentTabName
        Dim documentTitle, documentComment, uploadedBy, description, displayFilename, tmpUploadPath
        Dim accountClassName

        Dim filesDisplayed : filesDisplayed = false

        ' ### DISPLAY THE SUB-FOLDER WITHIN THE CURRENT FOLDER ###
        FOR EACH f IN uploadFolder.SubFolders
            IF uploadNavMode = 0 THEN
                childLink = uploadNavCurrentPage & "?extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & uploadPath & "\" & f.Name
            ELSEIF documentTabId <> "" THEN
                childLink = uploadNavCurrentPage & "?documentTabId=" & documentTabId & "&extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & uploadPath & "\" & f.Name
            ELSEIF targetAccountId <> "" THEN
                childLink = uploadNavCurrentPage & "?customerId=" & customerId & "&loanId=" & targetAccountId & "&documentDefId=" & documentDefId & "&extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & uploadPath & "\" & f.Name
            ELSE
                childLink = uploadNavCurrentPage & "?customerId=" & customerId & "&documentDefId=" & documentDefId & "&extendedAccountClassCode=" & extendedAccountClassCode & "&uploadDir=" & uploadPath & "\" & f.Name
            END IF
            IF dash = "y" THEN
                childLink = "include/dashpanels/" & childLink
            END IF
        %>
        <tr>
            <td>&nbsp;</td>
            <% IF dash = "y" THEN %>
            <td><a href="javascript:void(0);" onclick="loadPanel('<%=Replace(childLink, "\", "\\")%>', '<%=panelId%>')"><i class="aa-icon fas fa-folder" aria-hidden="true" title="Open <%=f.name%>"></a></td>
            <% ELSE %>
            <td><a href="<%=childLink%>"><i class="aa-icon fas fa-folder" aria-hidden="true" title="Open <%=f.name%>"></a></td>
            <% END IF %>
            <td>&nbsp;</td>
            <td class="aa-tal" colspan="<%=maxColumns-3%>"><%=f.Name%></td>
        </tr>
        <%
        NEXT

        ' ### DISPLAY THE FILES WITHIN THE CURRENT FOLDER ###
        Dim tt1, tt2, tt3
        Dim ttTotal : ttTotal = 0
        Dim ttCount : ttCount = 0
        Dim idx : idx = 0
        FOR EACH f IN uploadFolder.Files
            tt1 = Timer()
            Dim fileExtension, fileSize, fileDate
            filesDisplayed = true
            Dim imagePath : imagePath = RemoveTrailingSlash(Session("serverPath")) & uploadPath & "\" & f.Name
            imagePath = Replace(imagePath, "/", "\")
            Dim escFileName : escFileName = EscapeJSStr(f.Name)
            Dim modifiedUploadPath : modifiedUploadPath = Replace(Right(uploadPath, Len(uploadPath)-1), "\", "/")
            modifiedUploadPath = Replace(modifiedUploadPath, "upload/", "")
            IF modifiedUploadPath = "upload" THEN
                modifiedUploadPath = ""
            END IF
            fileExtension = UCase(GetFileExtension(f.Name))
            Dim documentTypeIcon : documentTypeIcon = ""
            documentTypeIcon = GetDocumentTypeIcon(f.Name)

            Dim uploadViewFileRoute : uploadViewFileRoute = GetUploadFileViewUrl(modifiedUploadPath, escFileName, Session("userId"))
            
            uploadViewFileRoute = "OpenWindow('" & uploadViewFileRoute & "');"

            IF fileExtension = ".DB" THEN
                'fso.DeleteFile f.Path, true
            ELSE
                Dim fo : Set fo = fso.GetFile(f)
                customerName   = GetCustomerName(f.Name)
                description    = GetDescription(f.Name)
                filename       = GetFilename(f.Name)
                customerName   = ""
                customerNumber = ""
                loanNumber     = ""
                documentTitle  = f.Name
                fileDate       = fo.DateLastModified
                fileSize       = FormatFileSize(fo.Size)
                uploadedBy     = "---"

                Set viewDocumentAccess = Nothing

                IF g_documentUploadDict.Exists(LCase(f.Name)) THEN
                    i                = g_documentUploadDict(LCase(f.Name))
                    documentUploadId = g_documentUploadList(DU_DOCUMENT_UPLOAD_ID,i)
                    customerName     = g_documentUploadList(DU_CUSTOMER_NAME,i)
                    customerNumber   = g_documentUploadList(DU_CUSTOMER_NUMBER,i)
                    loanNumber       = g_documentUploadList(DU_LOAN_NUMBER,i)
                    documentTitle    = g_documentUploadList(DU_TITLE,i)
                    documentTabName  = g_documentUploadList(DU_TAB_NAME,i)
                    uploadedBy       = g_documentUploadList(DU_UPLOADED_BY,i)
                    accountClassName = g_documentUploadList(DU_ACCOUNT_CLASS_NAME,i)

                    customerIsEmployee        = g_documentUploadList(DU_CUSTOMER_IS_EMPLOYEE,i)
                    branchId                  = g_documentUploadList(DU_BRANCH_ID,i)
                    documentSubTypeId         = g_documentUploadList(DU_DOCUMENT_SUB_TYPE_ID,i)
                    accountClassCode          = g_documentUploadList(DU_ACCOUNT_CLASS_CODE,i)
                    hideEmployeeFileYN        = g_documentUploadList(DU_HIDE_EMPLOYEE_FILE_YN,i)
                    fileHasDemographicData    = g_documentUploadList(DU_HAS_DEMOGRAPHIC_DATA,i)
                    documentTabIsEmployeeFile = True And hideEmployeeFileYN = "Y"
                    isCustomerEmployeeFile    = customerIsEmployee And documentTabIsEmployeeFile
                    
                    IF loanNumber & "" <> "" Then
                        allowDocumentAccess = AllowAccountTabAccess(documentSubTypeId)
                    ELSE
                        allowDocumentAccess = AllowCreditTabAccess(documentSubTypeId)
                    END IF

                    Set viewDocumentAccess = usr.Security.HasDocumentViewAccess(accountClassCode, branchId, allowDocumentAccess, isCustomerEmployeeFile, fileHasDemographicData)

                    IF accountClassName <> "" THEN
                        accountClassName = " <i>(" & accountClassName & ")</i>"
                    END IF
                END IF
                %>
                <tr>
                    <% IF greyboxMode = 0 THEN %>
                    <td><% IF customerName <> "" THEN %><a href="javascript:void(0);" onclick="openKendoDialog('Document Upload Details', 'documentuploaddetails.asp?documentUploadId=<%=documentUploadId%>&greybox=<%=greyboxMode%>', 500, 700);"><i class="aa-icon fas fa-info-circle aa-color-info" aria-hidden="true" title="View Information"></i></a><% ELSE %>&nbsp;<% END IF %></td>
                    <% ELSE %>
                    <td><% IF customerName <> "" THEN %><a href="documentuploaddetails.asp?documentUploadId=<%=documentUploadId%>&greybox=<%=greyboxMode%>"><i class="aa-icon fas fa-info-circle aa-color-info" aria-hidden="true" title="View Information"></i></a><% ELSE %>&nbsp;<% END IF %></td>
                    <% END IF %>
                    <td><%
                    IF customerName <> "" And ( _
                        usr.Security.IsSuperUser _
                        Or usr.Security.UserAccountSecurityByAccountClass("credit").AllowDocUpload _
                        Or usr.Security.UserAccountSecurityByAccountClass("loan").AllowDocUpload _
                        Or usr.Security.UserAccountSecurityByAccountClass("loanapp").AllowDocUpload _
                        Or usr.Security.UserAccountSecurityByAccountClass("deposit").AllowDocUpload _
                        Or usr.Security.UserAccountSecurityByAccountClass("trust").AllowDocUpload) THEN
                        IF viewDocumentAccess.HasAccess THEN
                            IF greyboxMode = 0 THEN
                                %><a href="javascript:void(0);" onclick="openKendoDialog('Move Document', 'uploadquickmove.asp?documentUploadId=<%=documentUploadId%>&greybox=1', 500, 700);"><i class="aa-icon fas fa-arrow-right aa-quick-move-higlight" aria-hidden="true" title="Restore Document"></i></a><%
                            ELSE
                                %><a href="uploadquickmove.asp?documentUploadId=<%=documentUploadId%>&greybox=<%=greyboxMode%>"><i class="aa-icon fas fa-arrow-right aa-quick-move-higlight" aria-hidden="true" title="Restore Document"></i></a><%
                            END IF
                        ELSE
                            %><i class="aa-icon fas fa-arrow-right aa-file-view-disabled" aria-hidden="true" title="<%=viewDocumentAccess.Reason%>"></i><%    
                        END IF
                    ELSE
                        %>&nbsp;<%
                    END IF
                    %></td><%
                    IF viewDocumentAccess Is Nothing Then
                        %><td><a href="javascript:void(0);" onclick="<%=uploadViewFileRoute%>"><i class="<%=documentTypeIcon%>" aria-hidden="true" title="View <%=documentTitle%>"></i></a></td><%
                    ELSEIF viewDocumentAccess.HasAccess THEN
                        %><td><a href="javascript:void(0);" onclick="<%=uploadViewFileRoute%>"><i class="<%=documentTypeIcon%>" aria-hidden="true" title="View <%=documentTitle%>"></i></a></td><%
                    ELSE
                        %><td><i class="aa-icon lock fad fa-lock fa-fw aa-file-view-disabled" aria-hidden="true" title="<%=viewDocumentAccess.Reason%>" alt="View"></i></td><%
                    END IF
                    IF uploadNavMode = 1 THEN
                        Dim chkBoxDisabled : chkBoxDisabled = ""
                        IF Not (viewDocumentAccess Is Nothing) THEN
                            IF NOT viewDocumentAccess.HasAccess ThEN
                                chkBoxDisabled = "disabled"
                            END IF
                        END IF
                        %><td><input class="k-checkbox" id="uploadFileCheckbox_<%=idx%>" type="checkbox" name="imageURL" value="<%=imagePath%>" <%=chkBoxDisabled%>/><label class="k-checkbox-label" for="uploadFileCheckbox_<%=idx%>"></label></td><%
                    END IF
                    %><td class="file-wrapper"><%
                    IF customerName = "" THEN
                        Response.Write f.Name
                    ELSE
                        documentTitle = "<div class=""doc-title"" title=""" & documentTitle & """>" & Server.HTMLEncode(documentTitle) & "</div>"
                        IF uploadNavShowDetails = 1 THEN documentTitle = "<b>" & Server.HTMLEncode(documentTabName) & " :</b> " & documentTitle
                        %><a href="javascript:void(0);" onclick="openPageInParent('searchgen.asp?searchType=Standard&name=<%=customerName%>');"><%=Trim(GetCustomerNameMarkup(customerName) & " " & GetCustomerNumberMarkup(customerNumber))%></a> <a href="javascript:void(0);" onclick="openPageInParent('searchgen.asp?searchType=Standard&loan=<%=loanNumber%>');"><span class="aa-color-danger"><%=GetLoanNumberMarkup(loanNumber)%><%= accountClassName%></span></a> - <%=documentTitle%><%
                    END IF
                    %></td><%
                    IF uploadNavShowDetails = 1 THEN
                        %><td><%=fileExtension%></td>
                        <td><%=fileDate%></td>
                        <td class="aa-tar"><%=fileSize%></td>
                        <td><%=uploadedBy%></td><%
                    END IF
                %></tr><%
            END IF

            tt2 = Timer()
            tt3 = tt2-tt1
            ttCount = ttCount + 1
            ttTotal = ttTotal + tt3
            idx = idx + 1
        NEXT ' ### f

        IF NOT filesDisplayed THEN
        %>
        <tr>
            <td colspan="<%=maxColumns%>"><i>No Files to Upload.</i></td>
        </tr>
        <% END IF %>
</table>

<script type="text/javascript">
    function downloadUploadFile(fileURL, fileName) {
        if (!window.ActiveXObject) {
            var save = document.createElement('a');
            save.href = fileURL;
            save.target = '_blank';

            var filename = fileURL.substring(fileURL.lastIndexOf('/') + 1);
            save.download = fileName || filename;

            if (navigator.userAgent.toLowerCase().match(/(ipad|iphone|safari)/) && navigator.userAgent.search("Chrome") < 0) {

                document.location = save.href;

            } else {
                evt = document.createEvent("MouseEvent");
                evt.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);

                save.dispatchEvent(evt);
                (window.URL || window.webkitURL).revokeObjectURL(save.href);
            }
        }
        else if (!!window.ActiveXObject && document.execCommand) {
            var _window = window.open(fileURL, '_blank');
            _window.document.close();
            _window.document.execCommand('SaveAs', true, fileName || fileURL);
            _window.close();
        }
    }
</script>