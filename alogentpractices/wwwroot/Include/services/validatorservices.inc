<%
	' The following are the Process Types expected by ExceptionValidator. Since the Service
	' is written in .NET this list will have to be manually updated if any changes occur
	' to it. 
	'
	' See AccuAccount.Applications.ExceptionValidator.ProcessType for details
	' of each type.
	'
	CONST VALIDATOR_PROCESS_FULL = -1
	CONST VALIDATOR_PROCESS_EXCEPTION = 0
	CONST VALIDATOR_PROCESS_DOCUMENT = 1
	CONST VALIDATOR_PROCESS_CUSTOMER = 2
	CONST VALIDATOR_PROCESS_ACCOUNT = 3
	CONST VALIDATOR_PROCESS_EXCEPTION_DEF = 4
	CONST VALIDATOR_PROCESS_DOCUMENT_DEF = 5
	CONST VALIDATOR_PROCESS_DOCUMENT_TAB = 6
%>
