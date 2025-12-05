<table class="aa-two-column-form-table">
    <tbody>
<%
	yesSelected = ""
	noSelected = ""
	if AccucaptureEnabled then
		yesSelected = "selected"
	else
		noSelected = "selected"
	end if
%> 
    <tr>
      <td class="slateredLabel">AccuCapture Enabled?</td>
      <td><select id="aa-accucapture-enabled" name="AccucaptureEnabled">
          <option value="0" <%=noSelected%>>No</option>
          <option value="1" <%=yesSelected%>>Yes</option>
        </select></td>
    </tr>
<%
	selected = "selected=""true"""
%>
    <tr>
      <td class="slateredLabel">Barcode/AccuCapture<br>Scan Rule</td>
      <td>
		    <select id="cbo_subTypeScanFlag" name="subTypeScanFlag">
			    <option value="0" <% if subTypeScanFlag = "0" then response.write selected end if %>>Always Create New Document</option>
			    <option value="1" <% if subTypeScanFlag = "1" then response.write selected end if %>>Insert pages into Newest Document</option>
			    <option value="2" <% if subTypeScanFlag = "2" then response.write selected end if %>>Insert pages into Oldest Document</option>
			    <option value="3" <% if subTypeScanFlag = "3" then response.write selected end if %>>Append pages into Newest Document</option>
			    <option value="4" <% if subTypeScanFlag = "4" then response.write selected end if %>>Append pages into Oldest Document</option>
		    </select>
		</td>
    </tr>
    </tbody>
</table>
<%	if action <> "ADD" then %>
<br />
<h2>Alternate Barcode Mappings</h2>
<table id="aa-barcode-map-table" class="aa-kendo-grid">
    <thead>
	    <tr>
		    <th>Action</th>
		    <th>Barcode Key</th>
	    </tr>
    </thead>
    <tbody>
<%
	Dim hasMappings
	Dim mappingQuery, mappingRS
	Set mappingRS = Server.CreateObject("ADODB.RecordSet")
	
	mappingQuery = "SELECT * FROM alternateBarcodeMap WHERE documentSubTypeId=" & dbFormatId(documentSubTypeId) & " ORDER BY barcodeKey"
	mappingRS.Open mappingQuery, db, adOpenStatic, adCmdText
	
	hasMappings = false
	do until mappingRS.eof
		hasMappings = true
%>
	<tr>
		<td><a href="docsubtypemaintupdate.asp?action=DELETE_MAPPING&documentTypeId=<%=documentTypeId%>&documentSubTypeId=<%=documentSubTypeId%>&alternateBarcodeMapId=<%=mappingRS("alternateBarcodeMapId")%>"><i class="fas fa-trash-alt" title="Delete Mapping"></i></a></td>
		<td>
			<input type="text" class="k-textbox" name="barcodeKey" value="<%=mappingRS("barcodeKey")%>" size="20" maxlength="128" />
			<input type="hidden" name="alternateBarcodeMapId" value="<%=mappingRS("alternateBarcodeMapId")%>" />
			<input type="hidden" name="orgBarcodeKey" value="<%=mappingRS("barcodeKey")%>" />
		</td>
	</tr>
<%
		mappingRS.MoveNext
	loop
	mappingRS.Close
	
	if Not hasMappings then
%>
	<tr>
		<td colspan="2">
			<i>No mappings defined yet.</i>
		</td>
	</tr>
<%	end if %>
    </tbody>
</table>
<%	end if ' documentSubTypeId <> "" %>	

<br>
    <h2>Add Additional Barcode Mappings</h2>
    <div class="aa-new-barcode-textbox">
        <input type="text" class="k-textbox" name="newBarcodeKey" value="" size="20" maxlength="128" />
    </div>
    <div class="aa-new-barcode-textbox">
        <input type="text" class="k-textbox" name="newBarcodeKey" value="" size="20" maxlength="128" />
    </div>
    <div class="aa-new-barcode-textbox">
        <input type="text" class="k-textbox" name="newBarcodeKey" value="" size="20" maxlength="128" />
    </div>
    <div class="aa-new-barcode-textbox">
        <input type="text" class="k-textbox" name="newBarcodeKey" value="" size="20" maxlength="128" />
    </div>
    <div class="aa-new-barcode-textbox">
        <input type="text" class="k-textbox" name="newBarcodeKey" value="" size="20" maxlength="128" />
    </div>