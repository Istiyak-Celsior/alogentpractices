using alogentpractices.DAL;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace alogentpractices.Pages
{
    public class TaskGroupDeleteConfirmModel(ApplicationDbContext _context) : PageModel
    {
        [BindProperty(SupportsGet = true)]
        public int TaskGroupId { get; set; }

        public bool IsDeleted { get; set; } = false;
        public string TaskGroupLabel { get; set; }

        public async Task<IActionResult> OnGetAsync()
        {
            var taskGroup = await _context.TaskGroups.FindAsync(TaskGroupId);
            if (taskGroup == null)
            {
                return NotFound();
            }

            TaskGroupLabel = taskGroup.taskGroupLabel;
            return Page();
        }

        public async Task<IActionResult> OnPostAsync(string action)
        {
            if (action == "DELETE")
            {
                var taskGroup = await _context.TaskGroups.FindAsync(TaskGroupId);
                if (taskGroup != null)
                {
                   
                    _context.TaskGroups.Remove(taskGroup);
                    await _context.SaveChangesAsync();
                    IsDeleted = true;
                }
            }

            return Page();
        }
    }
}
