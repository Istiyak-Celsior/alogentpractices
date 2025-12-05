<%
Customer.PageSize = cLng(pageSize)
pageCount = Customer.PageCount

IF cLng(Page) < 1 THEN
    page = 1
ELSEIF cLng(page) > cLng(pageCount) THEN
    page = pageCount
END IF
Customer.AbsolutePage = cLng(page)
%>
<div id="aa-pagination-wrapper">
    <%
    Response.Write "<div class=""pager"">"
    IF cLng(page) > 1 THEN
        Response.Write "<a href=""searchresults.asp?searchType=" & searchType & "&page=" & cLng(page) - 1 & expandLoanIdClause & """ aria-label=""Go to the previous page"" title=""Go to the previous page""><i class=""aa-icon fas fa-caret-left fa-fw"" aria-hidden=""true""></i></a>"
    END IF

    startIndex = cLng(Page) - 3
    lastIndex = cLng(Page) - 1
    IF cLng(startIndex) <= 2 THEN
        startIndex = 1
    END IF

    FOR i = startIndex TO lastIndex
        Response.Write "<a href=""searchresults.asp?searchType=" & searchType & "&page=" & i & expandLoanIdClause & """>" & i & "</a>"
    NEXT
    Response.Write "<a href=""#"" class=""selected""><b>" & Page & "</b></a>"

    startIndex = cLng(Page) + 1
    lastIndex = cLng(startIndex) + 2

    IF cLng(lastIndex) > cLng(pageCount) THEN
        lastIndex = cLng(pageCount)
    END IF

    FOR i = startIndex TO lastIndex
        Response.Write "<a href=""searchresults.asp?searchType=" & searchType & "&page=" & i & expandLoanIdClause & """>" & i & "</a>"
    NEXT

    IF cLng(page) < cLng(pageCount) THEN
        Response.Write "<a href=""searchresults.asp?searchType=" & searchType & "&page=" & cLng(page) + 1 & expandLoanIdClause & """ aria-label=""Go to the next page"" title=""Go to the next page""><i class=""aa-icon fas fa-caret-right fa-fw"" aria-hidden=""true""></i></a>"
    END IF
    Response.Write "</div>"

    IF displayJumpToBottom THEN
        displayJumpToBottom = false
        Response.Write "<div class=""page-bottom-wrapper"">" & vbCr _
                     & "<ul>" & vbCr _
                     & "<li><button type=""button"" class=""k-button k-primary"" onclick=""location.href='" & ParseHtmlPage(Request("URL")) & "?" & Request("Query_String") & "#pageBottom';"">Jump To Bottom</button></li>" & vbCr _
                     & "<li><a href=""searchresultsgrid.asp?searchType=" & searchType & "&interfaceSearch=" & interfaceSearch & """>View Grid</a></li>" & vbCr _
                     & "</ul>" & vbCr _
                     & "</div>" & vbCr
    END IF
    %>
</div>