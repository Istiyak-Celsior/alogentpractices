<%
    'Dynamic javascript to handle bank/branch changes
    Response.write vbcrlf & vbcrlf
    Response.write "<script language='JavaScript'>" & vbcrlf
    Response.write "  var banks = new Object();" & vbcrlf
    
    lastBankId = ""
    allBankList = ""
    
    for i = 0 to branchRows-1
      if CStr(lastBankId) <> CStr(branchArray(0,i)) then
        Response.write "  banks[" & Chr(34) & "bank=" & branchArray(0,i) & Chr(34) & "]= new Array(" & vbcrlf
        Response.write "    " & Chr(34) & Chr(34) & ", " & Chr(34) & "All Branches" & Chr(34) & ", " & vbcrlf
        lastBankId = branchArray(0,i)
      end if
      
      Response.write "    " & Chr(34) & branchArray(2,i) & Chr(34) & ", " & Chr(34) & branchArray(3,i) & Chr(34)
      allBankList = allBankList & _
                     "    " &  Chr(34) & branchArray(2,i) & Chr(34) & ", " & Chr(34) & branchArray(3,i) & Chr(34)
      
      if i = (branchRows-1) then
        'Handle last branch
        Response.write vbcrlf & "  );" & vbcrlf
        allBankList = allBankList & vbcrlf
      else
        Response.write ", " & vbcrlf
        allBankList = allBankList & ", " & vbcrlf
      end if
    next
    
    
    Response.write "  banks[" & Chr(34) & "bank=0" & Chr(34) & "]= new Array(" & vbcrlf
    Response.write "    " & Chr(34) & Chr(34) & ", " & Chr(34) & "All Branches" & Chr(34) & ", " & vbcrlf
    Response.write allBankList
    Response.write vbcrlf & "  );" & vbcrlf & vbcrlf
%>
    
    function changeBank(oList){
      var curform = oList.form; // get the containing form
      clearCombo(curform.branch); // clear the downstream list
      var newvalue = oList.name + "=" + oList.options[oList.selectedIndex].value;
      fillCombo(curform.branch, newvalue); // fill the downstream list
    
    }
    
    function clearCombo(oList){
      for (var i = oList.options.length - 1; i >= 0; i--){
        oList.options[i] = null;
      }
      oList.selectedIndex = -1;
    }
    function fillCombo(oList, vValue){
      if (vValue != "" && banks[vValue]){
        var arrX = banks[vValue];
        for (var i = 0; i < arrX.length; i = i + 2){
          oList.options[oList.options.length] = new Option(arrX[i + 1], arrX[i]);
        }
      } else oList.options[0] = new Option("None found", "");
    }

<%
    Response.write "</script>" & vbcrlf
    Response.write vbcrlf & vbcrlf
%>
