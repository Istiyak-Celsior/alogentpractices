<%
FUNCTION ReplaceUrlVariable(referer)
    Dim newQueryStr : newQueryStr = ""
    Dim serverUrl : serverUrl = RemoveTrailingSlash(Session("acculoan.serverURL")) & "/customerscan.asp?"
    Dim orgQueryStr : orgQueryStr = Replace(referer, serverUrl, "")
    Dim aryQueryStr : aryQueryStr = Split(orgQueryStr, "&")
    FOR i = 0 TO uBound(aryQueryStr)
        IF InStr(lCase(aryQueryStr(i)), "seltab") > 0 THEN
            aryQueryStr(i) = "seltab=a5"
        ELSEIF InStr(lCase(aryQueryStr(i)), "activetab") > 0 THEN
            aryQueryStr(i) = "seltab=a5"
        END IF
        newQueryStr = newQueryStr & aryQueryStr(i) & "&"
    NEXT

    ' Check when editing financial documents as only the documents tab is displayed so tab selection will be empty
    IF Trim(newQueryStr) = "" THEN
        newQueryStr = serverUrl
    ELSE
        newQueryStr = serverUrl & Left(newQueryStr, Len(newQueryStr) - 1)
    END IF

    ReplaceUrlVariable = newQueryStr
END FUNCTION

