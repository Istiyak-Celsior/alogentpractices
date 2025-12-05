using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace alogentpractices.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(IHttpContextAccessor httpContext, ILogger<IndexModel> logger)
        {
            httpContext.HttpContext.Session.SetInt32("accuaccount.enableExpress", 0); // means false
            httpContext.HttpContext.Session.SetString("isSuperUser", "True");
            httpContext.HttpContext.Session.SetString("credit.isAdmin", "True");
            httpContext.HttpContext.Session.SetString("credit.allowAdd", "True");
            httpContext.HttpContext.Session.SetString("UseBranchSecurity", "Y");
            httpContext.HttpContext.Session.SetInt32("BranchAccessCount", 5);
            httpContext.HttpContext.Session.SetString("accuaccount.disableImaging", "0");
            httpContext.HttpContext.Session.SetString("acculoan.showParticipationLoan", "1");
            httpContext.HttpContext.Session.SetInt32("accuaccount.enableNotices", 1);
            httpContext.HttpContext.Session.SetString("AccuAccount.Notice::Manage", "0");
            httpContext.HttpContext.Session.SetString("AccuAccount.Notice::Distribute", "0");
            httpContext.HttpContext.Session.SetString("AccuAccount.Audit::Manage", "0");
            _logger = logger;
        }

        public void OnGet()
        {

        }
    }
}
