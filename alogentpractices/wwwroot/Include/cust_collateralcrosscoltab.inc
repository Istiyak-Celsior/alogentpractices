<% IF selectedCollateralTab = "crosscollateral" THEN %>
Cross Collaterals&nbsp;&nbsp;<i class="fas fa-circle aa-status-yes fa-fw" aria-hidden="true"></i>
<% ELSE %>
<a name="crosscollateral<%=targetCollateralLoanId%>" href="customer.asp?collateralTab=crosscollateral#collateralHeader">Cross Collaterals</a>&nbsp;&nbsp;<i class="fas fa-circle aa-status-yes fa-fw" aria-hidden="true"></i>
<% END IF %>