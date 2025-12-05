<%
IF action <> "NEWAPP" AND action <> "NEWLOAN" THEN
    Dim maxLengthRS : Set maxLengthRS = Server.CreateObject("ADODB.RecordSet")
    Dim maxLengthQuery : maxLengthQuery = "SELECT TOP 1 LEN(naicsCode) AS maxCodeLength FROM naicsCode ORDER BY LEN(NaicsCode) DESC"
    maxLengthRS.Open maxLengthQuery, db
    Dim maxCodeLength : maxCodeLength = 0
    IF NOT maxLengthRS.EOF THEN
        maxCodeLength = maxLengthRS("maxCodeLength")
    END IF
    maxLengthRS.Close()
    %>
    <div class="aa-widget" id="aa-loan-maint-codes">
        <h2 class="top">Loan Codes</h2>
        <table class="aa-form-table">
            <tr>
                <td>NAICS:</td>
                <%
                imgLock = "unlock"
                IF lockCoreNaicsCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCoreNaicsCode" name="lockCoreNaicsCode" value="<%=lockCoreNaicsCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCoreNaicsCode"></i></td>
                <% kendoSelectList = kendoSelectList & "naics-code," %>
                <td><select id="naics-code" name="naicsCode">
                <option value="">Select NAICS Code</option><%
                maxLengthQuery = "SELECT TOP 1 LEN(naicsCode) AS maxCodeLength FROM naicsCode ORDER BY LEN(NaicsCode) DESC"
                maxLengthRS.Open maxLengthQuery, db
                maxCodeLength = 0
                IF NOT maxLengthRS.EOF THEN
                    maxCodeLength = maxLengthRS("maxCodeLength")
                END IF
                maxLengthRS.Close()

                Dim naicsCodeRS : Set naicsCodeRS = Server.CreateObject("ADODB.RecordSet")
                Dim naicsCodeQuery : naicsCodeQuery = _
                    " SELECT" & _
                    "   naicsCodeId," & _
                    "   ('[ ' + naicsCode + ' ] ' + naicsCodeDescription) AS naicsCodeDescription," & _
                    "   naicsCode" & _
                    " FROM naicsCode" & _
                    " ORDER BY RIGHT(REPLICATE('0', @maxCodeLength) + naicsCode, @maxCodeLength) ASC, naicsCode.naicsCodeDescription"
                naicsCodeQuery = Replace(naicsCodeQuery, "@maxCodeLength", maxCodeLength)
                naicsCodeRS.Open naicsCodeQuery, db
                DO UNTIL naicsCodeRS.EOF
                    strSelected = ""
                    IF cStr(naicsCodeRS("naicsCode")) = cStr(naicsCode) THEN
                        strSelected = " selected=""selected"""
                    END IF
                    Response.Write "<option value=""" & naicsCodeRS("naicsCode") & """" & strSelected & ">" & naicsCodeRS("naicsCodeDescription") & "</option>" & vbCr
                    naicsCodeRS.MoveNext
                LOOP
                naicsCodeRS.Close
                %></select></td>
            </tr>
            <tr>
                <td>Primary Collateral Code:</td>
                <%
                imgLock = "unlock"
                IF lockCoreCollateralCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCoreCollateralCode" name="lockCoreCollateralCode" value="<%=lockCoreCollateralCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCoreCollateralCode"></i></td>
                <% kendoSelectList = kendoSelectList & "collateral-code-id," %>
                <td><select name="collateralCodeId" id="collateral-code-id">
                <option value="">Select Collateral Code</option><%
                maxLengthQuery = "SELECT TOP 1 LEN(collateralCode) AS maxCodeLength FROM collateralCode ORDER BY LEN(collateralCode) DESC"
                maxLengthRS.Open maxLengthQuery, db
                maxCodeLength = 0
                IF NOT maxLengthRS.EOF THEN
                    maxCodeLength = maxLengthRS("maxCodeLength")
                END IF
                maxLengthRS.Close()

                Dim collateralCodeRS : Set collateralCodeRS = Server.CreateObject("ADODB.RecordSet")
                Dim collateralCodeQuery : collateralCodeQuery = _
                    " SELECT" & _
                    "   collateralCodeId," & _
                    "   ('[ ' + collateralCode + ' ] ' + collateralCodeDescription) AS collateralCodeDescription," & _
                    "   collateralCode" & _
                    " FROM collateralCode" & _
                    " ORDER BY RIGHT(REPLICATE('0', @maxCodeLength) + collateralCode, @maxCodeLength) ASC, collateralCode.collateralCodeDescription"
                collateralCodeQuery = Replace(collateralCodeQuery, "@maxCodeLength", maxCodeLength)
                collateralCodeRS.Open collateralCodeQuery, db
                DO UNTIL collateralCodeRS.EOF
                    strSelected = ""
                    IF cStr(collateralCodeRS("collateralCode")) = cStr(collateralCode) THEN
                        strSelected = "selected=""selected"""
                    END IF
                    Response.Write "<option value=""" & collateralCodeRS("collateralCode") & """ " & strSelected & ">" & collateralCodeRS("collateralCodeDescription") & "</option>" & vbCr
                    collateralCodeRS.MoveNext
                LOOP
                collateralCodeRS.Close
                %></select></td>
            </tr>
            <tr>
                <td>Type Code:</td>
                <%
                imgLock = "unlock"
                IF lockCoreTypeCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCoreTypeCode" name="lockCoreTypeCode" value="<%=lockCoreTypeCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCoreTypeCode"></i></td>
                <% kendoSelectList = kendoSelectList & "type-code-id," %>
                <td><select name="typeCodeId" id="type-code-id">
                <option value="">Select Type Code</option><%
                maxLengthQuery = "SELECT TOP 1 LEN(typeCode) AS maxCodeLength FROM typeCode ORDER BY LEN(typeCode) DESC"
                maxLengthRS.Open maxLengthQuery, db
                maxCodeLength = 0
                IF NOT maxLengthRS.EOF THEN
                    maxCodeLength = maxLengthRS("maxCodeLength")
                END IF
                maxLengthRS.Close()

                Dim typeCodeRS : Set typeCodeRS = Server.CreateObject("ADODB.RecordSet")
                Dim typeCodeQuery : typeCodeQuery = _
                    " SELECT" & _
                    "   typeCodeId," & _
                    "   ('[ ' + typeCode + ' ] ' + typeCodeDescription) AS typeCodeDescription," & _
                    "   typeCode" & _
                    " FROM typeCode" & _
                    " ORDER BY RIGHT(REPLICATE('0', @maxCodeLength) + typeCode, @maxCodeLength) ASC, typeCode.typeCodeDescription"
                typeCodeQuery = Replace(typeCodeQuery, "@maxCodeLength", maxCodeLength)
                typeCodeRS.Open typeCodeQuery, db
                DO UNTIL typeCodeRS.EOF
                    strSelected = ""
                    IF cStr(typeCodeRS("typeCode")) = cStr(typeCode) THEN
                        strSelected = "selected=""selected"""
                    END IF
                    Response.Write "<option value=""" & typeCodeRS("typeCode") & """ " & strSelected & ">" & typeCodeRS("typeCodeDescription") & "</option>" & vbCr
                    typeCodeRS.MoveNext
                LOOP
                typeCodeRS.Close
                %></select></td>
            </tr>
            <tr>
                <td>Purpose Code:</td>
                <%
                imgLock = "unlock"
                IF lockCorePurposeCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCorePurposeCode" name="lockCorePurposeCode" value="<%=lockCorePurposeCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCorePurposeCode"></i></td>
                <% kendoSelectList = kendoSelectList & "purpose-code-id," %>
                <td><select name="purposeCodeId" id="purpose-code-id">
                <option value="">Select Purpose Code</option><%
                maxLengthQuery = "SELECT TOP 1 LEN(purposeCode) AS maxCodeLength FROM purposeCode ORDER BY LEN(purposeCode) DESC"
                maxLengthRS.Open maxLengthQuery, db
                maxCodeLength = 0
                IF NOT maxLengthRS.EOF THEN
                    maxCodeLength = maxLengthRS("maxCodeLength")
                END IF
                maxLengthRS.Close()

                Dim purposeCodeRS : Set purposeCodeRS = Server.CreateObject("ADODB.RecordSet")
                Dim purposeCodeQuery : purposeCodeQuery = _
                    " SELECT" & _
                    "   purposeCodeId," & _
                    "   ('[ ' + purposeCode + ' ] ' + purposeCodeDescription) AS purposeCodeDescription," & _
                    "   purposeCode" & _
                    " FROM purposeCode" & _
                    " ORDER BY RIGHT(REPLICATE('0', @maxCodeLength) + purposeCode, @maxCodeLength) ASC, purposeCode.purposeCodeDescription"
                purposeCodeQuery = Replace(purposeCodeQuery, "@maxCodeLength", maxCodeLength)
                purposeCodeRS.Open purposeCodeQuery, db

                DO UNTIL purposeCodeRS.EOF
                    strSelected = ""
                    IF cStr(purposeCodeRS("purposeCode")) = cStr(purposeCode) THEN
                        strSelected = "selected=""selected"""
                    END IF
                    Response.Write "<option value=""" & purposeCodeRS("purposeCode") & """ " & strSelected & ">" & purposeCodeRS("purposeCodeDescription") & "</option>" & vbCr
                    purposeCodeRS.MoveNext
                LOOP
                purposeCodeRS.Close
                %></select></td>
            </tr>
            <tr>
                <td>Call Code:</td>
                <%
                imgLock = "unlock"
                IF lockCoreCollCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCoreCollCode" name="lockCoreCollCode" value="<%=lockCoreCollCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCoreCollCode"></i></td>
                <% kendoSelectList = kendoSelectList & "coll-code-id," %>
                <td><select name="collCodeId" id="coll-code-id">
                <option value="">Select Call Code</option><%
                maxLengthQuery = "SELECT TOP 1 LEN(collCode) AS maxCodeLength FROM collCode ORDER BY LEN(collCode) DESC"
                maxLengthRS.Open maxLengthQuery, db
                maxCodeLength = 0
                IF NOT maxLengthRS.EOF THEN
                    maxCodeLength = maxLengthRS("maxCodeLength")
                END IF
                maxLengthRS.Close()

                Dim collCodeRS : Set collCodeRS = Server.CreateObject("ADODB.RecordSet")
                Dim collCodeQuery : collCodeQuery = _
                    " SELECT" & _
                    "   collCodeId," & _
                    "   ('[ ' + collCode + ' ] ' + collCodeDescription) AS collCodeDescription," & _
                    "   collCode" & _
                    " FROM collCode" & _
                    " ORDER BY RIGHT(REPLICATE('0', @maxCodeLength) + collCode, @maxCodeLength) ASC, collCode.collCodeDescription"
                collCodeQuery = Replace(collCodeQuery, "@maxCodeLength", maxCodeLength)
                collCodeRS.Open collCodeQuery, db

                DO UNTIL collCodeRS.EOF
                    strSelected = ""
                    IF cStr(collCodeRS("collCode")) = cStr(collCode) THEN
                        strSelected = "selected=""selected"""
                    END IF
                    Response.Write "<option value=""" & collCodeRS("collCode") & """ " & strSelected & ">" & collCodeRS("collCodeDescription") & "</option>" & vbCr
                    collCodeRS.MoveNext
                LOOP
                collCodeRS.Close
                %></select></td>
            </tr>
            <tr>
                <td>Class Code:</td>
                <%
                imgLock = "unlock"
                IF lockCoreClassCode THEN imgLock = "lock"
                %>
                <td><input type="hidden" id="hidLockCoreClassCode" name="lockCoreClassCode" value="<%=lockCoreClassCode%>"/><i class="aa-icon fas fa-<%=imgLock%>" aria-hidden="true" id="imgLockCoreClassCode"></i></td>
                <% kendoSelectList = kendoSelectList & "class-code-id," %>
                <td><select name="classCodeId" id="class-code-id">
                <option value="">Select Class Code</option><%
                maxLengthQuery = "SELECT TOP 1 LEN(classCode) AS maxCodeLength FROM classCode ORDER BY LEN(classCode) DESC"
                maxLengthRS.Open maxLengthQuery, db
                maxCodeLength = 0
                IF NOT maxLengthRS.EOF THEN
                    maxCodeLength = maxLengthRS("maxCodeLength")
                END IF
                maxLengthRS.Close()

                Dim classCodeRS : Set classCodeRS = Server.CreateObject("ADODB.RecordSet")
                Dim classCodeQuery : classCodeQuery = _
                    " SELECT" & _
                    "   classCodeId," & _
                    "   ('[ ' + classCode + ' ] ' + classCodeDescription) AS classCodeDescription," & _
                    "   classCode" & _
                    " FROM classCode" & _
                    " ORDER BY RIGHT(REPLICATE('0', @maxCodeLength) + classCode, @maxCodeLength) ASC, classCode.classCodeDescription"
                classCodeQuery = Replace(classCodeQuery, "@maxCodeLength", maxCodeLength)
                classCodeRS.Open classCodeQuery, db

                DO UNTIL classCodeRS.EOF
                    strSelected = ""
                    IF cStr(classCodeRS("classCode")) = cStr(classCode) THEN
                        strSelected = "selected=""selected"""
                    END IF
                    Response.Write "<option value=""" & classCodeRS("classCode") & """ " & strSelected & ">" & classCodeRS("classCodeDescription") & "</option>" & vbCr
                    classCodeRS.MoveNext
                LOOP
                classCodeRS.Close
                %></select></td>
            </tr>
        </table>
    </div>
<% ELSE %>
    <div class="aa-widget" id="aa-loan-maint-codes">
        <h4>The Code options will appear after creating the application by clicking the UPDATE BUTTON</h4>
    </div>
<% END IF %>