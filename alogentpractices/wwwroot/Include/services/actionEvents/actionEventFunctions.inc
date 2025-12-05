<%
FUNCTION GetAccountClassId()
    Dim accountClassRS : Set accountClassRS = Server.CreateObject("ADODB.RecordSet")
    Dim accountClassSQL : accountClassSQL = _
        "SELECT " & _
        "   accountClassId " & _
        "FROM " & _
        "   accountClass " & _
        "WHERE " & _
        "   accountClassCode = 'loan'"
    accountClassRS.Open accountClassSQL, db
    IF NOT accountClassRS.EOF THEN
        Dim accountClassId : accountClassId = accountClassRS("accountClassId")
    END IF
    accountClassRS.Close
    GetAccountClassId = accountClassId
END FUNCTION

FUNCTION GetCloneableTypeList(nAccountClassId)
    Dim loanTypeRecord, jsonOut, jsonLoanTypeBlock, fieldId, fieldDescription
    Dim loanTypeListRS : Set loanTypeListRS = Server.CreateObject("ADODB.RecordSet")
    Dim loanTypeListSQL : loanTypeListSQL = _
        " SELECT DISTINCT lt.LoanTypeId, lt.LoanTypeDescription " & _
        " FROM " & _
        "   loanType AS lt " & _
        "   LEFT OUTER JOIN actionEvent AS ae ON lt.loanTypeId = ae.loanTypeId " & _
        " WHERE " & _
        "   ae.actionEventId IS NULL " & _
        "   AND lt.accountClassId = " & dbFormatId(nAccountClassId) & _
        " ORDER BY " & _
        "   lt.loanTypeDescription"

    loanTypeListRS.Open loanTypeListSQL, db

    jsonOut = ""
    
    WHILE NOT loanTypeListRS.EOF
        fieldId          = RemoveCurlyBrackets(loanTypeListRS("loanTypeId") & "")
        fieldDescription = loanTypeListRS("loanTypeDescription")

        jsonLoanTypeBlock = "{" & _
                                """LoanTypeId"": """ & fieldId  & """," & _
                                """LoanTypeDescription"": """ & fieldDescription  & """" & _
                            "}"

        IF jsonOut = "" THEN
            jsonOut = jsonLoanTypeBlock
        ELSE
            jsonOut = jsonOut & ", " & jsonLoanTypeBlock
        END IF
        
        loanTypeListRS.MoveNext
    WEND
    
    loanTypeListRS.Close

    jsonOut = "[" & jsonOut & "]"

    GetCloneableTypeList = jsonOut
END FUNCTION

