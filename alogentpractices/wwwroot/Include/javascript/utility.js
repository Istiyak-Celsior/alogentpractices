//
// Focuses on the given form's (frm) first text or textarea element.
// To use, call the function from onLoad in the BODY tag.
//
function focusFirstField(frm){
  var i = 0;
  while (i < frm.elements.length) {
    if (frm.elements[i].type == "text" || 
        frm.elements[i].type == "textarea" || 
        frm.elements[i].type == "password")
    {
      frm.elements[i].focus();
      break;
    }
    i++;
  }
}

// The following make up a trim function for javascript
function Trim(TRIM_VALUE){
if(TRIM_VALUE.length < 1){
return"";
}
TRIM_VALUE = RTrim(TRIM_VALUE);
TRIM_VALUE = LTrim(TRIM_VALUE);
if(TRIM_VALUE==""){
return "";
}
else{
return TRIM_VALUE;
}
} //End Function

function RTrim(VALUE){
var w_space = String.fromCharCode(32);
var v_length = VALUE.length;
var strTemp = "";
if(v_length < 0){
return"";
}
var iTemp = v_length -1;

while(iTemp > -1){
if(VALUE.charAt(iTemp) == w_space){
}
else{
strTemp = VALUE.substring(0,iTemp +1);
break;
}
iTemp = iTemp-1;

} //End While
return strTemp;

} //End Function

function LTrim(VALUE){
var w_space = String.fromCharCode(32);
if(v_length < 1){
return"";
}
var v_length = VALUE.length;
var strTemp = "";

var iTemp = 0;

while(iTemp < v_length){
if(VALUE.charAt(iTemp) == w_space){
}
else{
strTemp = VALUE.substring(iTemp,v_length);
break;
}
iTemp = iTemp + 1;
} //End While
return strTemp;
} //End Function


