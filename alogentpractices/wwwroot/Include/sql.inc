<%


'------------------------------------------------------------------------
' Deletes any customer documents that are not defined by the customerType
'------------------------------------------------------------------------
function DeleteUnusedCreditDocuments(customerId)
	if Trim(customerId) <> "" then
		db.Execute "EXEC spDeleteUnusedCreditDocuments " & dbFormatText(customerId)
	end if
end function 'DeleteUnusedCustomerDocuments


'------------------------------------------------------------------------
' Deletes any loan documents that are not defined by the loanType for
' the specified loan.
'------------------------------------------------------------------------
function DeleteUnusedLoanDocuments(loanId)
	if Trim(loanId) <> "" then
			db.Execute "EXEC spDeleteUnusedLoanDocuments " & dbFormatText(loanId)

	end if
end function 'DeleteUnusedLoanDocuments


'------------------------------------------------------------------------
'
'------------------------------------------------------------------------
function AddMissingCreditExceptions(customerId)
	if Trim(customerId) <> "" then
		db.Execute "EXEC spAddMissingCreditExceptions 'C', " & dbFormatText(customerId)
	end if
end function 'AddMissingCreditExceptions


'------------------------------------------------------------------------
'
'------------------------------------------------------------------------
function AddMissingLoanExceptions(loanId)
	if Trim(loanId) <> "" then
		db.Execute "EXEC spAddMissingLoanExceptions 'L', " & dbFormatText(loanId)
	end if
end function 'AddMissingLoanExceptions


'------------------------------------------------------------------------
'
'------------------------------------------------------------------------
function DeleteUnusedCustomerExceptions(customerId)
	if Trim(customerId) <> "" then
		db.Execute "EXEC spDeleteUnusedCreditExceptions 'C', " & dbFormatText(customerId)
	end if
end function 'DeleteUnusedCustomerExceptions


'------------------------------------------------------------------------
'
'------------------------------------------------------------------------
function DeleteUnusedLoanExceptions(loanId)
  if Trim(loanId) <> "" then
    db.Execute "EXEC spDeleteUnusedLoanExceptions 'L', " & dbFormatText(loanId)
  end if
end function 'DeleteUnusedLoanExceptions

%>