SUB CloneLoanTypeWorkflowEvents(srcLoanTypeId, dstLoanTypeId)
    ' ### SELECT ALL WORKFLOW EVENTS FOR SOURCE LOAN TYPE ###

    IF (Trim(srcLoanTypeId & "") = "" OR Trim(dstLoanTypeId & "") = "") THEN EXIT SUB

    Dim actionEventsRS : Set actionEventsRS = Server.CreateObject("ADODB.RecordSet")
    Dim actionEventsSQL : actionEventsSQL = "SELECT actionEventId FROM actionEvent WHERE loanTypeId = " & dbFormatId(srcLoanTypeId)
    actionEventsRS.Open actionEventsSQL, db
    IF NOT actionEventsRS.EOF THEN
        DO WHILE NOT actionEventsRS.EOF

            Dim newActionEventId : newActionEventId = GenerateGuid("actionEvent", "actionEventId")
            Dim actionEventInsertSQL : actionEventInsertSQL = _
                " INSERT INTO actionEvent (" & _
                "   actionEventId," & _
                "   actionEventName," & _
                "   actionEventDescription," & _
                "   isLenderAction," & _
                "   isApproverAction," & _
                "   isAnalystAction," & _
                "   selectLender," & _
                "   selectApprover," & _
                "   selectAnalyst," & _
                "   notifyLender," & _
                "   notifyApprover," & _
                "   notifyAnalyst," & _
                "   setApplicationStatus," & _
                "   applicationStatusId," & _
                "   setApprovalStatus," & _
                "   approvalStatusId," & _
                "   setCreditAnalysisStatus," & _
                "   creditAnalysisStatusId," & _
                "   setLoanStatus," & _
                "   loanStatusId," & _
                "   setDeclinedException," & _
                "   declinedExceptionDefCode," & _
                "   selectDeclinedReason," & _
                "   editConditions," & _
                "   enforceApprovalLimit," & _
                "   setLockApplication," & _
                "   buildApplicationSnapshot," & _
                "   snapshotDocumentCode," & _
                "   analystSortOrder," & _
                "   approverSortOrder," & _
                "   lenderSortOrder," & _
                "   notifyOther," & _
                "   notifyOtherEmail," & _
                "   loanTypeId," & _
                "   requireStatusFilter," & _
                "   ExecuteProgram," & _
                "   ProgramCmdLine," & _
                "   GenerateTasks," & _
                "   bankId," & _
                "   TaskGroupId" & _
                " ) " & _
                " SELECT " & _
                dbFormatId(newActionEventId) & ", " & _
                "   actionEventName," & _
                "   actionEventDescription," & _
                "   isLenderAction," & _
                "   isApproverAction," & _
                "   isAnalystAction," & _
                "   selectLender," & _
                "   selectApprover," & _
                "   selectAnalyst," & _
                "   notifyLender," & _
                "   notifyApprover," & _
                "   notifyAnalyst," & _
                "   setApplicationStatus," & _
                "   applicationStatusId," & _
                "   setApprovalStatus," & _
                "   approvalStatusId," & _
                "   setCreditAnalysisStatus," & _
                "   creditAnalysisStatusId," & _
                "   setLoanStatus," & _
                "   loanStatusId," & _
                "   setDeclinedException," & _
                "   declinedExceptionDefCode," & _
                "   selectDeclinedReason," & _
                "   editConditions," & _
                "   enforceApprovalLimit," & _
                "   setLockApplication," & _
                "   buildApplicationSnapshot," & _
                "   snapshotDocumentCode," & _
                "   analystSortOrder," & _
                "   approverSortOrder," & _
                "   lenderSortOrder," & _
                "   notifyOther," & _
                "   notifyOtherEmail," & _
                dbFormatId(dstLoanTypeId) & ", " & _
                "   requireStatusFilter," & _
                "   ExecuteProgram," & _
                "   ProgramCmdLine," & _
                "   GenerateTasks," & _
                "   bankId," & _
                "   TaskGroupId" & _
                " FROM actionEvent" & _
                " WHERE actionEventId=" & dbFormatId(actionEventsRS("actionEventId"))
            db.Execute(actionEventInsertSQL)

            ' ### PROCESS APPROVAL STATUS CONDITIONS ###
            Dim approvalStatusesSQL : approvalStatusesSQL = _
                "INSERT INTO actionApprovalStatusFilter(actionEventId, approvalStatusId) " & _
                "SELECT " & _
                dbFormatId(newActionEventId) & ", " & _
                "   approvalStatusId " & _
                "FROM " & _
                "   actionApprovalStatusFilter " & _
                "WHERE " & _
                "   actionEventId = " & dbFormatId(actionEventsRS("actionEventId"))
            db.Execute(approvalStatusesSQL)

            ' ### PROCESS APPLICATION STATUS CONDITIONS ###
            Dim applicationStatusesSQL : applicationStatusesSQL = _
                "INSERT INTO actionApplicationStatusFilter(actionEventId, loanStatusId) " & _
                "SELECT " & _
                dbFormatId(newActionEventId) & ", " & _
                "   loanStatusId " & _
                "FROM " & _
                "   actionApplicationStatusFilter " & _
                "WHERE " & _
                "   actionEventId = " & dbFormatId(actionEventsRS("actionEventId"))
            db.Execute(applicationStatusesSQL)

            ' ### PROCESS ANALYSIS STATUS CONDITIONS ###
            Dim analysisStatusesSQL : analysisStatusesSQL = _
                "INSERT INTO actionAnalysisStatusFilter(actionEventId, creditAnalysisStatusId) " & _
                "SELECT " & _
                dbFormatId(newActionEventId) & ", " & _
                "   creditAnalysisStatusId " & _
                "FROM " & _
                "   actionAnalysisStatusFilter " & _
                "WHERE " & _
                "   actionEventId = " & dbFormatId(actionEventsRS("actionEventId"))
            db.Execute(analysisStatusesSQL)

            ' ### PROCESS ACTION EVENT TIMERS ###
            Dim actionEventTimersSQL : actionEventTimersSQL = _
                "INSERT INTO actionEventTimer " & _
                "   (actionTimerDefId, actionEventId, timerActionType) " & _
                "SELECT " & _
                "   actionTimerDefId, " & _
                dbFormatId(newActionEventId) & ", " & _
                "   timerActionType " & _
                "FROM " & _
                "   actionEventTimer " & _
                "WHERE " & _
                "   actionEventId = " & dbFormatId(actionEventsRS("actionEventId"))
            db.Execute(actionEventTimersSQL)

            actionEventsRS.MoveNext
        LOOP
    END IF
    actionEventsRS.Close
END SUB
%>