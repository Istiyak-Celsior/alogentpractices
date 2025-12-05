<%
	creditCommentTimeStart = Timer()
%>
<!-- BEGIN Credit Tab Comment Body -->
<table class="aa-comment-body">
    <tr>
        <td colspan="3"><h3>Customer Comments</h3></td>
    </tr>
    <%
    Dim Comments : Set Comments = Server.CreateObject("ADODB.Recordset")
    Dim CommentQuery : CommentQuery = _
        " SELECT " & _
        "   cc.commentId, " & _
        "   cc.customerid, " & _
        "   cc.userid, " & _
        "   cc.comment, " & _
        "   cc.date, " & _
        "   u.userId, " & _
        "   u.userFirstName, " & _
        "   u.userLastName " & _
        " FROM customerComments AS cc " & _
        "   INNER JOIN [user] AS u ON cc.userId = u.userId " & _
        " WHERE " & _
        "   cc.customerid = " & dbFormatId(selectedCustomerId) & _
        " ORDER BY cc.date DESC" 
    Comments.Open CommentQuery, db, adOpenStatic
    IF NOT Comments.EOF THEN
        %>
        <tr class="header-cell">
            <td>&nbsp;</td>
            <td>User</td>
            <td>Comments</td>
        </tr>
        <%
        DO UNTIL Comments.EOF
            %>
            <tr class="data-row">
                <% IF Session("isSuperUser") OR Session("credit.isAdmin") THEN %>
                <td><a href="commentdeleteconfirm.asp?commentId=<%=Comments("commentId")%>&commentType=C&extendedAccountClassCode=credit" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete Comment" aria-hidden="true"></i></a></td>
                <% ELSE %>
                <td>&nbsp;</td>
                <% END IF %>
                <td class="aa-comment-user"><%=Comments("userFirstName") & " " & Comments("userLastName")%><br/><span><%=Comments("date")%></span></td>
                <% IF Session("userID") = Comments("UserID") THEN %>
                <td class="aa-comment-list">
                    <ul>
                        <li><a href="javascript:void(0);" class="img_<%=RemoveCurlyBrackets(Comments("commentID"))%>"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Comment" aria-hidden="true"></i></a></li>
                        <li><div class="aa-comment-container" id="text_<%=RemoveCurlyBrackets(Comments("commentID"))%>"><%=Comments("comment")%></div></li>
                        <li>
                            <div id="form_<%=RemoveCurlyBrackets(Comments("commentID"))%>">
                                <input type="text" class="k-input" name="input_<%=RemoveCurlyBrackets(Comments("commentID"))%>" value="<%=Comments("comment")%>" size="40"/>
                                &nbsp;&nbsp;<a href="javascript:void(0);" class="btnSubmit_<%=RemoveCurlyBrackets(Comments("commentID"))%>"><i class="aa-icon far fa-save fa-fw" title="Save Changes" aria-hidden="true"></i></a>
                                &nbsp;<a href="javascript:void(0);" class="btnClear_<%=RemoveCurlyBrackets(Comments("commentID"))%>"><i class="aa-icon fas fa-window-close fa-fw" title="Cancel" aria-hidden="true"></i></a>
                            </div>
                        </li>
                    </ul>
                </td>
                <% ELSE %>
                <td class="aa-comment-list">
                    <ul>
                        <li><i class="aa-icon fas fa-pencil-alt fa-fw aa-disabled" title="No Permission" aria-hidden="true"></i></li>
                        <li><div class="aa-comment-container"><%=Comments("comment")%></div></li>
                    </ul>
                </td>
                <% END IF %>
            </tr>
            <%
            Comments.MoveNext
        LOOP ' ### Until Comments.EOF
    END IF
    Comments.Close
    Set Comments = Nothing
    %>
    <tr class="aa-comment-add-header">
        <td colspan="3"><h3>Add New Customer Comment</h3></td>
    </tr>
    <tr class="aa-comment-add-wrapper">
        <td colspan="3">
            <form action="addcomments.asp" name="frmAddCustomerComment" method="post">
                <input type="hidden" name="action" value="ADD"/>
                <input type="hidden" name="commentType" value="C"/>
                <div><textarea name="comment" class="k-textbox" rows="5" cols="60"></textarea></div>
                <div><button type="submit" class="k-button k-button-sm k-primary">Add Comment</button></div>
            </form>
        </td>
    </tr>
</table>
<!-- END Credit Tab Comment Body -->
<%
	creditCommentTimeStop = Timer()
	creditCommentTimeDelta = creditCommentTimeStop-creditCommentTimeStart
%>