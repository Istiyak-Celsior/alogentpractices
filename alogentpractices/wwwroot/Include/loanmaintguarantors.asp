<% IF action <> "NEWAPP" AND action <> "NEWLOAN" THEN %>
<div class="aa-widget" id="aa-loan-maint-guarantors">
    <% IF isCrossCollateralYN = "N" THEN %>
    <ul class="aa-document-header-list">
        <li><h2>Additional <%=GuarantorsOrSigners%></h2></li>
    </ul>
    <%
    Dim borrowerQuery, borrowerRS
    Set borrowerRS = CreateObject("ADODB.RecordSet")
    borrowerQuery = _
      " SELECT" & _
      "     c.customerId," & _
      "     c.customerName, " & _
      "     c.customerNumber," & _
      "     bt.borrowerTypeId," & _
      "     bt.borrowerTypeName," & _
      "     bt.borrowerTypeCode" & _
      " FROM" & _
      "     coborrower AS cb INNER JOIN customer AS c" & _
      "         ON cb.customerId=c.customerId" & _
      "     INNER JOIN borrowerType AS bt" & _
      "         ON bt.borrowerTypeId=cb.borrowerTypeId" & _
      " WHERE cb.loanId=" & dbFormatId(loanId) & _
      " ORDER BY customerName"
    borrowerRS.Open borrowerQuery, db
    %>
    <table class="aa-kendo-grid guarantors">
        <thead>
            <tr>
                <th>Delete</th>
                <th>Additional <%=GuarantorsOrSigners%> Name</th>
                <th><%=Left(GuarantorsOrSigners,len(GuarantorsOrSigners)-1)%> Type</th>
                <th>Customer Number</th>
            </tr>
        </thead>
        <%
        IF borrowerRS.EOF THEN
            %><tbody>
                <tr>
                    <td colspan="4">No additional <%=GuarantorsOrSigners%> on this <%=typeNameString%>.</td>
                </tr>
            </tbody><%
        ELSE
            DO UNTIL borrowerRS.EOF
                borrowerTypeName = borrowerRS("borrowerTypeName")
                %>
                <tbody>
                    <tr>
                        <td><%
                        IF hasCustomerBranchAccess(borrowerRS("customerId")) THEN
                            %><a href="borrowerdeleteconfirm.asp?action=DELBORROWER&borrowerCustomerId=<%=borrowerRS("customerId")%>&customerId=<%=customerId%>&loanId=<%=loanId%>&loanTypeId=<%=loanTypeId%>&bankId=<%=bankId%>&GOS=<%=GuarantorsOrSigners%>&AT=<%=typeNameString%>&accountClassId=<%=accountClassId%>" class="aa-command-link"><i class="aa-icon fas fa-trash-alt fa-fw" aria-hidden="true" title="Delete"></i></a><%
                        ELSE
                            %><i class="aa-icon fas fa-trash-alt fa-fw disabled" aria-hidden="true"></i><%
                        END IF
                        %></td>
                        <td><%
                        IF NOT hasCustomerBranchAccess(borrowerRS("customerId")) And Session("bankSecurity") = "DU" THEN
                            %><%=borrowerRS("customerNumber")%><%
                        ELSE
                            %><a href="customermaint.asp?state=INITIAL&action=EDIT&customerId=<%=borrowerRS("customerId")%>"><%=borrowerRS("customerName")%></a><%
                        END IF
                        %></td>
                        <td><%=borrowerTypeName%></td>
                        <td><%=borrowerRS("customerNumber")%></td>
                    </tr>
                </tbody>
                <%
                borrowerRS.MoveNext
            LOOP
            %>
        </table>
        <%
        END IF ' ### borrower.eof
        borrowerRS.Close

        IF Session("isSuperUser") _
            OR (Session(extAccountClassCode & ".isAdmin") _
                OR Session(extAccountClassCode & ".allowEdit") _
                OR Session(extAccountClassCode & ".allowAdd") _
                AND allowLoanBranchAccess) THEN
                %>
                <table class="aa-two-column-form-table">
                    <tr class="aa-no-background-color narrow">
                        <td colspan="2"></td>
                    </tr>
                    <tr class="aa-no-background-color">
                        <td colspan="2"><h2>Add New <%=Left(GuarantorsOrSigners, LEN(GuarantorsOrSigners)-1)%></h2></td>
                    </tr>
                    <tr class="aa-no-background-color">
                        <td colspan="2"><i>Type in Customer Name or Number you wish to add.</i></td>
                    </tr>
                    <tr>
                        <td>Customer Name:</td>
                        <td><input id="combo_borrower_cname" autocomplete="off" style="width:350px" />
                        <input type="hidden" id="borrower-customer-id" name="borrowerCustomerId" value=""/></td>
                    </tr>
                    <tr>
                        <td>Customer Number:</td>
                        <td><input id="combo_borrower_cnumber" autocomplete="off" style="width:350px" />
                        <input type="hidden" id="borrower-customer-id2" name="borrowerCustomerId2" value=""/></td>
                    </tr>
                    <tr>
                        <td><%=Left(GuarantorsOrSigners,len(GuarantorsOrSigners)-1)%> Type:</td>
                        <td><select name="borrowerTypeId" id="uxBorrowerTypeId">
                        <option value="">Select Type...</option><%
                        kendoSelectList = kendoSelectList & "uxBorrowerTypeId,"
                        Dim borrowerTypeRS : Set borrowerTypeRS = Server.CreateObject("ADODB.RecordSet")
                        Dim borrowerTypeQuery : borrowerTypeQuery = "SELECT borrowerTypeId, borrowerTypeName FROM borrowerType WHERE accountClassId=" & dbFormatId(accountClassId) & " ORDER BY borrowerTypeName"
                        borrowerTypeRS.Open borrowerTypeQuery, db
                        DO UNTIL borrowerTypeRS.EOF
                            Response.Write "<option value=""" & borrowerTypeRS("borrowerTypeId") & """>" & borrowerTypeRS("borrowerTypeName") & "</option>" & vbCr
                            borrowerTypeRS.MoveNext
                        LOOP
                        borrowerTypeRS.Close
                        %></select></td>
                    </tr>
                </table>
        <% END IF %>
    <% END IF ' ### isCrossCollateralYN = "N" %>
</div>
<% ELSE %>
<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><i>-The Guarantor options will appear after creating the application by clicking the UPDATE BUTTON-</i></b>
<% END IF %>