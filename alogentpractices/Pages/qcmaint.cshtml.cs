using alogentpractices.DAL;
using alogentpractices.Models;
using alogentpractices.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace alogentpractices.Pages
{
    public class QcMaintModel : PageModel
    {
        private readonly ApplicationDbContext _db;
        private readonly Security _securityService;
        private readonly CommonHelper _commonHelper;
        private readonly BranchSecurityFunctions _branchSecurityFunctions;
        private readonly DocumentTabSecurity _documentTabSecurity;
        private readonly ApplicationTransactions _applicationTransactions;

        public QcMaintModel(
            ApplicationDbContext db,
            Security securityService,
            CommonHelper commonHelper,
            BranchSecurityFunctions branchSecurityFunctions,
            DocumentTabSecurity documentTabSecurity,
            ApplicationTransactions applicationTransactions)
        {
            _db = db;
            _securityService = securityService;
            _commonHelper = commonHelper;
            _branchSecurityFunctions = branchSecurityFunctions;
            _documentTabSecurity = documentTabSecurity;
            _applicationTransactions = applicationTransactions;
        }

        [BindProperty]
        public QcMaintViewModel QcMaint { get; set; }

        public void OnGet(string historyId, string cust, string docId, string file, string path)
        {
            // ### Build out user for security processing
            //
            var usr = _applicationTransactions.GetUserBySession(HttpContext.Session);

            historyId = (historyId ?? "").Trim();
            historyId = historyId.Replace("{", "");
            historyId = historyId.Replace("}", "");

            if (historyId == "")
            {
                _commonHelper.Break("-Encountered an error trying to find the document history- " + docId);
            }

            cust = (cust ?? "").Trim();
            if (cust == "") cust = "<i>Customer not found</i>";

            docId = (docId ?? "").Trim();
            docId = docId.Replace("{", "");
            docId = docId.Replace("}", "");

            file = (file ?? "").Trim();
            path = (path ?? "").Trim();
            string escFileName = _commonHelper.EscapeJSStr(file);

            // LINQ query equivalent to the SQL in the original ASP
            var rsHistory = (from dh in _db.DocumentHistory
                             join d in _db.Document on dh.documentId equals d.documentId into dDoc
                             from d in dDoc.DefaultIfEmpty()
                             join c in _db.Customer on d.customerId equals c.customerId into dCust
                             from c in dCust.DefaultIfEmpty()
                             join l in _db.Loan on d.loanId equals l.loanId into dLoan
                             from l in dLoan.DefaultIfEmpty()
                             join ls in _db.LoanStatus on l.loanStatusId equals ls.statusId into dLoanStatus
                             from ls in dLoanStatus.DefaultIfEmpty()
                             join ac in _db.AccountClass on ls.accountClassId equals ac.accountClassId into dAccountClass
                             from ac in dAccountClass.DefaultIfEmpty()
                             join dd in _db.DocumentDefinitions on d.documentDefId equals dd.documentDefId into dDocDef
                             from dd in dDocDef.DefaultIfEmpty()
                             join dt in _db.DocumentType on dd.documentTypeId equals dt.documentTypeId into dDocType
                             from dt in dDocType.DefaultIfEmpty()
                             join dst in _db.DocumentSubType on new { dd.documentTypeId, dd.documentSubTypeId } equals new { dst.documentTypeId, dst.documentSubTypeId } into dDocSubType
                             from dst in dDocSubType.DefaultIfEmpty()
                             join dsto in _db.DocumentSubTypeOption on dd.documentSubTypeId equals dsto.documentSubTypeId into dDocSubTypeOption
                             from dsto in dDocSubTypeOption.DefaultIfEmpty()
                             join u in _db.User on dh.userLogin equals u.userLogin into dUser
                             from u in dUser.DefaultIfEmpty()
                             where dh.historyId == _commonHelper.DbFormatId(historyId)
                             select new
                             {
                                 dh.historyId,
                                 dh.documentId,
                                 dh.documentType,
                                 dh.qcStatus,
                                 dh.qcHistory,
                                 dh.userLogin,
                                 userEmail = u != null ? u.userEmail : null,
                                 customerName = c != null ? c.customerName : null,
                                 bankId = c != null ? c.bankId : null,
                                 customerId = c != null ? c.customerId : null,
                                 customerBranchId = c != null ? c.customerBranchId : null,
                                 customerNumber = c != null ? c.customerNumber : null,
                                 employee = c != null ? c.employee : false,
                                 loanId = l != null ? l.loanId : null,
                                 loanBranchId = l != null ? l.loanBranchId : null,
                                 extendedAccountClassCode = l != null && (ls == null || ls.isApplicationStatus == null || ls.isApplicationStatus == 0)
                                     ? (ac != null ? ac.accountClassCode : null)
                                     : (l != null && ls != null && ls.isApplicationStatus == 1
                                         ? "loanapp"
                                         : (c != null ? "credit" : null)),
                                 documentMissing = d == null ? 1 : 0,
                                 documentStatus = d != null ? d.documentStatus : (int?)null,
                                 documentTitle = d != null ? d.documentTitle : null,
                                 filename = d != null ? d.filename : null,
                                 documentTypeName = dt != null ? dt.documentTypeName : null,
                                 documentSubTypeName = dst != null ? dst.documentSubTypeName : null,
                                 hasDemographicData = dsto != null ? dsto.hasDemographicData : (bool?)null,
                                 hideEmployeeFileYN = dd != null ? dd.hideEmployeeFileYN : null,
                                 documentSubTypeId = dd != null ? dd.documentSubTypeId : (int?)null
                             }).FirstOrDefault();

            QcMaint = new QcMaintViewModel();
            QcMaint.historyId = historyId;
            QcMaint.cust = cust;
            QcMaint.docId = docId;
            QcMaint.file = file;
            QcMaint.path = path;
            QcMaint.escFileName = escFileName;

            if (rsHistory != null)
            {
                QcMaint.documentType = rsHistory.documentType;
                QcMaint.customerName = rsHistory.customerName;
                QcMaint.customerNumber = rsHistory.customerNumber;
                QcMaint.userEmail = rsHistory.userEmail;
                QcMaint.bankId = rsHistory.bankId;
                QcMaint.customerId = rsHistory.customerId;
                QcMaint.customerBranchId = rsHistory.customerBranchId;
                QcMaint.employee = rsHistory.employee;
                QcMaint.loanId = rsHistory.loanId;
                QcMaint.loanBranchId = rsHistory.loanBranchId;
                QcMaint.extendedAccountClassCode = rsHistory.extendedAccountClassCode;
                QcMaint.documentMissing = rsHistory.documentMissing;
                QcMaint.documentStatus = rsHistory.documentStatus;
                QcMaint.documentTitle = rsHistory.documentTitle;
                QcMaint.filename = rsHistory.filename;
                QcMaint.documentTypeName = rsHistory.documentTypeName;
                QcMaint.documentSubTypeName = rsHistory.documentSubTypeName;
                QcMaint.hasDemographicData = rsHistory.hasDemographicData;
                QcMaint.hideEmployeeFileYN = rsHistory.hideEmployeeFileYN;
                QcMaint.documentSubTypeId = rsHistory.documentSubTypeId;
                QcMaint.qcStatus = rsHistory.qcStatus;
                QcMaint.qcHistory = rsHistory.qcHistory;
                QcMaint.documentId = rsHistory.documentId;

                // Computed values
                QcMaint.customerIsEmployee = rsHistory.employee;
                int missingDocument = rsHistory.documentMissing;
                string historicalLabel = "";

                if (missingDocument == 1)
                {
                    historicalLabel = " (historical change only)";
                }
                QcMaint.historicalLabel = historicalLabel;

                // ### Determine the document's view access
                //
                string branchId = rsHistory.loanBranchId;
                if (string.IsNullOrEmpty(branchId))
                {
                    branchId = rsHistory.customerBranchId;
                }
                QcMaint.branchId = branchId;

                string hideEmployeeFileYN = (rsHistory.hideEmployeeFileYN ?? "").ToUpper();
                bool documentTabIsEmployeeFile;
                if (hideEmployeeFileYN == "Y" && rsHistory.employee)
                {
                    documentTabIsEmployeeFile = true;
                }
                else
                {
                    documentTabIsEmployeeFile = false;
                }
                QcMaint.documentTabIsEmployeeFile = documentTabIsEmployeeFile;

                bool allowDocumentAccess;
                if (!string.IsNullOrEmpty(rsHistory.loanId))
                {
                    allowDocumentAccess = _documentTabSecurity.AllowAccountTabAccess(rsHistory.documentSubTypeId);
                }
                else
                {
                    allowDocumentAccess = _documentTabSecurity.AllowCreditTabAccess(rsHistory.documentSubTypeId);
                }
                QcMaint.allowDocumentAccess = allowDocumentAccess;

                bool isCustomerEmployeeFile;
                UserDocumentViewAccess viewDocumentAccess;
                if (!string.IsNullOrEmpty(rsHistory.documentId))
                {
                    isCustomerEmployeeFile = rsHistory.employee && documentTabIsEmployeeFile;
                    viewDocumentAccess = usr.Security.HasDocumentViewAccess(rsHistory.extendedAccountClassCode, branchId, allowDocumentAccess, isCustomerEmployeeFile, rsHistory.hasDemographicData);
                    QcMaint.isCustomerEmployeeFile = isCustomerEmployeeFile;
                }
                else
                {
                    viewDocumentAccess = new UserDocumentViewAccess();
                    viewDocumentAccess.HasAccess = false;
                }
                QcMaint.viewDocumentAccess = viewDocumentAccess;

                string documentTypeIcon = _commonHelper.GetDocumentTypeIcon(file);
                QcMaint.documentTypeIcon = documentTypeIcon;

                // Build view document URL
                if (viewDocumentAccess.HasAccess)
                {
                    escFileName = _commonHelper.EscapeJSStr(escFileName);
                    string qcmaintViewFileRoute = _commonHelper.GetDocumentFileViewUrl(rsHistory.documentId, HttpContext.Session.GetString("userId"));
                    QcMaint.qcmaintViewFileRoute = qcmaintViewFileRoute;
                    QcMaint.viewDocumentUrl = "javascript:Start('" + qcmaintViewFileRoute + "');";
                }

                // ### Process qcStatus
                //
                string noQc = "", qcSuccess = "", qcErrors = "";
                string loadcheck = "", loaddisable = "";
                int? qcStatus = rsHistory.qcStatus;

                if (qcStatus == null)
                {
                    noQc = " checked=\"checked\"";
                    loadcheck = "";
                    loaddisable = " disabled=\"disabled\"";
                }
                else if (qcStatus == 0)
                {
                    noQc = " checked=\"checked\"";
                    loadcheck = "";
                    loaddisable = " disabled=\"disabled\"";
                }
                else if (qcStatus == 1)
                {
                    qcSuccess = " checked=\"checked\"";
                    loadcheck = "";
                    loaddisable = " disabled=\"disabled\"";
                }
                else if (qcStatus == 2)
                {
                    qcErrors = " checked=\"checked\"";
                    loadcheck = " checked=\"checked\"";
                    loaddisable = "";
                }

                QcMaint.noQc = noQc;
                QcMaint.qcSuccess = qcSuccess;
                QcMaint.qcErrors = qcErrors;
                QcMaint.loadcheck = loadcheck;
                QcMaint.loaddisable = loaddisable;

                string qcNotifyEnabled = "true";
                string qcInfo = "";
                string qcInfoDisplay = "icon-hide";

                // ### IF sender or author emails empty then disable notifications
                // ###
                string sessionUserEmail = HttpContext.Session.GetString("userEmail");
                bool allowEmailSending = HttpContext.Session.GetString("allowEmailSending") == "true";

                if (string.IsNullOrEmpty(sessionUserEmail))
                {
                    qcNotifyEnabled = "false";
                    qcInfo = "You do not have an email address configured.";
                    qcInfoDisplay = "icon-show";
                    loadcheck = "";
                    loaddisable = " disabled=\"disabled\"";
                }
                else if (string.IsNullOrEmpty(rsHistory.userEmail))
                {
                    qcNotifyEnabled = "false";
                    qcInfo = "The author does not have an email address configured.";
                    qcInfoDisplay = "icon-show";
                    loadcheck = "";
                    loaddisable = " disabled=\"disabled\"";
                }
                else if (!allowEmailSending)
                {
                    qcNotifyEnabled = "false";
                    qcInfo = "You do not have permission to send mail.";
                    qcInfoDisplay = "icon-show";
                    loadcheck = "";
                    loaddisable = " disabled=\"disabled\"";
                }

                QcMaint.qcNotifyEnabled = qcNotifyEnabled;
                QcMaint.qcInfo = qcInfo;
                QcMaint.qcInfoDisplay = qcInfoDisplay;
                QcMaint.loadcheck = loadcheck;
                QcMaint.loaddisable = loaddisable;
                QcMaint.sessionUserEmail = sessionUserEmail;
                QcMaint.allowEmailSending = allowEmailSending;
                QcMaint.sessionUserId = HttpContext.Session.GetString("userId");
            }
        }
    }
}