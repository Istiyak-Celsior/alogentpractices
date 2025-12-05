<!-- #include file="../adovbs.inc" -->
<!-- #include file="../dbopen.inc" -->
<!-- #include file="../common.inc" -->
<!-- #include file="../security.inc" -->
<%
Dim searchBankId : searchBankId = ""
Dim searchBankQuery : searchBankQuery = ""
Dim searchBankRS : Set searchBankRS = Server.CreateObject("ADODB.RecordSet")
%>
<form name="frmQuickSearch" id="dash-quick-search" action="searchgen.asp" style="margin:0 40px" method="post">
    <input type="hidden" name="searchType" value="standard"/>
    <input type="hidden" name="searchPageSize" value="25" />
    <input type="hidden" name="bank" value="<%=searchBankId%>" />
    <div class="sub-title">Customer Name:</div>
    <div><input id="combo_zone_cname" name="name" autocomplete="off" style="width:270px" /></div>
    <div class="sub-title">Customer Number:</div>
    <div><input id="combo_zone_cnumber" name="customerID" autocomplete="off" style="width:270px" /></div>
    <div class="sub-title">Tax Id:</div>
    <div><input id="combo_zone_taxid" name="taxID" autocomplete="off" style="width:270px" /></div>
    <div class="sub-title">Account Number:</div>
    <div><input id="combo_zone_lnumber" name="loan" autocomplete="off" style="width:270px" /></div>
    <div class="button-wrapper"><button type="submit" class="k-button k-primary">Search</button></div>
</form>
<!-- #include file="../dbclose.inc" -->