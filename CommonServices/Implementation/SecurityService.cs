using Microsoft.AspNetCore.Http;

namespace alogentpractices.Services
{
    public class SecurityService(IHttpContextAccessor _contextAccessor)
    {
        public void CheckLoginStatus()
        {
            var session = _contextAccessor.HttpContext.Session;

            var userInactive = session.GetString("userInactive");
            var userLoggedIn = session.GetString("userLoggedIn");
            var enableWindowsSecurityYN = session.GetString("enableWindowsSecurityYN");

            if (string.Equals(userInactive, "Y", StringComparison.OrdinalIgnoreCase))
            {
                session.SetString("userName", "");
                session.SetString("userID", "");
                _contextAccessor.HttpContext.Response.Redirect("default?error=3");
                return;
            }

            if (!string.Equals(userLoggedIn, "true", StringComparison.OrdinalIgnoreCase))
            {
                var loginErrorArgs = "";

                if (string.Equals(enableWindowsSecurityYN, "N", StringComparison.OrdinalIgnoreCase))
                {
                    loginErrorArgs = "?error=2";
                }

                _contextAccessor.HttpContext.Response.Redirect("default" + loginErrorArgs);
            }
        }

        public bool CheckRecordSecurity(string typeCode, string recordLevel)
        {
            string statusCheck = string.Empty;
            bool statusCheckFlag = false;
            string key = $"{typeCode}.{recordLevel}";
            statusCheck = _contextAccessor.HttpContext.Session.GetString(key);


            if (statusCheck == "")
            {
                statusCheckFlag = false;
            }

            bool isAdmin = Convert.ToBoolean(_contextAccessor.HttpContext.Session.Get($"{typeCode}.isAdmin"));
            bool isSuperUser = Convert.ToBoolean(_contextAccessor.HttpContext.Session.Get("isSuperUser"));

            return statusCheckFlag || isAdmin || isSuperUser;
        }

        public bool IsAdministrator()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "credit.isAdmin") ||
                   IsSessionFlagTrue(session, "loan.isAdmin") ||
                   IsSessionFlagTrue(session, "loanapp.isAdmin") ||
                   IsSessionFlagTrue(session, "deposit.isAdmin") ||
                   IsSessionFlagTrue(session, "trust.isAdmin") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsAccountAdministrator()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "loan.isAdmin") ||
                   IsSessionFlagTrue(session, "loanapp.isAdmin") ||
                   IsSessionFlagTrue(session, "deposit.isAdmin") ||
                   IsSessionFlagTrue(session, "trust.isAdmin") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsReader()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "credit.allowRead") ||
                   IsSessionFlagTrue(session, "loan.allowRead") ||
                   IsSessionFlagTrue(session, "loanapp.allowRead") ||
                   IsSessionFlagTrue(session, "deposit.allowRead") ||
                   IsSessionFlagTrue(session, "trust.allowRead") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsAccountReader()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "loan.allowRead") ||
                   IsSessionFlagTrue(session, "loanapp.allowRead") ||
                   IsSessionFlagTrue(session, "deposit.allowRead") ||
                   IsSessionFlagTrue(session, "trust.allowRead") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsEditor()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "credit.allowEdit") ||
                   IsSessionFlagTrue(session, "loan.allowEdit") ||
                   IsSessionFlagTrue(session, "loanapp.allowEdit") ||
                   IsSessionFlagTrue(session, "deposit.allowEdit") ||
                   IsSessionFlagTrue(session, "trust.allowEdit") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsAccountEditor()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "loan.allowEdit") ||
                   IsSessionFlagTrue(session, "loanapp.allowEdit") ||
                   IsSessionFlagTrue(session, "deposit.allowEdit") ||
                   IsSessionFlagTrue(session, "trust.allowEdit") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsCreator()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "credit.allowAdd") ||
                   IsSessionFlagTrue(session, "loan.allowAdd") ||
                   IsSessionFlagTrue(session, "loanapp.allowAdd") ||
                   IsSessionFlagTrue(session, "deposit.allowAdd") ||
                   IsSessionFlagTrue(session, "trust.allowAdd") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsAccountCreator()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "loan.allowAdd") ||
                   IsSessionFlagTrue(session, "loanapp.allowAdd") ||
                   IsSessionFlagTrue(session, "deposit.allowAdd") ||
                   IsSessionFlagTrue(session, "trust.allowAdd") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsDestroyer()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "credit.allowDelete") ||
                   IsSessionFlagTrue(session, "loan.allowDelete") ||
                   IsSessionFlagTrue(session, "loanapp.allowDelete") ||
                   IsSessionFlagTrue(session, "deposit.allowDelete") ||
                   IsSessionFlagTrue(session, "trust.allowDelete") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        public bool IsAccountDestroyer()
        {
            var session = _contextAccessor.HttpContext.Session;

            return IsSessionFlagTrue(session, "loan.allowDelete") ||
                   IsSessionFlagTrue(session, "loanapp.allowDelete") ||
                   IsSessionFlagTrue(session, "deposit.allowDelete") ||
                   IsSessionFlagTrue(session, "trust.allowDelete") ||
                   IsSessionFlagTrue(session, "isSuperUser");
        }

        private bool IsSessionFlagTrue(ISession session, string key)
        {
            var value = session.GetString(key);
            return !string.IsNullOrEmpty(value) &&
                   (value.Equals("true", StringComparison.OrdinalIgnoreCase) || value == "1");
        }

        public void CheckExceptionSecurity(int minLevel)
        {
            var session = _contextAccessor.HttpContext.Session;
            var permissionValueStr = session.GetString("permissionException");

            if (int.TryParse(permissionValueStr, out var permissionLevel))
            {
                if (permissionLevel < minLevel)
                {
                    _contextAccessor.HttpContext.Response.Redirect("/error?error=1");
                }
            }
            else
            {
                _contextAccessor.HttpContext.Response.Redirect("/error?error=1");
            }
        }

        public bool IsScanner(string extendedAccountClassCode)
        {
            var session = _contextAccessor.HttpContext.Session;
            var allowDocScanKey = $"{extendedAccountClassCode}.allowDocScan";
            var allowDocAddKey = $"{extendedAccountClassCode}.allowDocAdd";

            var allowDocScan = session.GetString(allowDocScanKey);
            var allowDocAdd = session.GetString(allowDocAddKey);
            var isSuperUser = session.GetString("isSuperUser");

            bool result = (allowDocScan == "true" && allowDocAdd == "true") || isSuperUser == "true";

            return result;
        }
    }
}
