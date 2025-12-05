<% IF collateralCount > 1 THEN %>
<div class="aa-account-options">
    <ul>
        <li><a href="javascript:void(0);"  onclick="openKendoDialog('View Collateral Listing', 'collaterallist.asp?loanId=<%=selectedLoanId%>&accountClassCode=<%=selectedAccountClassCode%>', 500, 700);">View Collaterals (<%=collateralCount%>)</a></li>
    </ul>
</div>
<% END IF %>