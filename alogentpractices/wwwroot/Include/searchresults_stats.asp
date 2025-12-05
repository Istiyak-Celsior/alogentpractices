<%
timeEnd = Timer()
timeDelta = timeEnd-timeStart
Session("searchResultTimeRender") = timeDelta

IF creditExceptCount = 0 THEN creditExceptCount = -1
IF accountExceptCount = 0 THEN accountExceptCount = -1
IF borrowerCounter = 0 THEN borrowerCounter = -1

IF Session("acculoan.enableDebugging") = 1 THEN
    IF docCount = 0 THEN
        avgDocumentAccess = "---"
    ELSE
        avgDocumentAccess = FormatNumber(docCountDelta/docCount,2) & " seconds"
    END IF

    IF creditExceptCount = 0 THEN
        avgCreditExceptionAccess = "---"
    ELSE
        avgCreditExceptionAccess = FormatNumber(creditExceptCountDelta/creditExceptCount,2) & " seconds"
    END IF

    IF accountExceptCount = 0 THEN
        avgAccountExceptionAccess = "---"
    ELSE
        avgAccountExceptionAccess = FormatNumber(accountExceptCountDelta / accountExceptCount,2) & " seconds"
    END IF

    IF borrowerCounter = 0 THEN
        avgBorrowerAccess = "---"
    ELSE
        avgBorrowerAccess = FormatNumber(borrowerCountDelta / borrowerCounter,2) & " seconds"
    END IF
    %>
    <div id="aa-search-debug-title">Debugging Information</div>
    <div id="aa-search-debug-panel">
        <table border="0">
            <tr>
                <td colspan="4">Page Render: <b><%=FormatNumber(timeDelta,2)%></b> seconds&nbsp;&nbsp;Query Load: <b><%=FormatNumber(queryDelta,2)%></b> seconds</td>
            </tr>
            <tr>
                <td>Average Document Access: <%=avgDocumentAccess %>; Total Time: <%=FormatNumber(docCountDelta,2)%> secs (<%=docCount%> calls)</td>
                <td>Average Credit Exception Access: <%=avgCreditExceptionAccess%>; Total Time: <%=FormatNumber(creditExceptionCountDelta,2)%> secs (<%=creditExceptCount%> calls)</td>
                <td>Average Account Exception Access: <%=avgAccountExceptionAccess%>; Total Time: <%=FormatNumber(accountExceptCountDelta,2)%> secs (<%=accountExceptCount%> calls)</td>
                <td>Average Borrower Access: <%=avgBorrowerAccess%>; Total Time: <%=FormatNumber(borrowerCountDelta,2)%> secs (<%=borrowerCounter%> calls)</td>
            </tr>
        </table>
    </div>
    <%
END IF
%>