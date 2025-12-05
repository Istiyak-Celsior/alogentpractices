<div style="padding:10px">
<table class="aa-two-column-form-table">
    <tbody>
        <tr>
            <td>Tab Name: </td>
            <td>
                <input type="text" class="k-textbox" name="documentSubTypeName" size="60" maxlength="75" value="<%=Server.HTMLEncode(documentSubTypeName)%>"/>
                <input type="hidden" name="orgDocumentSubTypeName" value="<%=Server.HTMLEncode(orgDocumentSubTypeName)%>"/>
            </td>
        </tr>
        <% IF action <> "ADD" THEN %>
        <tr>
            <td>Folder Name:</td>
            <td>
                <div class="aa-static-content"><%=subTypeFolderName%></div>
                <input type="hidden" name="subTypeFolderName" value="<%=subTypeFolderName%>"/>
            </td>
        </tr>
        <% END IF %>
        <tr>
            <td>Document Code: </td>
            <td>
                <input type="text" class="k-textbox" name="documentCode" size="20" maxlength="50" value="<%=documentCode%>"/>
                <input type="hidden" name="orgDocumentCode" value="<%=documentCode%>"/>
            </td>
        </tr>
        <tr>
            <td>Default Status:</td>
            <td>
                <select id="aa-sub-type-default-status" name="subTypeDefaultStatus">
                    <option value="1" <% IF subTypeDefaultStatus = 1 THEN %> selected="selected"<% END IF %>>Required</option>
                    <option value="2" <% IF subTypeDefaultStatus = 2 THEN %> selected="selected"<% END IF %>>N/A</option>
                    <option value="3" <% IF subTypeDefaultStatus = 3 THEN %> selected="selected"<% END IF %>>Waived</option>
                </select>
            </td>
        </tr>
        <tr>
            <td>Track Views:</td>
            <td><input type="checkbox" class="k-checkbox" id="aa-track-views" name="trackViews" value="1" <% if subTrackViews then response.write "checked" end if %> /><label for="aa-track-views" class="k-checkbox-label"></label></td>
        </tr>
        <tr>
            <td>Require Expiration Date?</td>
            <td>
                <select id="aa-sub-type-require-exp-date" name="subTypeRequireExpDateYN">
                    <option value="N"<% IF subTypeRequireExpDateYN = "N" THEN %> selected="selected"<% END IF %>>No</option>
                    <option value="Y"<% IF subTypeRequireExpDateYN = "Y" THEN %> selected="selected"<% END IF %>>Yes</option>
                </select>
            </td>
        </tr>
        <tr>
            <td>Hide Employee File?</td>
            <td>
                <select id="aa-sub-type-hide-emp-file" name="subTypeHideEmployeeFileYN">
                    <option value="N"<% IF subTypeHideEmployeeFileYN = "N" THEN %> selected="selected"<% END IF %>>No</option>
                    <option value="Y"<% IF subTypeHideEmployeeFileYN = "Y" THEN %> selected="selected"<% END IF %>>Yes</option>
                </select>
            </td>
        </tr>
        <tr>
            <td>Contains Demographic Data</td>
            <td>
                <input type="checkbox" class="k-checkbox" id="aa-has-demographic-data" name="hasDemographicData" value="1" <% IF hasDemographicData THEN %> checked="checked"<% END IF %>/><label for="aa-has-demographic-data" class="k=-checkbox-label"></label>
            </td>
        </tr>
        <% IF Session("acculoan.showParticipationLoan") = 1 THEN %>
        <tr>
            <td>Block Participation?</td>
            <td><input type="checkbox" class="k-checkbox" id="aa-block-participation" name="blockParticipation" value="1"<% IF blockParticipation THEN %> checked="checked"<% END IF %>/><label for="aa-block-participation" class="k-checkbox-label"></label></td>
        </tr>
        <% END IF %>
        <% IF Session("acculoan.enablePDFModule") = 1 THEN %>
        <tr>
            <td>Enable Bookmarking PDF Documents:</td>
            <td><input type="checkbox" class="k-checkbox" id="uxBookmarkPdf" name="cbBookmarkPDF" value="1"<% IF bookmarkPdf THEN %> checked="checked"<% END IF %>/><label for="uxBookmarkPdf" class="k-checkbox-label"></label></td>
        </tr>
        <tr>
            <td>Enable Searchable PDF Documents:</td>
            <td><input type="checkbox" class="k-checkbox" id="uxIndexPdf" name="cbIndexPDF" value="1"<% IF indexPdf THEN %> checked="checked"<% END IF %>/><label for="uxIndexPdf" class="k-checkbox-label"></label></td>
        </tr>
        <% ELSE %>
        <tr class="hide">
            <td colspan="2">
                <input type="hidden" id="uxBookmarkPdf" name="cbBookmarkPDF" value="0"/>
                <input type="hidden" id="uxIndexPdf" name="cbIndexPDF" value="0"/>
            </td>
        </tr>
        <% END IF %>
        <tr>
            <td>Description:</td>
            <td><textarea name="subTypeDescription" class="k-textbox large" cols="" rows="4"><%=subTypeDescription%></textarea></td>
        </tr>
        <tr>
            <td>Instructions:</td>
            <td><textarea name="subTypeInstruction" class="k-textbox large" cols="" rows="4"><%=subTypeInstruction%></textarea></td>
        </tr>
        <% IF CanAccessPurge() AND Session("acculoan.enablePurgeAdvancedOptions") = "1" THEN %>
        <tr>
            <td>Block Purge State:</td>
            <td>
                <input type="checkbox" class="k-checkbox" id="aa-purge-state" name="cbPurgeState" id="cbBlockPurge" value="1"<% IF cBool(subPurgeState) THEN %> checked="checked"<% END IF %>/><label for="aa-purge-state" class="k-checkbox-label">Yes, Block Purge Changes</label>
            </td>
        </tr>
        <% END IF %>
    </tbody>
</table>
</div>