<%
firstCustomerId   = ""
firstLoanId       = ""
firstCollateralId = ""
customerCount     = 0
loanCount         = 0

Customer.MoveFirst
DO UNTIL Customer.EOF
    ' Get firstCustomerId whether it has a loan or not
    IF Trim(Customer("customerId") & "") <> firstCustomerId THEN 
        customerCount = customerCount + 1
        IF firstCustomerId = "" THEN firstCustomerId = Customer("customerId")
    END IF

    ' Only get firstLoanId if the same first customer is being looped through
    IF  Trim(Customer("loanId") & "") <> "" _
        AND Trim(Customer("isCollateralYN") & "") <> "Y" _
        AND Trim(Customer("customerId") & "") = firstCustomerId _
    THEN
        loanCount = loanCount + 1
        IF firstLoanId = "" THEN firstLoanId = Customer("loanId")
    END IF

    ' Only get firstCollateralId if the same first customer and loan is being looped through
    IF  Trim(Customer("loanId") & "") <> "" _
        AND Trim(Customer("isCollateralYN") & "") = "Y" _
        AND Trim(Customer("customerId") & "") = firstCustomerId _
        AND Trim(Customer("parentLoanId") & "") = firstLoanId _
    THEN
        collateralCount = collateralCount + 1
        IF firstCollateralId = "" THEN firstCollateralId = Customer("loanId")
    END IF

    Customer.MoveNext
LOOP
Customer.Close

' Only redirect to customer page if there is only one customer and zero or one loan encountered during loop
IF customerCount = 1 AND loanCount <= 1  THEN
    Dim nextUrl : nextUrl = "customer.asp?customerId=" & firstCustomerId
    IF firstLoanId <> "" THEN nextUrl = nextUrl & "&loanId=" & firstLoanId
    IF firstCollateralId <> "" THEN nextUrl = nextUrl & "&collateralId=" & firstCollateralId

    Response.Clear
    Response.Redirect(nextUrl)
END IF
%>
<div id="aa-search-summary">
    <ul>
        <li>Total Customers:</li>
        <li><%=customerCount%></li>
        <li>Total Accounts:</li>
        <li><%=loanCount%></li>
    </ul>
</div>