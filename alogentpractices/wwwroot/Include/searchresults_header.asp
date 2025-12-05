      <table class="noprint" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td><img src="images/nav/searchresults.gif" alt="Search Results"/></td>
          <td align="left">Below are the results of your search query.  Click on the customer name<br/>
            to view all accounts for that customer.  Click on the account description to <br/>
            see the specifics on only that account.
          </td>
        </tr>
      </table>

<div class="noprint">
	<br/>
	<br/>
</div>
<%
      Dim banner
		
      if UCase(searchType) = UCase("standard") then
        banner = "Search Results"
        matchType = "Document"
      elseif UCase(searchType) = UCase("existing") then
        banner = "Existing Document Search Results"
        matchType = "Document"
      elseif UCase(searchType) = UCase("missing") then
        banner = "Missing Document Search Results"
        matchType = "Document"
      elseif UCase(searchType) = UCase("expired") then
        banner = "Expired Document Search Results"
        matchType = "Document"
      elseif UCase(searchType) = UCase("waived") then
        banner = "Waived Document Search Results"
        matchType = "Document"
      elseif UCase(searchType) = UCase("exception") then
        banner = "Exception Search Results"
        matchType = "Exception"
      end if
%>

<div align="center"><h3><%=banner%></h3> </div>
<%	if maxResultExceeded then %>
<div style="text-align:center;"><span style="color:red; font-weight:bold;">Warning!</span> Max search results exceeded. Please refine your search.</div>
<br/>
<%	end if %>