<main class="inner">
<%
    IF exceptionRS("computationType") = "computed" THEN
        Dim computationQuery, computationRS
        Set computationRS = CreateObject("ADODB.RecordSet")

        computationQuery = _
            " SELECT" & _
            " 	cp.*," & _
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
            " 	ed.exceptionDefId = " & dbFormatId(exceptionRS("exceptionDefId"))
        computationRS.Open computationQuery, db, adOpenStatic  
%>
        <table class="aa-kendo-grid">
            <thead>
                <tr>
                    <th>Document Description</th>
                    <th>Status Check</th>
                    <th>Grace Period (Days)</th>
                </tr>
            </thead>
            <tbody>
                <%
                IF computationRS.EOF THEN 
                %><tr>
                    <td colspan="3">
                        This document exception does not have a document tab associated with it to track the exception yet. 
                        If you are a super user or administrator, you can configure this in Exception Maintenance or Required Document Maintenance.
                    </td>
                  </tr><%
                ELSE
                %><tr>
                    <td><%=computationRS("documentTypeName")%> / <%=Server.HTMLEncode(computationRS("documentSubTypeName") & "")%></td>
                    <td><%=computationRS("statusTypeCheck")%></td>
                    <td><%=computationRS("gracePeriod")%></td>
                </tr><% 
                END IF
            %></tbody>
        </table>
<%
        computationRS.Close
    END IF ' ### computationType = computed
%>
</main>