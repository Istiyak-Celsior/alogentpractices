namespace alogentpractices.Services
{
    public class DocumentTabSecurity
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public DocumentTabSecurity(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private ISession Session => _httpContextAccessor.HttpContext.Session;

        public int creditTabSecurityRows { get; set; }
        public int accountTabSecurityRows { get; set; }
        public int gblAccountClassCount { get; set; }
        public object[,] creditTabSecurity { get; set; }
        public object[,] accountTabSecurity { get; set; }
        public Dictionary<string, int> tabSecurityFields { get; set; }

        public bool AllowCreditTabAccess(int? documentSubTypeId)
        {
            int tabIdx, accountOffset;
            string fn_AccountClassCode;
            bool accessResult = false;

            for (tabIdx = 0; tabIdx <= creditTabSecurityRows - 1; tabIdx++)
            {
                if (documentSubTypeId.ToString() == creditTabSecurity[tabSecurityFields["documentSubTypeId"], tabIdx].ToString())
                {
                    for (accountOffset = 0; accountOffset <= gblAccountClassCount - 1; accountOffset++)
                    {
                        fn_AccountClassCode = creditTabSecurity[tabSecurityFields["accountClassCode"], tabIdx + accountOffset].ToString();
                        if (Convert.ToBoolean(creditTabSecurity[tabSecurityFields["allowAccess"], tabIdx + accountOffset])
                            && (
                                 Session.GetString(fn_AccountClassCode + ".allowDocRead") == "true"
                                 || Session.GetString(fn_AccountClassCode + ".allowDocEdit") == "true"
                                 || Session.GetString(fn_AccountClassCode + ".allowDocAdd") == "true"
                                 || Session.GetString(fn_AccountClassCode + ".allowDocDelete") == "true"
                                 || Session.GetString(fn_AccountClassCode + ".isAdmin") == "true"
                                 || Session.GetString("isSuperUser") == "true"
                               ))
                        {
                            accessResult = true;
                        }
                    }
                    break;
                }
            }
            return accessResult;
        }

        public bool AllowAccountTabAccess(int? documentSubTypeId)
        {
            int tabIdx, accountOffset;
            string fn_AccountClassCode;
            bool accessResult = false;

            for (tabIdx = 0; tabIdx <= accountTabSecurityRows - 1; tabIdx++)
            {
                if (documentSubTypeId.ToString() == accountTabSecurity[tabSecurityFields["documentSubTypeId"], tabIdx].ToString())
                {
                    for (accountOffset = 0; accountOffset <= gblAccountClassCount - 1; accountOffset++)
                    {
                        fn_AccountClassCode = accountTabSecurity[tabSecurityFields["accountClassCode"], tabIdx + accountOffset].ToString();
                        if ((fn_AccountClassCode ?? "").Trim() == "loan")
                        {
                            if (Convert.ToBoolean(accountTabSecurity[tabSecurityFields["allowAccess"], tabIdx + accountOffset])
                                && (
                                        Session.GetString(fn_AccountClassCode + ".allowDocRead") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".allowDocEdit") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".allowDocAdd") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".allowDocDelete") == "true"
                                        || Session.GetString(fn_AccountClassCode + "app.allowDocRead") == "true"
                                        || Session.GetString(fn_AccountClassCode + "app.allowDocEdit") == "true"
                                        || Session.GetString(fn_AccountClassCode + "app.allowDocAdd") == "true"
                                        || Session.GetString(fn_AccountClassCode + "app.allowDocDelete") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".isAdmin") == "true"
                                        || Session.GetString("isSuperUser") == "true"
                                   ))
                            {
                                accessResult = true;
                            }
                        }
                        else
                        {
                            if (Convert.ToBoolean(accountTabSecurity[tabSecurityFields["allowAccess"], tabIdx + accountOffset])
                                && (
                                        Session.GetString(fn_AccountClassCode + ".allowDocRead") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".allowDocEdit") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".allowDocAdd") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".allowDocDelete") == "true"
                                        || Session.GetString(fn_AccountClassCode + ".isAdmin") == "true"
                                        || Session.GetString("isSuperUser") == "true"
                                   ))
                            {
                                accessResult = true;
                            }
                        }
                    }
                    break;
                }
            }
            return accessResult;
        }
    }
}