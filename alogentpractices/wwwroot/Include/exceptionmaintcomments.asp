<main class="inner">
    <%
    Dim exceptionCommentRS : Set exceptionCommentRS = Server.CreateObject("ADODB.RecordSet")
    Dim exceptionCommentQuery : exceptionCommentQuery = _
        " SELECT ec.*, (u.userFirstName + ' ' + u.userMiddleInitial + ' ' + u.userLastName) AS userName" & _
        " FROM exceptionComment AS ec LEFT OUTER JOIN [user] AS u ON ec.userId=u.userId" & _
        " WHERE ec.exceptionId=" & dbFormatId(exceptionId) & _
        " ORDER BY ec.dateAdded ASC"
    exceptionCommentRS.Open exceptionCommentQuery, db
    IF exceptionCommentRS.EOF THEN %>
    <table class="aa-kendo-grid">
        <thead>
            <tr>
                <% IF Session("permissionException") > "1" THEN %>
                <th>Edit</th>
                <th>Delete</th>
                <% END IF %>
                <th>Added By</th>
                <th>Date Added</th>
                <th>Last Modified</th>
                <th>Comment</th>
            </tr>
        </thead>
        <tbody>
           <tr>
               <td colspan="6" class="aa-tac">No Comments Added</td>
           </tr>
        </tbody>
    </table>
    <% ELSE %>
    <table class="aa-kendo-grid">
        <thead>
            <tr>
                <% IF Session("permissionException") > "1" THEN %>
                <th>Edit</th>
                <th>Delete</th>
                <% END IF %>
                <th>Added By</th>
                <th>Date Added</th>
                <th>Last Modified</th>
                <th>Comment</th>
            </tr>
        </thead>
        <tbody>
            <%
            DO UNTIL exceptionCommentRS.EOF
                editLink = _
                    "exceptioncommentedit.asp?exceptionId=" & exceptionId & _ 
                    "&exceptionCommentId=" & exceptionCommentRS("exceptionCommentId")
                delLink = _
                    "exceptioncommentdeleteconfirm.asp?exceptionId=" & exceptionId & _ 
                    "&exceptionCommentId=" & exceptionCommentRS("exceptionCommentId")
                %><tr><%
                    IF Session("permissionException") > "1" THEN
                        %><td class="aa-tac"><a href="<%=editLink%>" class="aa-command-link"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Comment" aria-hidden="true"></i></a></td>
                        <td class="aa-tac"><a href="<%=delLink%>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete Comment" aria-hidden="true"></i></a></td><%
                    END IF
                    %><td><%=exceptionCommentRS("userName") %></td>
                    <td><%=FormatDateTime(exceptionCommentRS("dateAdded"),2)%></td>
                    <td><%=FormatDateTime(exceptionCommentRS("dateModified"),2)%></td>
                    <td><%=exceptionCommentRS("exceptionComment")%></td>
                </tr><%
                exceptionCommentRS.MoveNext
            LOOP
    END IF ' ### exceptionCommentRS.RecordCount = 0
    %></tbody>
    </table>
</main>