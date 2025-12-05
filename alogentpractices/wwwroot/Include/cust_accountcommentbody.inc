<!-- BEGIN Loan Comment Tab Body -->
<% IF selectedLoanId <> "" THEN %>
<table class="aa-comment-body">
    <tr>
        <td colspan="3"><h3><%=selectedAccountClassName%> Comments</h3></td>
    </tr>
    <%
    Dim loanCommentRS : Set loanCommentRS = Server.CreateObject("ADODB.Recordset")
    Dim loanCommentQuery : loanCommentQuery = _
        " SELECT lc.loanCommentId, lc.comment, u.userFirstName, u.userLastName, u.UserId, lc.commentDate" &_
        " FROM [loanComments] as lc INNER JOIN [user] as u ON lc.userID = u.userID " &_
        " WHERE lc.loanId = " & dbFormatId(selectedLoanId) &_
        " ORDER by commentDate DESC" 
    loanCommentRS.Open loanCommentQuery, db, adOpenStatic
    IF NOT loanCommentRS.EOF THEN
        %>
        <tr class="header-cell">
            <td>&nbsp;</td>
            <td>User</td>
            <td>Comments</td>
        </tr>
        <%
        DO UNTIL loanCommentRS.EOF
            %>
            <tr class="data-row">
                <% IF Session("isSuperUser") OR Session(selectedAccountClassName & ".isAdmin") THEN %>
                <td><a href="commentdeleteconfirm.asp?commentId=<%=loanCommentRS("loanCommentId")%>&commentType=L&extendedAccountClassCode=<%=selectedAccountClassName%>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" title="Delete Comment" aria-hidden="true"></i></a></td>
                <% ELSE %>
                <td>&nbsp;</td>
                <% END IF %>
                <td class="aa-comment-user"><%=loanCommentRS("userFirstName") & " " & loanCommentRS("userLastName")%><br/><span><%=loanCommentRS("commentDate")%></span></td>
                <% IF Session("userID") = loanCommentRS("UserID") THEN %>
                <td class="aa-comment-list">
                    <ul>
                        <li><a href="javascript:void(0);" class="img_<%=RemoveCurlyBrackets(loanCommentRS("loanCommentID"))%>"><i class="aa-icon fas fa-pencil-alt fa-fw" title="Edit Comment" aria-hidden="true"></i></a></li>
                        <li><div class="aa-comment-container" id="text_<%=RemoveCurlyBrackets(loanCommentRS("loanCommentID"))%>"><%=loanCommentRS("comment")%></div></li>
                        <li>
                            <div id="form_<%=RemoveCurlyBrackets(loanCommentRS("loanCommentID"))%>">
                                <input type="text" class="k-input" name="input_<%=RemoveCurlyBrackets(loanCommentRS("loanCommentID"))%>" value="<%=loanCommentRS("comment")%>" size="40"/>
                                &nbsp;&nbsp;<a href="javascript:void(0);" class="btnSubmit2_<%=RemoveCurlyBrackets(loanCommentRS("loanCommentID"))%>"><i class="aa-icon far fa-save fa-fw" title="Save Changes" aria-hidden="true"></i></a>
                                &nbsp;<a href="javascript:void(0);" class="btnClear_<%=RemoveCurlyBrackets(loanCommentRS("loanCommentID"))%>"><i class="aa-icon fas fa-window-close fa-fw" title="Cancel" aria-hidden="true"></i></a>
                            </div>
                        </li>
                    </ul>
                </td>
                <% ELSE %>
                <td class="aa-comment-list">
                    <ul>
                        <li><i class="aa-icon fas fa-pencil-alt fa-fw aa-disabled" title="No Permission" aria-hidden="true"></i></li>
                        <li><div class="aa-comment-container"><%=loanCommentRS("comment")%></div></li>
                    </ul>
                </td>
                <% END IF %>
            </tr>
            <%
            loanCommentRS.MoveNext
        LOOP ' ### DO UNTIL loanCommentRS.EOF
    END IF
    loanCommentRS.Close
    Set loanCommentRS = Nothing
    %>

    <tr class="aa-comment-add-header">
        <td colspan="3"><h3>Add New <%=selectedAccountClassName%> Comment</h3></td>
    </tr>
    <tr class="aa-comment-add-wrapper">
        <td colspan="3">
            <form action="addcomments.asp" name="frmAddLoanComment" method="post">
                <input type="hidden" name="action" value="ADD"/>
                <input type="hidden" name="commentType" value="L"/>
                <div><textarea name="comment" class="k-textbox" rows="5" cols="60"></textarea></div>
                <div><button type="submit" class="k-button k-button-sm k-primary">Add Comment</button></div>
            </form>
        </td>
    </tr>
</table>
<% END IF %>
<!-- END Loan Comment Tab Body -->