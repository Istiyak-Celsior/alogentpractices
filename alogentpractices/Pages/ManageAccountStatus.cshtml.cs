using alogentpractices.DAL;
using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace alogentpractices.Pages
{
    public class ManageAccountStatusModel : PageModel
    {
        public string PageTitle = "Account status main";

        [BindProperty]
        public TaskGroupType TaskGroupTypes { set; get; }

        private readonly ApplicationDbContext _context;
        public string BankId = string.Empty;

        public ManageAccountStatusModel(ApplicationDbContext context)
        {
            _context = context;
        }

        public void OnGet()
        {
            BankId = Request.Query["bankId"];
            var TaskGroupTypeId = Request.Query["taskGroupType"];
            if (BankId == null || BankId == "0")
            {
                TaskGroupTypes = new TaskGroupType
                {
                    TaskGroupId = 0
                };
            }
            else
            {
                TaskGroupTypes = _context.TaskGroupTypes.FirstOrDefault(x => x.TaskGroupId == int.Parse(TaskGroupTypeId));
            }
        }

        public IActionResult OnPostSave()
        {
            if (TaskGroupTypes == null)
            {
                return Page();
            }

            if (TaskGroupTypes.TaskGroupId == 0)
            {
                var lastRecord = _context.TaskGroupTypes.OrderByDescending(x => x.TaskGroupId).First();
                TaskGroupTypes.TaskGroupId = lastRecord.TaskGroupId + 1;

                //this i filled only for testing 
                string processing = TaskGroupTypes.TaskProcessing; // "C" or "L"
                string label = TaskGroupTypes.TaskGroupLabel;

                _context.TaskGroupTypes.Add(TaskGroupTypes);
            }
            else
            {

                _context.TaskGroupTypes.Update(TaskGroupTypes);
            }

            _context.SaveChanges();

            return RedirectToPage("/TaskGroupList", new { bankid = "1" });
        }
    }
}
