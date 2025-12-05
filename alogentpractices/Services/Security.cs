using Microsoft.AspNetCore.Http;

namespace alogentpractices.Services
{
    public class Security
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public Security(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private ISession Session => _httpContextAccessor.HttpContext.Session;
        private HttpResponse Response => _httpContextAccessor.HttpContext.Response;

        // If inactive user redirect to error page
        public void CheckUserSecurity()
        {
            if (Session.GetString("userInactive") == "Y")
            {
                Session.SetString("userName", "");
                Session.SetString("userID", "");
                Response.Redirect("default?error=3");
            }

            if (Session.GetString("userLoggedIn") == null || Session.GetString("userLoggedIn") != "true")
            {
                string loginErrorArgs = "";

                // only pass error argument if windows authentication is off.
                // Necessary due to users bookmarking pages other than the default
                // when autologin is enabled.
                if (Session.GetString("enableWindowsSecurityYN") == "N")
                {
                    loginErrorArgs = "?error=2";
                }

                Response.Redirect("default" + loginErrorArgs);
            }
        }

        // Flags for the various levels of Record and Document Security
        public const string REC_READ = "allowRead";
        public const string REC_EDIT = "allowEdit";
        public const string REC_ADD = "allowAdd";
        public const string REC_DELETE = "allowDelete";
        public const string DOC_READ = "allowDocRead";
        public const string DOC_EDIT = "allowDocEdit";
        public const string DOC_ADD = "allowDocAdd";
        public const string DOC_DELETE = "allowDocDelete";
        public const string DOC_SCAN = "allowDocScan";
        public const string DOC_SCAN_DELETE = "allowDocScanDelete";
        public const string DOC_UPLOAD = "allowDocUpload";
        public const string DOC_MOVECOPY = "allowDocMoveCopy";
        public const string IS_ADMIN = "isAdmin";

        // This is used for bitwise checks of security
        // and should be used over the above flags when possible
        public const int SEC_NONE = 0;
        public const int SEC_READ = 1;        // 2^0
        public const int SEC_EDIT = 2;        // 2^1
        public const int SEC_ADD = 4;         // 2^2
        public const int SEC_DELETE = 8;      // 2^3
        public const int SEC_DOC_READ = 16;   // 2^4
        public const int SEC_DOC_EDIT = 32;   // 2^5
        public const int SEC_DOC_ADD = 64;    // 2^6
        public const int SEC_DOC_DELETE = 128; // 2^7
        public const int SEC_DOC_SCAN = 256;  // 2^8
        public const int SEC_DOC_SCAN_DELETE = 512; // 2^9
        public const int SEC_DOC_UPLOAD = 1024; // 2^10
        public const int SEC_DOC_MOVECOPY = 2048; // 2^11
        public const int SEC_ADMIN = 4096;    // 2^12

        public bool CheckRecordSecurity(string typeCode, string recordLevel)
        {
            bool statusCheck;
            string statusCheckValue = Session.GetString(typeCode + "." + recordLevel);

            if (string.IsNullOrEmpty(statusCheckValue))
            {
                statusCheck = false;
            }
            else
            {
                statusCheck = bool.Parse(statusCheckValue);
            }

            // Always take into account Admin and SuperUser access for Records.
            bool isAdmin = Session.GetString(typeCode + ".isAdmin") == "true";
            bool isSuperUser = Session.GetString("isSuperUser") == "true";

            return (statusCheck || isAdmin || isSuperUser);
        }

        public bool CheckDocumentSecurity(string typeCode, string documentLevel)
        {
            bool statusCheck;
            string statusCheckValue = Session.GetString(typeCode + "." + documentLevel);

            if (string.IsNullOrEmpty(statusCheckValue))
            {
                statusCheck = false;
            }
            else
            {
                statusCheck = bool.Parse(statusCheckValue);
            }

            // Use the better of the individual status or the admin flag
            if (documentLevel == DOC_READ
                || documentLevel == DOC_EDIT
                || documentLevel == DOC_ADD
                || documentLevel == DOC_DELETE)
            {
                bool isAdmin = Session.GetString(typeCode + ".isAdmin") == "true";
                statusCheck = (statusCheck || isAdmin);
            }

            // Account for SuperUser access
            bool isSuperUser = Session.GetString("isSuperUser") == "true";
            return (statusCheck || isSuperUser);
        }

        public bool IsAdministrator()
        {
            bool result =
                Session.GetString("credit.isAdmin") == "true"
                || Session.GetString("loan.isAdmin") == "true"
                || Session.GetString("loanapp.isAdmin") == "true"
                || Session.GetString("deposit.isAdmin") == "true"
                || Session.GetString("trust.isAdmin") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsAccountAdministrator()
        {
            bool result =
                Session.GetString("loan.isAdmin") == "true"
                || Session.GetString("loanapp.isAdmin") == "true"
                || Session.GetString("deposit.isAdmin") == "true"
                || Session.GetString("trust.isAdmin") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsReader()
        {
            bool result =
                Session.GetString("credit.allowRead") == "true"
                || Session.GetString("loan.allowRead") == "true"
                || Session.GetString("loanapp.allowRead") == "true"
                || Session.GetString("deposit.allowRead") == "true"
                || Session.GetString("trust.allowRead") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsAccountReader()
        {
            bool result =
                Session.GetString("loan.allowRead") == "true"
                || Session.GetString("loanapp.allowRead") == "true"
                || Session.GetString("deposit.allowRead") == "true"
                || Session.GetString("trust.allowRead") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsEditor()
        {
            bool result =
                Session.GetString("credit.allowEdit") == "true"
                || Session.GetString("loan.allowEdit") == "true"
                || Session.GetString("loanapp.allowEdit") == "true"
                || Session.GetString("deposit.allowEdit") == "true"
                || Session.GetString("trust.allowEdit") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsAccountEditor()
        {
            bool result =
                Session.GetString("loan.allowEdit") == "true"
                || Session.GetString("loanapp.allowEdit") == "true"
                || Session.GetString("deposit.allowEdit") == "true"
                || Session.GetString("trust.allowEdit") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsCreator()
        {
            bool result =
                Session.GetString("credit.allowAdd") == "true"
                || Session.GetString("loan.allowAdd") == "true"
                || Session.GetString("loanapp.allowAdd") == "true"
                || Session.GetString("deposit.allowAdd") == "true"
                || Session.GetString("trust.allowAdd") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsAccountCreator()
        {
            bool result =
                Session.GetString("loan.allowAdd") == "true"
                || Session.GetString("loanapp.allowAdd") == "true"
                || Session.GetString("deposit.allowAdd") == "true"
                || Session.GetString("trust.allowAdd") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsDestroyer()
        {
            bool result =
                Session.GetString("credit.allowDelete") == "true"
                || Session.GetString("loan.allowDelete") == "true"
                || Session.GetString("loanapp.allowDelete") == "true"
                || Session.GetString("deposit.allowDelete") == "true"
                || Session.GetString("trust.allowDelete") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public bool IsAccountDestroyer()
        {
            bool result =
                Session.GetString("loan.allowDelete") == "true"
                || Session.GetString("loanapp.allowDelete") == "true"
                || Session.GetString("deposit.allowDelete") == "true"
                || Session.GetString("trust.allowDelete") == "true"
                || Session.GetString("isSuperUser") == "true";
            return result;
        }

        public void CheckExceptionSecurity(int minLevel)
        {
            // Check for minimum security levels
            // userSecurity Admin+ always checks out, otherwise check the permissionException level
            // for minimum level of security
            string permissionExceptionValue = Session.GetString("permissionException");
            int permissionException = string.IsNullOrEmpty(permissionExceptionValue) ? 0 : int.Parse(permissionExceptionValue);

            if (permissionException < minLevel)
            {
                Response.Redirect("error?error=1");
            }
        }

        public bool IsScanner(string extendedAccountClassCode)
        {
            bool result =
                (Session.GetString(extendedAccountClassCode + ".allowDocScan") == "true" && Session.GetString(extendedAccountClassCode + ".allowDocAdd") == "true")
                || Session.GetString("isSuperUser") == "true";

            return result;
        }
    }
}