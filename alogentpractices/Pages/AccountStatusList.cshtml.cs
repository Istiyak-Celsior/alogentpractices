using alogentpractices.DAL;
using alogentpractices.Entities;
using alogentpractices.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;

namespace alogentpractices.Pages
{
    public class AccountStatusListModel : PageModel
    {
        private readonly ApplicationDbContext _context;
        private readonly AccountStatusListService _accountStatusListService;

        public AccountStatusListModel(ApplicationDbContext context, AccountStatusListService accountStatusListService)
        {
            _context = context;
            _accountStatusListService = accountStatusListService;
        }

        public IList<AccountClass> AccountClass { get;set; } = default!;
        public string LoanAccountStatusList = string.Empty;
        public string AccountClassId = string.Empty;

        public async Task OnGetAsync()
        {
            AccountClassId = Request.Query["accountClassId"];
            var loanAccountStatusList = await _accountStatusListService.LoadAccountStatus(int.Parse(AccountClassId));
            LoanAccountStatusList = JsonConvert.SerializeObject(loanAccountStatusList);

            AccountClass = await _context.AccountClasses
                .Include(a => a.LoanStatuses)
                .OrderBy(x => x.AccountClassSortOrder)
                .ToListAsync();
        }
    }
}
