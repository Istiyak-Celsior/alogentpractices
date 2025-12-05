<main class="inner">
    <%
    IF action = "ADD" AND computationType = "computed" THEN
        IF IsNumeric(grouptabmaint) AND grouptabmaint > 0 THEN
            %><div class="common"><i>The Document Tab <b><%=Server.HTMLEncode(documentSubTypeName)%></b> will be associated automatically when the exception is created.</i></div><%
            IF NOT IsNumeric(computationGracePeriod) THEN computationGracePeriod = 0
            %>
            <div class="common">You can set the default grace period for this type of exception.</div>
            <table class="aa-two-column-form-table">
                <tr>
                    <td><%=uCase(Left(statusTypeCheck,1))%><%=Right(statusTypeCheck, Len(statusTypeCheck)-1)%> Grace Period</td>
                    <td><input type="text" class="k-textbox" name="computationGracePeriod" value="<%=computationGracePeriod%>"/></td>
                </tr>
            </table>
            <%
        ELSE
            %><div class="common"><i>The Exception must be created first before documents can be assigned.</i></div><%
        END IF
    ELSEIF action = "EDIT" AND computationType = "computed" THEN
        Dim computationQuery
        Dim computationRS : Set computationRS = CreateObject("ADODB.RecordSet")

        addURL = _
            "exceptiondefmaint2.asp?" & _
            "action=ADD" & _
            "&exceptionDefId=" & exceptionDefId & _
            "&exceptionId=" & exceptionId & _
            "&targetType=" & targetType & _
            "&targetTypeId=" & targetTypeId & _
            "&targetId=" & targetId & _
            "&bankId=" & bankId & _
            "&activeTab=" & activeTab & _
            urlArgs

        computationQuery = _
            " SELECT" & _
            " 	cp.*," & _
            "   dd.customerTypeId," & _
            "   dd.loanTypeId," & _
            " 	dt.documentTypeName," & _
            " 	dst.documentSubTypeName" & _
            " FROM" & _
            " 	exceptionDefinition AS ed INNER JOIN computation AS cp" & _
            " 		ON ed.exceptionDefId = cp.exceptionDefId" & _
            " 	INNER JOIN documentDefinitions AS dd" & _
            " 		ON dd.documentDefId = cp.docDefId" & _
            " 	INNER JOIN documentType AS dt" & _
            " 		ON dt.documentTypeId = dd.documentTypeId" & _
            " 	INNER JOIN documentSubType AS dst" & _
            " 		ON dst.documentSubTypeId = dd.documentSubTypeId" & _
            " WHERE" & _
            " 	ed.exceptionDefId = " & dbFormatId(exceptionDefId)
        computationRS.Open computationQuery, db, adOpenStatic  
        %>
        <div class="common"><h3>Compound Computation</h3></div>
        <% IF computationRS.EOF THEN %><div class="common"><a href="<%=addURL%>">Add Document Type to Compute</a></div><% END IF %>
        <table class="aa-kendo-grid">
            <thead>
                <tr>
                    <th class="aa-tac">Delete</th>
                    <th class="aa-tac">Edit</th>
                    <th>Document Description</th>
                    <th class="aa-tac">Status Check</th>
                    <th class="aa-tac">Grace Period</th>
                </tr>
            </thead>
            <tbody>
                <%
                IF computationRS.EOF THEN 
                %><tr>
                    <td colspan="5">
                        This document exception does not have a document tab associated with it to track the exception yet. 
                        If you are a super user or administrator, you can configure this in Exception Maintenance or Required Document Maintenance.
                    </td>
                  </tr><%
                ELSE
                    Dim docTypeQuery
                    Dim docTypeRS : Set docTypeRS = Server.CreateObject("ADODB.RecordSet")

                    IF NOT IsNull(computationRS("customerTypeId")) THEN
                        docTypeQuery = "SELECT * FROM customerType WHERE customerTypeId=" & dbFormatId(computationRS("customerTypeId"))
                        docTypeFieldname = "customerTypeDescription"
                    ELSE
                        docTypeQuery = "SELECT * FROM loanType WHERE loanTypeId=" & dbFormatId(computationRS("loanTypeId"))
                        docTypeFieldname = "loanTypeDescription"
                    END IF
                    
                    docTypeRS.Open docTypeQuery, db, adOpenStatic, adCmdText

                    deleteURL = _
                        "exceptiondefcompupdate.asp?" & _
                        "action=DELETE" & _
                        "&computationId=" & computationRS("computationId") & _
                        "&exceptionDefId=" & computationRS("exceptionDefId") & _
                        "&exceptionDefType=" & exceptionDefType & _
                        urlArgs

                    editURL = _
                        "exceptiondefmaint2.asp?" & _
                        "action=EDIT" & _
                        "&computationId=" & computationRS("computationId") & _
                        "&exceptionDefId=" & exceptionDefId & _
                        "&exceptionId=" & exceptionId & _
                        "&targetType=" & targetType & _
                        "&targetTypeId=" & targetTypeId & _
                        "&targetId=" & targetId & _
                        "&bankId=" & bankId & _
                        "&activeTab=" & activeTab & _
                        urlArgs
                %><tr>
                    <td class="aa-tac"><a href="<%=deleteURL%>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete" aria-hidden="true"></i></a></td>
                    <td class="aa-tac"><a href="<%=editURL%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit" aria-hidden="true"></i></a></td>
                    <td><b>[<%=docTypeRS(docTypeFieldname)%>]</b> <%=computationRS("documentTypeName")%> / <%=Server.HTMLEncode(computationRS("documentSubTypeName"))%></td>
                    <td class="aa-tac"><%=computationRS("statusTypeCheck")%></td>
                    <td class="aa-tac"><%=computationRS("gracePeriod")%></td>
                </tr><% 
                    docTypeRS.Close
                    computationRS.Close
                END IF
               %>                
            </tbody>
        </table>
        <%
    END IF ' ### action = "ADD" AND computationType = "computed"
    IF compoundStatement <> modifiedCompoundStatement THEN
        ' ### Update the modified compoundStatement in the exceptionDefinition table. ###
        db.Execute "UPDATE exceptionDefinition SET compoundStatement='" & modifiedCompoundStatement & "' WHERE exceptionDefId=" & dbFormatId(exceptionDefId)
    END IF
    %>
</main>