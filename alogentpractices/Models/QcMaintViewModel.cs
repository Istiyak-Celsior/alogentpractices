namespace alogentpractices.Models
{
    public class QcMaintViewModel
    {
        public string historyId { get; set; }
        public string cust { get; set; }
        public string docId { get; set; }
        public string file { get; set; }
        public string path { get; set; }
        public string escFileName { get; set; }

        // From rsHistory recordset
        public string documentType { get; set; }
        public string customerName { get; set; }
        public string customerNumber { get; set; }
        public string userEmail { get; set; }
        public string bankId { get; set; }
        public string customerId { get; set; }
        public string customerBranchId { get; set; }
        public bool employee { get; set; }
        public string loanId { get; set; }
        public string loanBranchId { get; set; }
        public string extendedAccountClassCode { get; set; }
        public int documentMissing { get; set; }
        public int? documentStatus { get; set; }
        public string documentTitle { get; set; }
        public string filename { get; set; }
        public string documentTypeName { get; set; }
        public string documentSubTypeName { get; set; }
        public bool? hasDemographicData { get; set; }
        public string hideEmployeeFileYN { get; set; }
        public int? documentSubTypeId { get; set; }
        public int? qcStatus { get; set; }
        public string qcHistory { get; set; }
        public string documentId { get; set; }

        // Computed properties
        public bool customerIsEmployee { get; set; }
        public string historicalLabel { get; set; }
        public string branchId { get; set; }
        public bool documentTabIsEmployeeFile { get; set; }
        public bool allowDocumentAccess { get; set; }
        public bool isCustomerEmployeeFile { get; set; }
        public UserDocumentViewAccess viewDocumentAccess { get; set; }
        public string documentTypeIcon { get; set; }
        public string viewDocumentUrl { get; set; }
        public string qcmaintViewFileRoute { get; set; }

        // QC Status flags
        public string noQc { get; set; }
        public string qcSuccess { get; set; }
        public string qcErrors { get; set; }
        public string loadcheck { get; set; }
        public string loaddisable { get; set; }

        // QC Notification
        public string qcNotifyEnabled { get; set; }
        public string qcInfo { get; set; }
        public string qcInfoDisplay { get; set; }

        // Session values
        public string sessionUserEmail { get; set; }
        public bool allowEmailSending { get; set; }
        public string sessionUserId { get; set; }
    }

    public class UserDocumentViewAccess
    {
        public bool HasAccess { get; set; }
        public string Reason { get; set; }
    }
}