Dim CREDIT_DOC_SPAN : CREDIT_DOC_SPAN = 9
highlightColor = "#C6C6dA"
IF action <> "NEWAPP"  and action <> "NEWLOAN" then
    IF Session("isSuperUser") _
        OR ((Session("credit.isAdmin") _
        OR Session("credit.allowDocEdit") _
        OR Session(extAccountClassCode & ".isAdmin") _
        OR Session(extAccountClassCode & "allowDocEdit") ) _
        AND (allowCustomerBranchAccess Or allowLoanBranchAccess)) THEN

        IF isCrossCollateralYN = "N" THEN %>
        <div class="aa-widget" id="aa-loan-maint-documents">
            <% IF action = "EDITCUSTOMERDOCS" THEN %>
            <div>
                <ul class="aa-document-header-list">
                    <li><h2>Credit Documents</h2></li>
                    <%
                    Dim referer : referer = Request.ServerVariables("HTTP_REFERER")
                    Dim linkText

                    ' ### Must check to see if were coming from customer maintenance first. We may be coming from
                    ' customermaint.asp directly or indirectly from customerscanupdate with url argument (fromcustmaint)
                    IF Instr(referer, "customermaint.asp") > 0 OR Request("fromcustmaint") = "1" THEN
                        linkText = "Back to Customer Maintenance"
                        referer = "customermaint.asp?STATE=INITIAL&ACTION=EDIT&customerId=" & customerId
                    ELSE
                        IF Instr(referer, "customerscan.asp") > 0 THEN
                            Session("lastFinancialDocumentsHistory") = referer
                        ELSE
                            referer = Session("lastFinancialDocumentsHistory")
                        END IF
                        linkText = "Back to Account Documents"
                        referer = ReplaceUrlVariable(referer)
                        IF Instr(lCase(referer), "seltab") = 0 THEN referer = referer & "&seltab=a5"
                    END IF
                    Response.Write "<li><a href=""" & referer & """ class=""aa-command-button""><i class=""aa-icon fas fa-arrow-circle-left fa-fw"" title=""" & linkText & """ aria-hidden=""true""></i></a></li>" & vbCr
                    %>
                </ul>
            </div>
            <table id="aa-kendo-grid-document" style="table-layout:fixed">
                <thead>
                    <tr>
                        <th style="width:25%">Document Tab</th>
                        <th style="width:15%">Document Title</th>
                        <% IF Session("accuaccount.disableImaging") = 1 THEN %>
                            <th style="width:5%"><input type="checkbox" class="k-checkbox" id="select-all" /><label class="k-checkbox-label" id="all-label" for="select-all">All</label>&nbsp;<i class="aa-icon fas fa-question-circle aa-color-info fa-fw" id="question-icon" title="Check to set required documents to 'Has File'" aria-hidden="true"></i></th>
                        <% ELSE %>
                            <th style="width:5%">&nbsp;</th>
                        <% END IF %>
                        <th style="width:10%" class="aa-tac">Status</th>
                        <th style="width:10%" class="aa-tac">Document Date</th>
                        <th style="width:10%" class="aa-tac">Expiration Date</th>
                        <th style="width:10%" class="aa-tac">Non Expiring</th>
                        <th style="width:15%">Comment</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ' ### Get credit documents and display ###
                    Dim creditDocumentRS : Set creditDocumentRS = Server.CreateObject("ADODB.RecordSet")
                    Dim creditDocumentQuery : creditDocumentQuery = _
                        " SELECT" & _
                        "   dd.documentDefId," & _
                        "   dd.requireExpDate," & _
                        "   dd.sortOrder," & _
                        "   dd.docDefDocSortBy," & _
                        "   dd.documentTypeId," & _
                        "   dd.documentTypeName," & _
                        "   dd.documentSubTypeId," & _
                        "   dd.documentSubTypeName," & _
                        "   dd.subTypeInstruction," & _
                        "   dtab.documentTabId," & _
                        "   dtab.docTabStatusType," & _
                        "   d.documentId," & _
                        "   IsNull(d.documentTitle, dd.documentSubTypeName) AS documentTitle," & _
                        "   IsNull(d.documentStatus, 2) AS documentStatus," & _
                        "   IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) AS documentStatusType," & _
                        "   d.documentComment," & _
                        "   IsNull(d.loanFile, dd.defaultName) AS loanFile," & _
                        "   d.origDate," & _
                        "   d.modifiedDate," & _
                        "   CASE WHEN d.documentId IS NOT NULL THEN" & _
                        "       d.expDate" & _
                        "   ELSE" & _
                        "       dd.defaultExpDate" & _
                        "   END AS expDate," & _
                        "   IsNull(d.nonExpiring, 0) AS nonExpiring," & _
                        "   da.activationId," & _
                        "   da.activationStatus," & _
                        "   dd.defaultActivationStatus" & _
                        " FROM" & _
                        "   customer AS c INNER JOIN qryDocumentDefinitions AS dd" & _
                        "       ON c.customerTypeId=dd.customerTypeId" & _
                        "   LEFT OUTER JOIN documentTab AS dtab" & _
                        "       ON dtab.documentDefId=dd.documentDefId" & _
                        "       AND dtab.customerId=c.customerId" & _
                        "   LEFT OUTER JOIN [document] AS d" & _
                        "       ON d.documentTabId=dtab.documentTabId" & _
                        "       AND d.customerId=c.customerId" & _
                        "   LEFT OUTER JOIN documentActivation AS da" & _
                        "       ON da.customerId=c.customerId" & _
                        "       AND da.loanId IS NULL" & _
                        "       AND da.documentTypeId=dd.documentTypeId" & _
                        " WHERE" & _
                        "   c.customerId=" & dbFormatId(CustomerRS("customerId")) & _
                        "   AND dd.customerTypeId=" & dbFormatId(CustomerRS("customerTypeId")) & _
                        "   AND dd.bankId=" & dbFormatId(CustomerRS("bankId")) & _
                        "   AND IsNull(dd.HideTabYN,'N') LIKE 'N'" & _
                        "   AND (" & _
                        "       d.documentStatus=1" & _
                        "       OR (IsNull(da.activationStatus,dd.defaultActivationStatus) LIKE 'on')" & _
                        "   )" & _
                        " ORDER BY" & _
                        "   dd.sortOrder," & _
                        "   dd.documentTypeName," & _
                        "   dd.documentSubTypeName," & _
                        "   d.origDate DESC"
                    creditDocumentRS.Open creditDocumentQuery, db
                    oldGroupName = ""
                    oldTabName = ""
                    documentIdx = 1
                    DO UNTIL creditDocumentRS.EOF
                        ' ### Document Definition related properties ###
                        documentDefId = creditDocumentRS("documentDefId")
                        documentTabId = CheckForNull(creditDocumentRS("documentTabId"))
                        documentTypeId = creditDocumentRS("documentTypeId")
                        documentSubTypeId = creditDocumentRS("documentSubTypeId")
                        documentTypeName = creditDocumentRS("documentTypeName")
                        documentSubTypeName = creditDocumentRS("documentSubTypeName")
                        documentInstruction = creditDocumentRS("subTypeInstruction")
                        requireExpDate = creditDocumentRS("requireExpDate")

                        ' ### Document Related properties ###
                        documentStatus = creditDocumentRS("documentStatus")
                        documentStatusType = creditDocumentRS("documentStatusType")
                        documentOrigDate = creditDocumentRS("origDate")
                        documentExpDate = creditDocumentRS("expDate")
                        nonExpiring = CheckForNull(creditDocumentRS("nonExpiring"))
                        documentComment = creditDocumentRS("documentComment")

                        IF IsDate(documentOrigDate) THEN
                            documentOrigDate = FormatDateTime(documentOrigDate,2)
                        END IF

                        IF IsDate(documentExpDate) THEN
                            documentExpDate = FormatDateTime(documentExpDate,2)
                        END IF

                        ' ### Display the Group (documentType), but only once per occurance. ###
                        IF oldGroupName <> documentTypeName THEN
                            oldGroupName = documentTypeName
                            %>
                            <tr class="document-type-header">
                                <td colspan="<%=CREDIT_DOC_SPAN%>"><%=documentTypeName%></td>
                            </tr>
                            <%
                        END IF ' ### oldGroupName <> documentTypeName

                        ' ### Display document record. If this is the first time the tab is to be displayed then display
                        ' the tab name, otherwise don't show it for the mulitple documents. ###
                        IF oldTabName <> documentSubTypeName THEN
                            oldTabName = documentSubTypeName
                            displayTabName = documentSubTypeName
                        ELSE
                            displayTabName = ""
                        END IF ' ### oldTabName <> documentSubTypeName
                        %>
                        <tr>
                            <td>
                                <div class="tab-name-wrapper" title="<%=displayTabName%>"><%=Server.HTMLEncode(displayTabName)%></div>
                            </td>
                            <td><input type="text" class="k-textbox" name="documentTitle" size="30" maxlength="256" value="<%=Server.HTMLEncode(creditDocumentRS("documentTitle"))%>"/>
                            <input type="hidden" name="orgDocumentTitle" value="<%=Server.HTMLEncode(creditDocumentRS("documentTitle"))%>"/>
                            <input type="hidden" name="defaultDocumentTitle" value="<%=Server.HTMLEncode(creditDocumentRS("documentSubTypeName")) %>" />
                            <input type="hidden" name="documentId" value="<%=creditDocumentRS("documentId")%>"/>
                            <input type="hidden" name="documentDefId" value="<%=creditDocumentRS("documentDefId")%>"/>
                            <input type="hidden" name="documentTabId" value="<%=creditDocumentRS("documentTabId")%>"/>
                            <input type="hidden" name="documentTypeId" value="<%=creditDocumentRS("documentTypeId")%>"/>
                            <input type="hidden" name="documentSubTypeId" value="<%=creditDocumentRS("documentSubTypeId")%>"/>
                            <input type="hidden" name="docType" value="C"/>
                            <input type="hidden" name="documentIdx" value="<%=documentIdx%>"/>
                            <input type="hidden" name="loanFile" value="<%=creditDocumentRS("loanFile")%>"/>
                            <input type="hidden" name="requireExpDate" value="<%=creditDocumentRS("requireExpDate")%>"/></td>
                            <td><%
                            IF Session("accuaccount.disableImaging") = "0" THEN
                                IF documentStatus = "1" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-yes fa-fw"
                                ELSEIF documentStatus = "2" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-no fa-fw"
                                ELSEIF documentStatus = "3" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-pending fa-fw"
                                ELSEIF documentStatus = "4" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-no fa-fw"
                                ELSE
                                    imgStatus = "aa-icon fas fa-circle aa-status-no fa-fw"
                                END IF
                                %><i class="<%=imgStatus%>" aria-hidden="true"></i><%
                            ELSE
                                kendoSelectList = kendoSelectList & "cboCreditDocumentStatus" & documentIdx & ","
                                %><select name="documentStatus" id="cboCreditDocumentStatus<%=documentIdx%>" style="width:100px">
                                <option value="2"<% IF cInt(documentStatus) = 2 THEN %> selected="selected"<% END IF %>>No File</option>
                                <option value="1"<% IF cInt(documentStatus) = 1 THEN %> selected="selected"<% END IF %>>Has File</option>
                                </select><input type="hidden" name="orgDocumentStatus" value="<%=documentStatus%>"/>
                            <% END IF %></td>
                            <td><%
                            IF Session("isSuperUser") OR Session("credit.isAdmin") OR Session("credit.allowEdit") THEN
                                kendoSelectList = kendoSelectList & "cboDocumentStatusType" & documentIdx & ","
                                %><select name="documentStatusType" id="cboDocumentStatusType<%=documentIdx%>">
                                <option value="1"<% IF documentStatusType = 1 THEN %> selected="selected"<% END IF %>>Required</option><%
                                IF NOT documentStatus = 1 THEN
                                %><option value="2"<% IF documentStatusType = 2 THEN %> selected="selected"<% END IF %>>N/A</option><%
                                END IF
                                %><option value="3"<% IF documentStatusType = 3 THEN %> selected="selected"<% END IF %>>Waived</option>
                                </select><%
                            ELSE
                                %><input type="hidden" name="documentStatusType" value="<%=documentStatusType%>"/><%
                            END IF
                            %><input type="hidden" name="orgDocumentStatusType" id="orgDocumentStatusType<%=documentIdx%>" value="<%=documentStatusType%>"/></td>
                            <td><input type="text" class="k-textbox document-date" name="documentOrigDate" size="8" value="<%=documentOrigDate%>"/>
                            <input type="hidden" name="orgDocumentOrigDate" value="<%=documentOrigDate%>"/></td>
                            <td><%
                            IF creditDocumentRS("requireExpDate") THEN
                            %><input type="text" class="k-textbox document-date" name="documentExpDate" size="8" value="<%= documentExpDate %>"/><%
                            ELSE
                            %>---<input type="hidden" name="documentExpDate" value=""/><%
                            END IF
                            %><input type="hidden" name="orgDocumentExpDate" value="<%=creditDocumentRS("expDate")%>"/></td>
                            <td><%
                            IF creditDocumentRS("requireExpDate") THEN
                            %><input type="checkbox" class="k-checkbox" name="nonExpiring" id="nonExpiring<%=documentIdx%>" value="<%=documentIdx%>"<% IF nonExpiring THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="nonExpiring<%=documentIdx%>"></label><%
                            ELSE
                            %>---<%
                            END IF
                            %><input type="hidden" name="orgNonExpiring" value="<%=nonExpiring%>"/></td>
                            <td><input type="text" class="k-textbox" size="40" name="documentComment" value="<%=documentComment%>"/>
                            <input type="hidden" name="orgDocumentComment" value="<%=documentComment%>"/></td>
                        </tr>
                        <%
                        documentIdx = documentIdx + 1
                        creditDocumentRS.MoveNext
                    LOOP
                    creditDocumentRS.Close
                    %>
                </tbody>
            </table>
            <%
            END IF ' ### action = "EDITCUSTOMERDOCS"

            IF action <> "EDITCUSTOMERDOCS" AND isCrossCollateralYN = "N" THEN
            %>
            <div>
                <ul class="aa-document-header-list">
                    <li><h2><%=accountClassName%> Documents</h2></li>
                    <% IF Session("isSuperUser") OR Session("credit.isAdmin") OR Session("credit.allowEdit") OR Session("credit.allowAdd") THEN %>
                    <li><a href="customerscan.asp?state=INITIAL&action=EDITCUSTOMERDOCS&customerId=<%=customerId%>&bankid=<%=customerbankid%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Financial Documents" aria-hidden="true"></i></a></li>
                    <% END IF %>
                </ul>
            </div>
            <table id="aa-kendo-grid-document" style="table-layout:fixed">
                <thead>
                    <tr>
                        <th style="width:25%">Document Tab</th>
                        <th style="width:15%">Document Title</th>
                        <% IF Session("accuaccount.disableImaging") = 1 THEN %>
                            <th style="width:5%"><input type="checkbox" class="k-checkbox" id="select-all" /><label class="k-checkbox-label" id="all-label" for="select-all">All</label>&nbsp;<i class="aa-icon fas fa-question-circle aa-color-info fa-fw" id="question-icon" title="Check to set required documents to 'Has File'" aria-hidden="true"></i></th>
                        <% ELSE %>
                            <th style="width:5%">&nbsp;</th>
                        <% END IF %>
                        <th style="width:10%">Status</th>
                        <th style="width:10%">Document Date</th>
                        <th style="width:10%">Expiration Date</th>
                        <th style="width:10%">Non Expiring</th>
                        <th style="width:15%">Comment</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ' ### Get loan documents and display ###
                    Dim loanDocumentRS : Set loanDocumentRS = Server.CreateObject("ADODB.RecordSet")

                    documentIdx = 1

                    IF loanId = "" OR loanId = "0" THEN
                        ' ### New loan ###
                    ELSE
                        ' ### Existing loan ###
                        Dim loanDocumentQuery : loanDocumentQuery = _
                            " SELECT" & _
                            "   dd.documentDefId," & _
                            "   dd.requireExpDate," & _
                            "   dd.sortOrder," & _
                            "   dd.docDefDocSortBy," & _
                            "   dd.documentTypeId," & _
                            "   dd.documentTypeName," & _
                            "   dd.documentSubTypeId," & _
                            "   dd.documentSubTypeName," & _
                            "   dd.subTypeInstruction," & _
                            "   dtab.documentTabId," & _
                            "   dtab.docTabStatusType," & _
                            "   d.documentId," & _
                            "   IsNull(d.documentTitle, dd.documentSubTypeName) AS documentTitle," & _
                            "   IsNull(d.documentStatus, 2) AS documentStatus," & _
                            "   IsNull(d.documentStatusType, dd.defaultExistingDocumentStatusType) AS documentStatusType," & _
                            "   d.documentComment," & _
                            "   IsNull(d.loanFile, dd.defaultName) AS loanFile," & _
                            "   d.origDate," & _
                            "   d.modifiedDate," & _
                            "   CASE WHEN d.documentId IS NOT NULL THEN" & _
                            "       d.expDate" & _
                            "   ELSE" & _
                            "       dd.defaultExpDate" & _
                            "   END AS expDate," & _
                            "   IsNull(d.nonExpiring, 0) AS nonExpiring," & _
                            "   da.activationId," & _
                            "   da.activationStatus," & _
                            "   dd.defaultActivationStatus" & _
                            " FROM" & _
                            "   customer AS c INNER JOIN loan AS l" & _
                            "       ON c.customerId=l.customerId" & _
                            "   INNER JOIN qryDocumentDefinitions AS dd" & _
                            "       ON l.loanTypeId=dd.loanTypeId" & _
                            "       AND c.bankId=dd.bankId" & _
                            "   LEFT OUTER JOIN documentTab AS dtab" & _
                            "       ON dtab.documentDefId=dd.documentDefId" & _
                            "       AND dtab.loanId=l.loanId" & _
                            "   LEFT OUTER JOIN [document] AS d" & _
                            "       ON d.documentTabId=dtab.documentTabId" & _
                            "       AND d.loanId=l.loanId" & _
                            "   LEFT OUTER JOIN documentActivation AS da" & _
                            "       ON da.customerId=c.customerId" & _
                            "       AND da.loanId=l.loanId" & _
                            "       AND da.documentTypeId=dd.documentTypeId" & _
                            " WHERE" & _
                            "   l.loanId=" & dbFormatId(loanId) & _
                            "   AND dd.loanTypeId=" & dbFormatId(loanTypeId) & _
                            "   AND dd.bankId=" & dbFormatId(CustomerRS("bankId")) & _
                            "   AND IsNull(dd.HideTabYN,'N') LIKE 'N'" & _
                            "   AND (" & _
                            "       d.documentStatus=1" & _
                            "       OR (IsNull(da.activationStatus,dd.defaultActivationStatus) LIKE 'on')" & _
                            "   )" & _
                            " ORDER BY" & _
                            "   dd.sortOrder," & _
                            "   dd.documentTypeName," & _
                            "   dd.documentSubTypeName," & _
                            "   d.origDate DESC"
                    END IF
                    loanDocumentRS.Open loanDocumentQuery, db
                    oldGroupName = ""
                    oldTabName = ""
                    DO UNTIL loanDocumentRS.EOF
                        ' ### Document Definition related properties ###
                        documentDefId = loanDocumentRS("documentDefId")
                        documentTabId = CheckForNull(loanDocumentRS("documentTabId"))
                        documentTypeId = loanDocumentRS("documentTypeId")
                        documentSubTypeId = loanDocumentRS("documentSubTypeId")
                        documentTypeName = loanDocumentRS("documentTypeName")
                        documentSubTypeName = loanDocumentRS("documentSubTypeName")
                        documentInstruction = loanDocumentRS("subTypeInstruction")
                        requireExpDate = loanDocumentRS("requireExpDate")

                        ' ### Document Related properties ###
                        documentStatus = loanDocumentRS("documentStatus")
                        documentStatusType = loanDocumentRS("documentStatusType")
                        documentOrigDate = loanDocumentRS("origDate")
                        documentExpDate = loanDocumentRS("expDate")
                        nonExpiring = CheckForNull(loanDocumentRS("nonExpiring"))
                        documentComment = loanDocumentRS("documentComment")

                        IF IsDate(documentOrigDate) THEN
                            documentOrigDate = FormatDateTime(documentOrigDate,2)
                        END IF

                        IF IsDate(documentExpDate) THEN
                            documentExpDate = FormatDateTime(documentExpDate,2)
                        END IF

                        ' ### Display the Group (documentType), but only once per occurance. ###
                        IF oldGroupName <> documentTypeName THEN
                            oldGroupName = documentTypeName
                            %>
                            <tr class="document-type-header">
                                <td colspan="<%=CREDIT_DOC_SPAN%>"><%=documentTypeName%></td>
                            </tr>
                            <%
                        END IF ' ### oldGroupName <> documentTypeName

                        ' ### Display document record. If this is the first time the tab is to be displayed then display
                        ' the tab name, otherwise don't show it for the mulitple documents. ###
                        IF oldTabName <> documentSubTypeName THEN
                            oldTabName = documentSubTypeName
                            displayTabName = documentSubTypeName
                        ELSE
                            displayTabName = ""
                        END IF ' ### oldTabName <> documentSubTypeName
                        %>
                        <tr>
                            <td>
                                <div class="tab-name-wrapper" title="<%=displayTabName%>"><%=Server.HTMLEncode(displayTabName)%></div>
                            </td>
                            <td><input type="text" class="k-textbox" name="documentTitle" size="30" maxlength="256" value="<%=Server.HTMLEncode(loanDocumentRS("documentTitle"))%>"/>
                            <input type="hidden" name="orgDocumentTitle" value="<%=Server.HTMLEncode(loanDocumentRS("documentTitle"))%>"/>
                            <input type="hidden" name="defaultDocumentTitle" value="<%=Server.HTMLEncode(loanDocumentRS("documentSubTypeName")) %>" />
                            <input type="hidden" name="documentId" value="<%=loanDocumentRS("documentId")%>"/>
                            <input type="hidden" name="documentDefId" value="<%=loanDocumentRS("documentDefId")%>"/>
                            <input type="hidden" name="documentTabId" value="<%=loanDocumentRS("documentTabId")%>"/>
                            <input type="hidden" name="documentTypeId" value="<%=loanDocumentRS("documentTypeId")%>"/>
                            <input type="hidden" name="documentSubTypeId" value="<%=loanDocumentRS("documentSubTypeId")%>"/>
                            <input type="hidden" name="docType" value="L"/>
                            <input type="hidden" name="documentIdx" value="<%=documentIdx%>"/>
                            <input type="hidden" name="loanFile" value="<%=loanDocumentRS("loanFile")%>"/>
                            <input type="hidden" name="requireExpDate" value="<%=loanDocumentRS("requireExpDate")%>"/></td>
                            <td><%
                            IF Session("accuaccount.disableImaging") = "0" THEN
                                IF documentStatus = "1" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-yes fa-fw"
                                ELSEIF documentStatus = "2" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-no fa-fw"
                                ELSEIF documentStatus = "3" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-pending fa-fw"
                                ELSEIF documentStatus = "4" THEN
                                    imgStatus = "aa-icon fas fa-circle aa-status-no fa-fw"
                                ELSE
                                    imgStatus = "aa-icon fas fa-circle aa-status-no fa-fw"
                                END IF
                                %>
                                <i class="<%=imgStatus%>" aria-hidden="true"></i>
                            <% ELSE
                            kendoSelectList = kendoSelectList & "cboLoanDocumentStatus" & documentIdx & "," %>
                            <select name="documentStatus" id="cboLoanDocumentStatus<%=documentIdx%>" style="width:100px">
                            <option value="2"<% IF cInt(documentStatus) = 2 THEN %> selected="selected"<% END IF %>>No File</option>
                            <option value="1"<% IF cInt(documentStatus) = 1 THEN %> selected="selected"<% END IF %>>Has File</option>
                            </select>
                            <input type="hidden" name="orgDocumentStatus" value="<%=documentStatus%>" />
                            <% END IF %></td>
                            <td><%
                            IF Session("isSuperUser") OR Session(extAccountClassCode & ".isAdmin") OR Session(extAccountClassCode & ".allowDocEdit") THEN
                            kendoSelectList = kendoSelectList & "cboDocumentStatusType" & documentIdx & ","
                            %><select name="documentStatusType" id="cboDocumentStatusType<%=documentIdx%>" class="document-status">
                            <option value="1"<% IF documentStatusType = 1 THEN %> selected="selected"<% END IF %>>Required</option>
                            <option value="2"<% IF documentStatusType = 2 THEN %> selected="selected"<% END IF %>>N/A</option>
                            <option value="3"<% IF documentStatusType = 3 THEN %> selected="selected"<% END IF %>>Waived</option>
                            </select><%
                            ELSE
                            %><input type="hidden" name="documentStatusType" value="<%=documentStatusType%>"/><%
                            END IF
                            %><input type="hidden" name="orgDocumentStatusType" id="orgDocumentStatusType<%=documentIdx%>" value="<%=documentStatusType%>"/></td>
                            <td><input type="text" class="k-textbox document-date" name="documentOrigDate" size="8" value="<%=documentOrigDate%>"/>
                            <input type="hidden" name="orgDocumentOrigDate" value="<%=documentOrigDate%>"/></td>
                            <td><%
                            IF loanDocumentRS("requireExpDate") THEN
                            %><input type="text" class="k-textbox document-date" name="documentExpDate" size="8" value="<%= documentExpDate %>"/><%
                            ELSE
                            %>---<input type="hidden" name="documentExpDate" value=""/><%
                            END IF
                            %><input type="hidden" name="orgDocumentExpDate" value="<%=loanDocumentRS("expDate")%>"/></td>
                            <td><%
                            IF loanDocumentRS("requireExpDate") THEN
                            %><input type="checkbox" class="k-checkbox" name="nonExpiring" id="nonExpiring<%=documentIdx%>" value="<%=documentIdx%>"<% IF nonExpiring THEN %> checked="checked"<% END IF %>/><label class="k-checkbox-label" for="nonExpiring<%=documentIdx%>"></label><%
                            ELSE
                            %>---<%
                            END IF
                            %><input type="hidden" name="orgNonExpiring" value="<%=nonExpiring%>"/></td>
                            <td><input type="text" class="k-textbox" size="40" name="documentComment" value="<%=documentComment%>"/>
                            <input type="hidden" name="orgDocumentComment" value="<%=documentComment%>"/></td>
                        </tr>
                        <%
                        documentIdx = documentIdx + 1
                        loanDocumentRS.MoveNext
                    LOOP
                    loanDocumentRS.Close
                    %>
                </tbody>
            </table>
            </div>
            <%
            END IF ' ### action <> "EDITCUSTOMERDOCS"
        END IF ' ### isCrossCollateralYN = "N"
    END IF ' ### IF Session("isSuperUser")
ELSE
%>
<div>
    <table cellspacing="0" cellpadding="0" border="0">
        <tr class="h30">
            <td class="fb fi">-The Document options will appear after creating the application by clicking the UPDATE BUTTON-</td>
        </tr>
    </table>
</div>
<% END IF ' ### action <> "NEWAPP" And action <> "NEWLOAN" %>