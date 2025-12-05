function validate_required(field, alerttxt) {
    with (field) {
        if (value == null || value == "")
        { alert(alerttxt); return false; }
        else { return true; }
    }
}

function validate_numeric(field, alerttxt) {
    with (field) {
        var temp_value = value;

        if (temp_value == "") {
            value = "";
            return true;
        }
        var Chars = "0123456789.,$";
        for (var i = 0; i < temp_value.length; i++) {
            if (Chars.indexOf(temp_value.charAt(i)) == -1) {
                alert(alerttxt);
                return false;
            }
            else {
                return true;
            }
        }
    }

}

function validate_range(field, alerttxt, lower, upper) {
    with (field) {
        value = value.toString().replace("%","")
        if (value == null || (value < lower) || (value > upper))
        { alert(alerttxt); return false; }
        else { return true; }
    }
}

function validate_date(field, alerttxt) {
    with (field) {
        //This expression validates dates in the US m/d/y format from 1/1/1600 - 12/31/9999
        if (!value.toString().match(/^(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[13-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/))
        {if (value != "") { alert(alerttxt); return false; } }
        else { return true; }
    }
}


/*
 * Regular Expression for common data patterns.
 */
var isInteger_re	= /^\s*(\+|-)?\d+\s*$/;
var isDecimal_re	= /^\s*(\+|-)?((\d+(\.\d+)?)|(\.\d+))\s*$/;
var isDate_re		= /^(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[13-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/

/*
 * The regex expression has been refactored to handle parenthetical negative currency values as well as standard
 * currency value representations (e.g. -$1000.00)
 */
var isCurrency_re = /^\(\$?\d{1,3}?(,?\d{3})*(\.\d{0,2})?\)$|(^(\+|-)?\$?((\d{1,3}?(,?\d{3})*(\.\d{0,2})?)|(\.\d{0,2}))*$)/;

function ValidateDateField(fld){
	var s = fld.value;
	if( s.length > 0 && String(s).search (isDate_re) == -1 ){
		alert("Invalid Date Value.");
		fld.focus(false,true);
		fld.select();
		return false;
	}
	else{
		return true;
	}

}

function ValidateCurrencyField(fld){
	var s = fld.value;

    s = s.replace(/\s*/g, "");

	if( s.length > 0 && String(s).search (isCurrency_re) == -1 ){
		alert("Invalid Currency Value.");
		fld.focus(false,true);
		fld.select();
		return false;
	}
	else{
		return true;
	}
}

function ValidateIntegerField(fld){
	var s = fld.value;
	
	if( s.length > 0 && String(s).search (isInteger_re) == -1 ){
		alert("Invalid Integer Value.");
		fld.focus(false,true);
		fld.select();
		return false;
	}
	else{
		return true;
	}
}

function ValidateDecimalField(fld, size, precision){
    var s = fld.value;
    var precisionInt = parseInt(precision);
    var fullSize = parseInt(size) + parseInt(precision);

    if (s.length > 0) {
        if (String(s).search(isDecimal_re) == -1) {
            alert('Invalid Decimal Value.');
            fld.focus(false, true);
            fld.select();
            return false;
        } else {
            var regexStr = '^(\\d{0,' + size + '}\\.\\d{0,' + precision + '}|\\d{0,' + size + '}|\\.\\d{0,' + precision + '})$';
            var regex = new RegExp(regexStr);
            var isValidDecimal = regex.test(s);
            if (!isValidDecimal) {
                if (precisionInt === 0) {
                    alert('This decimal flex field is configured to only accept ' + fullSize + ' digits in total, and no decimals. Please make the necessary adjustments.');
                }
                else if (precisionInt === 1) {
                    alert('This decimal flex field is configured to only accept ' + fullSize + ' digits in total, including ' + precision + ' decimal place. Please make the necessary adjustments.');
                }
                else {
                    alert('This decimal flex field is configured to only accept ' + fullSize + ' digits in total, including ' + precision + ' decimal places. Please make the necessary adjustments.');
                }
                fld.focus(false, true);
                fld.select();
                return false;
            } else {
                return true;
            }
        }
    }
}

function ValidateTextField(fld){
	return true;
}

