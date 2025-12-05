<%
	'
	'	Function:
	'		AddNewCollateral
	'
	' Arguments:
	'		parentLoanId						- the loanId that the collateral will be attached to
	'		crossCollateralLoanId		- by default a collateral copies it's parent's loan record,
	'															if this is passed then the cross collateral is being
	'															created. The collateral copies the cross collateral record
	'															information instead of the loan it's being assigned to.
	'
	'	Returns:
	'		newCollateralLoanId			- the loanId of the newly created collateral.
	'
	'	Description:
	'		Creates a collateral/cross collateral for a specific loan. If the second argument
	'		is not passed then it's a regular collateral, otherwise it's a cross collateral.
	'
	'	Maintenance History:
	'	Developer					Date				Action
	' -----------------	----------	-------------------------------------------------
	'	MikeF							09/17/2007	Created
	'
	function AddNewCollateral(parentLoanId, crossCollateralLoanId)
		'// if crossCollateralLoanId is NULL or an empty string then force the primary
		'// collateral to reference the parent loanId and set the isCrossCollateralYN flag
		'// as appropriate.
		'//
		if IsNull(crossCollateralLoanId) then
			crossCollateralLoanId = parentLoanId
			isCrossCollateralYN = "N"
		elseif Trim(crossCollateralLoanId) = "" then
			crossCollateralLoanId = parentLoanId
			isCrossCollateralYN = "N"
		else
			isCrossCollateralYN = "Y"
		end if
			
		'// Open a record set to the parent loan
		'//
		Dim parentLoanQuery, parentLoanRS
		Set parentLoanRS = Server.CreateObject("ADODB.RecordSet")
		parentLoanQuery = "SELECT * FROM viewLoansAndCollaterals WHERE loanId=" & dbFormatId(parentLoanId)
		parentLoanRS.Open parentLoanQuery, db, adOpenStatic, adCmdText
		
		Dim primaryCollateralQuery, primaryCollateralRS
		Set primaryCollateralRS = Server.CreateObject("ADODB.RecordSet")
		primaryCollateralQuery = "SELECT * FROM viewLoansAndCollaterals WHERE loanId=" & dbFormatId(crossCollateralLoanId)
		primaryCollateralRS.Open primaryCollateralQuery, db, adOpenStatic, adCmdText
			
		'// STEP 1:
		'//		Ensure unique loan/collateral number by creating a string of the form
		'//		<loanNumber>_<index>
		Dim collateralQuery, collateralRS
		Set collateralRS = Server.CreateObject("ADODB.RecordSet")
		collateralQuery = _
			" SELECT MAX(collateralSequence) AS collateralSequence" & _
			" FROM collateral" & _
			" WHERE parentLoanId=" & dbFormatId(parentLoanId)
		collateralRS.Open collateralQuery, db, adOpenStatic, adCmdText
      
		if IsNull(collateralRS("collateralSequence")) then
			nextSequence = 1
		else
			nextSequence = cLng(collateralRS("collateralSequence")) + 1
		end if
			
		collateralNumber = parentLoanRS("loanNumber") & "_" & GetPaddedCollateralSequence(nextSequence)
		collateralRS.Close
      
		collateralUnique = false
		do until collateralUnique
			collateralQuery = "SELECT * FROM loan WHERE loanNumber LIKE '" & collateralNumber & "'"
			collateralRS.Open collateralQuery, db, adOpenStatic, adCmdText
			if collateralRS.eof then
				collateralUnique = true
			else
				nextSequence = cLng(nextSequence) + 1
				collateralNumber = parentLoanRS("loanNumber") & "_" & GetPaddedCollateralSequence(nextSequence)
			end if
			collateralRS.Close
		loop
			
		'// STEP 2:
		'// 	Create a new loan entry that will be used as the collateral record. NOTE: only
		'// 	loanDescription is used.
		collateralRS.Open "loan", db, adOpenKeyset, adLockPessimistic, adCmdTableDirect
		collateralRS.AddNew
		
		'// Update the Collateral fields used.
		'//
		if isCrossCollateralYN = "Y" then
			collateralRS("loanDescription")     = primaryCollateralRS("loanDescription")
			collateralRS("primaryCollateralId") = primaryCollateralRS("loanId")
		else
			collateralRS("loanDescription") = collateralDescription
		end if
				
		collateralRS("loanNumber") 			= collateralNumber
		collateralRS("loanFolder") 			= collateralNumber & "/"
		collateralRS("isCrossCollateralYN") = isCrossCollateralYN
		collateralRS("isCollateralYN")		= "Y"

		
		'// Copy primary collateral values for default
		'//
		today = now()
		collateralRS("customerId")		= parentLoanRS("customerId")
		collateralRS("loanTypeId")		= primaryCollateralRS("loanTypeId")
		collateralRS("loanOfficerId")	= primaryCollateralRS("loanOfficerId")
		collateralRS("transferStatus")	= primaryCollateralRS("transferStatus")
		collateralRS("loanStatusId")	= primaryCollateralRS("loanStatusId")
		collateralRS("loanClosed")		= primaryCollateralRS("loanClosed")
		collateralRS("loanOrigDate")	= primaryCollateralRS("loanOrigDate")
		collateralRS("origdate")		= today
		collateralRS("modifieddate")	= today
		collateralRS("loanAmount")		= primaryCollateralRS("loanAmount")
		collateralRS("lockLoanTypeYN")	= primaryCollateralRS("lockLoanTypeYN")
		collateralRS("ignoreExceptionsYN") = primaryCollateralRS("ignoreExceptionsYN")
		collateralRS("loanBranchId")	= primaryCollateralRS("loanBranchId")
		collateralRS("orderNumber")		= primaryCollateralRS("orderNumber")
		collateralRS("propertyDesc")	= primaryCollateralRS("propertyDesc")
			
		'// Update record to create
		'//
		collateralRS.Update
		
		'// Get the newly create record Id
		'//
		newCollateralLoanId = collateralRS("loanId")
		
		'// Close record sets
		'//
		collateralRS.Close
		primaryCollateralRS.Close
		parentLoanRS.Close
			
			
		'STEP 3:
		'// Add new record in collateral associating the loan to collateral relationship
		'//
		collateralRS.Open "collateral", db, adOpenDynamic, adLockPessimistic, adCmdTableDirect
		collateralRS.AddNew
		collateralRS("parentLoanId") = parentLoanId
		collateralRS("collateralLoanId") = newCollateralLoanId
		collateralRS("collateralSequence") = nextSequence
		collateralRS("statusOverrideYN") = "N"
		collateralRS("ignoreExceptionsOverrideYN") = "N"
		collateralRS.Update
		collateralRS.Close
		
		AddNewCollateral = newCollateralLoanId
	end function '// AddNewCollateral()
%>



