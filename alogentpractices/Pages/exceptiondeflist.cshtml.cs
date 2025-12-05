using alogentpractices.DAL;
using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace alogentpractices.Pages
{
    public class exceptiondeflistModel(ApplicationDbContext _context) : PageModel
    {
        [BindProperty]
        public string bankId { set; get; }
        [BindProperty]
        public string exceptionDefType { set; get; }
        [BindProperty]
        public string collapseTypeId { set; get; }
        [BindProperty]
        public string expandAll { set; get; }
        [BindProperty]
        public string activeTab { set; get; }
        [BindProperty]
        public string expandTypeId { set; get; }
        [BindProperty]
        public string exceptionActiveBankId { set; get; }

        public void OnGet()
        {
            exceptionDefType = Request.Query["exceptionDefType"];
            expandTypeId = Request.Query["expandTypeId"];
            collapseTypeId = Request.Query["collapseTypeId"];
            expandAll = Request.Query["expandAll"];
            activeTab = Request.Query["activeTab"];
            exceptionActiveBankId = Request.Query["exceptionActiveBankId"];

            if (string.IsNullOrEmpty(exceptionActiveBankId))
            {
                exceptionActiveBankId = "1";
            }
        }

        public void LoadData()
        {
            string loanStyle = string.Empty;
            string activeTabStyle = string.Empty;
            string displayLabel = string.Empty;
            string targetIdFieldName = string.Empty;
            string targetType = string.Empty;
            string targetDescriptionFieldName = string.Empty;

            if (expandAll == "")
            {
                expandAll = "N";
            }

            if (bankId == "")
            {
                bankId = exceptionActiveBankId;
            }
            else
            {
                bankId = bankId;
                exceptionActiveBankId = bankId;
                var sqlGetBankName = (from n in _context.banks
                                      where n.bankId == bankId
                                      select n).FirstOrDefault<Bank>();

                string exceptionActiveBankName = sqlGetBankName.bankName;
            }

            if ((bankId ?? "").Trim() == "")
            {
                HttpContext.Session.SetString("errFlag", "true");
                HttpContext.Session.SetString("errMsg", "You must choose a bank to enter Exception Maintenance.");
                Response.Clear();
                Response.Redirect("/exceptionbankselection");
            }

            string customerStyle = "tabStyle1";
            if (exceptionDefType == "")
            {
                exceptionDefType = "customer";
                activeTab = "credit";
            }

            if (exceptionDefType == "customer")
            {
                var targetTypeQuery = (from n in _context.customerTypes
                                       join m in _context.customerTypeDescriptions on n.customerTypeId equals m.customerTypeId
                                       where m.bankId == dbFormatId(bankId)
                                       group m by new { n.customerTypeId, n.customerTypeDescription } into g
                                       orderby g.Key.customerTypeDescription
                                       select new
                                       {
                                           customerTypeId = g.Key.customerTypeId,
                                           customerTypeDescription = g.Key.customerTypeDescription,
                                       }).ToList();

                targetDescriptionFieldName = "customerTypeDescription";
                targetIdFieldName = "customerTypeId";
                targetType = "C";
                activeTabStyle = customerStyle;
                displayLabel = "Credit";
            }
            else
            {
                var targetTypeQuery = (from lt in _context.loanTypes
                                       join dd in _context.documentDefinations
                                            on lt.loanTypeId equals dd.loanTypeId
                                       join ac in _context.AccountClasses
                                            on lt.accountClassId equals ac.accountClassId
                                       where dd.bankId == dbFormatId(bankId)
                                       && ac.accountClassCode.Contains(dbFormatId(activeTab))
                                       group ac by new { lt.loanTypeId, lt.loanTypeDescription } into g
                                       orderby g.Key.loanTypeDescription
                                       select new
                                       {
                                           loanTypeId = g.Key.loanTypeId,
                                           loanTypeDescription = g.Key.loanTypeDescription,
                                       }).ToList();

                targetDescriptionFieldName = "loanTypeDescription";

                if (activeTab == "loan")
                {
                    loanStyle = "tabStyle3";
                    activeTabStyle = loanStyle;
                    displayLabel = "Loan";
                }
                else if (activeTab == "deposit")
                {
                    loanStyle = "tabStyle2";
                    activeTabStyle = loanStyle;
                    displayLabel = "Deposit";
                }
                else if (activeTab == "trust")
                {
                    loanStyle = "tabStyle4";
                    activeTabStyle = loanStyle;
                    displayLabel = "Trust";
                }

                targetIdFieldName = "loanTypeId";
                targetType = "L";
            }
        }

        public string dbFormatId(string bankId)
        {
            return bankId;
        }
    }
}
