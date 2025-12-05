using alogentpractices.DAL;
using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace alogentpractices.Pages
{
    public class AccountStatusMainModel : PageModel
    {
        public string PageTitle = "Account status main";
        
        [BindProperty]
        public LoanStatus loanStatus { set; get; }

        private readonly ApplicationDbContext _context;

        public AccountStatusMainModel(ApplicationDbContext context)
        {
            _context = context;
        }

        public void OnGet()
        {
            loanStatus = new LoanStatus
            {
                statusId = 2,
                statusDescription = "",
                statusCode = "",
                isDefault = true,
                isActive = true,
                accountClassId = 1,
                isApplicationStatus = false,
                accountCount = 0
            };
        }

        public IActionResult OnPostSave()
        {
            if (loanStatus == null)
            {
                return Page();
            }

            var lastRecord = _context.LoanStatuses.OrderByDescending(x => x.statusId).First();
            loanStatus.statusId = lastRecord.statusId + 1;

            _context.LoanStatuses.Add(loanStatus);
            _context.SaveChanges();

            return RedirectToPage("/accountstatuslist", new { accountClassId = 1 });
        }
    }
}
