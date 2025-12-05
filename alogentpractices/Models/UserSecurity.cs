namespace alogentpractices.Models
{
    public class UserSecurity
    {
        // Constants
        public const string RESOURCE_DOCUMENT = "document";
        public const string RESOURCE_DOCUMENT_NAME_DEMOGRAPHIC = "demographic";
        public const int PERMISSION_TYPE_DENY = 0;

        private bool m_isInactive;
        private bool m_isSuperUser;
        private bool m_hasEmployeeFileAccess;
        private List<UserAccountSecurity> m_accountSecurityList;
        private List<UserPermission> m_permissionList;
        private UserBranchSecurity m_branchSecurity;

        // Default Constructor
        public UserSecurity()
        {
            // Perform any default initializations
            m_accountSecurityList = new List<UserAccountSecurity>();
            m_permissionList = new List<UserPermission>();
            m_branchSecurity = new UserBranchSecurity();
        }

        public bool IsInactive
        {
            get { return m_isInactive; }
            set { m_isInactive = value; }
        }

        public bool IsSuperUser
        {
            get { return m_isSuperUser; }
            set { m_isSuperUser = value; }
        }

        public bool HasEmployeeFileAccess
        {
            get { return IsSuperUser || m_hasEmployeeFileAccess; }
            set { m_hasEmployeeFileAccess = value; }
        }

        public List<UserAccountSecurity> AccountSecurityList
        {
            get { return m_accountSecurityList; }
            set { m_accountSecurityList = value; }
        }

        public List<UserPermission> PermissionList
        {
            get { return m_permissionList; }
            set { m_permissionList = value; }
        }

        public UserBranchSecurity BranchSecurity
        {
            get { return m_branchSecurity; }
            set { m_branchSecurity = value; }
        }

        public UserAccountSecurity UserAccountSecurityByAccountClass(string classCode)
        {
            UserAccountSecurity accountSecurity = null;

            for (int i = 0; i < m_accountSecurityList.Count; i++)
            {
                accountSecurity = m_accountSecurityList[i];
                if (accountSecurity.AccountClassCode == classCode?.ToLower())
                {
                    break;
                }
            }

            return accountSecurity;
        }

        public int HasPermission(string permissionResource, string permissionName)
        {
            int result = 0;

            for (int i = 0; i < m_permissionList.Count; i++)
            {
                var permission = m_permissionList[i];
                if (permission.Resource == permissionResource && permission.Name == permissionName)
                {
                    result = permission.PermissionType;
                    break;
                }
            }

            return result;
        }

        public UserDocumentViewAccess HasDocumentViewAccess(string accountClassCode, string branchId, bool hasDocumentAccess, bool isEmployeeCustomerFile, bool? hasDemographicData)
        {
            UserDocumentViewAccess result = new UserDocumentViewAccess();

            result.HasAccess = true;
            result.Reason = "";

            // TODO: implement security logic to determine access
            //
            var accountSecurity = this.UserAccountSecurityByAccountClass(accountClassCode);
            bool hasBranchAccess = this.BranchSecurity.HasAccess(branchId);

            if (this.IsSuperUser)
            {
                result.HasAccess = true;
            }
            else if (accountSecurity != null && accountSecurity.AllowDocRead)
            {
                result.HasAccess = true;

                // ### Process security from general to specific settings
                //
                if (!hasBranchAccess)
                {
                    result.HasAccess = false;
                    result.Reason = "Branch Access Denied";
                }
                else if (!hasDocumentAccess)
                {
                    result.HasAccess = false;
                    result.Reason = "Document Access Denied";
                }
                else if (isEmployeeCustomerFile && !this.HasEmployeeFileAccess)
                {
                    result.HasAccess = false;
                    result.Reason = "Employee Access Denied";
                }
                else if (hasDemographicData == true && (this.HasPermission(RESOURCE_DOCUMENT, RESOURCE_DOCUMENT_NAME_DEMOGRAPHIC) == PERMISSION_TYPE_DENY))
                {
                    result.HasAccess = false;
                    result.Reason = "Demographic Data Access Denied";
                }
            }
            else
            {
                result.HasAccess = false;
                result.Reason = "Document Access Denied";
            }

            return result;
        }

        public bool AllowAnyDocumentScanAccess
        {
            get
            {
                bool result = false;

                for (int i = 0; i < m_accountSecurityList.Count; i++)
                {
                    result = result || m_accountSecurityList[i].AllowDocScan;
                }

                return result;
            }
        }

        public bool AllowAnyAdminAccess
        {
            get
            {
                bool result = false;

                for (int i = 0; i < m_accountSecurityList.Count; i++)
                {
                    result = result || m_accountSecurityList[i].IsAdmin;
                }

                return result;
            }
        }

        public bool AllowBranchAccess(string branchId)
        {
            return this.IsSuperUser || this.BranchSecurity.HasAccess(branchId);
        }

        public bool AllowEmployeeFileAccess(bool isEmployeeCustomerFile)
        {
            return this.IsSuperUser || (!isEmployeeCustomerFile || (this.HasEmployeeFileAccess && isEmployeeCustomerFile));
        }
    }

    public class UserAccountSecurity
    {
        public string AccountClassCode { get; set; }
        public bool AllowDocRead { get; set; }
        public bool AllowDocEdit { get; set; }
        public bool AllowDocAdd { get; set; }
        public bool AllowDocDelete { get; set; }
        public bool AllowDocScan { get; set; }
        public bool IsAdmin { get; set; }
    }

    public class UserPermission
    {
        public string Resource { get; set; }
        public string Name { get; set; }
        public int PermissionType { get; set; }
    }

    public class UserBranchSecurity
    {
        public List<string> AllowedBranches { get; set; }

        public UserBranchSecurity()
        {
            AllowedBranches = new List<string>();
        }

        public bool HasAccess(string branchId)
        {
            if (AllowedBranches == null || AllowedBranches.Count == 0)
            {
                return true;
            }
            return AllowedBranches.Contains(branchId);
        }
    }
}

