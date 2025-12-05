<%
FUNCTION GetCustomerName(f)
    Dim customerName
    IF InStr(f, "~") THEN customerName = Left(f, InStr(f,"~")-1)
    GetCustomerName = customerName
END FUNCTION

FUNCTION GetDescription(f)
    Dim description : description = ""
    IF InStr(f, "^") THEN
        description = Left(f, InStr(f, "^")-1)
        IF InStr(f, "~") THEN description = Right(description, Len(description) - InStrRev(description,"~"))
    END IF
    GetDescription = description
END FUNCTION

FUNCTION GetFilename(f)
    Dim filename
    IF InStr(f, "^") THEN
        filename = Right( f, Len(f) - InStrRev(f, "^"))
    ELSEIF InStr(f, "~") THEN
        filename = Right( f, Len(f) - InStrRev(f, "~"))
    ELSE
        filename = f
    END IF
    GetFilename = filename
END FUNCTION

FUNCTION GetCustomerNameMarkup(n)
    Dim str : str = ""
    IF n <> "" THEN str = "<b>" & n & "</b>"
    GetCustomerNameMarkup = str
END FUNCTION

FUNCTION GetCustomerNumberMarkup(n)
    Dim str : str = ""
    IF n <> "" THEN str = "(<i>" & n & "</i>)"
    GetCustomerNumberMarkup = str
END FUNCTION

FUNCTION GetLoanNumberMarkup(n)
    Dim str : str = ""
    IF n <> "" THEN str = "<b>" & loanNumber & "</b>"
    GetLoanNumberMarkup = str
END FUNCTION

FUNCTION GetDescriptionMarkup(d)
    Dim str : str = ""
    IF d <> "" THEN str = "<b>" & d & "</b>"
    GetDescriptionMarkup = str
END FUNCTION

FUNCTION GetFilenameMarkup(f)
    GetFilenameMarkup = f
END FUNCTION
%>