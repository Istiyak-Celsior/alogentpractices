<main class="inner">
    <%
    Dim exceptionHistoryRS : Set exceptionHistoryRS = CreateObject("ADODB.RecordSet")
    Dim exceptionHistoryQuery : exceptionHistoryQuery = _
        " SELECT eh.*, u.userFirstName, u.userMiddleInitial, u.userLastName" & _
        " FROM exceptionHistory AS eh INNER JOIN [user] AS u ON eh.changedByUserId=u.userId" & _
        " WHERE exceptionId=" & dbFormatId(exceptionId) & " ORDER BY dateChanged DESC"
    exceptionHistoryRS.Open exceptionHistoryQuery, db, adOpenStatic
    %>
    <table class="aa-kendo-grid history">
        <thead>
            <tr>
                <th>Date of Change</th>
                <th>Changed By</th>
                <th>Action Taken</th>
            </tr>
        </thead>
        <tbody>
            <% IF exceptionHistoryRS.EOF THEN %>
                <tr>
                    <td class="aa-tac" colspan="3">No History Records Were Found..</td>
                </tr>
            <% ELSE %>
                <% DO UNTIL exceptionHistoryRS.EOF
                    username = exceptionHistoryRS("userFirstName") & " " & exceptionHistoryRS("userMiddleInitial") & " " & exceptionHistoryRS("userLastName")
                    %>
                    <tr>
                        <td><%=exceptionHistoryRS("dateChanged")%></td>
                        <td><%=username%></td>
                        <td><%=exceptionHistoryRS("actionTaken")%></td>
                    </tr>
                    <%
                    exceptionHistoryRS.MoveNext
                LOOP
            END IF ' ### IF exceptionHistoryRS.EOF
            exceptionHistoryRS.Close
            %>
        </tbody>
    </table>
</main>