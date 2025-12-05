using alogentpractices.DAL;
using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Text.Json;

namespace alogentpractices.Pages
{
    public class TaskGroupListModel(ApplicationDbContext _context) : PageModel
    {
        [BindProperty]
        public string bankId { get; set; }
        [BindProperty]
        public List<TaskGroup> taskGroups { set; get; }

        public string BankName { get; set; }
        public string Tab { get; set; }
        public List<TaskGroupType> TaskGroupTypeRecords { get; set; } = new();

        public IActionResult OnGet(string bankId, string tab)
        {
            if (string.IsNullOrEmpty(bankId))
            {
                HttpContext.Session.SetString("redirectURL", "/TaskGroupList");
                return RedirectToPage("/BankSelect");
            }

            this.bankId = bankId;
            Tab = string.IsNullOrEmpty(tab) ? "C" : tab;

            TaskGroupTypeRecords = _context.TaskGroupTypes
                .Where(x => x.TaskProcessing.Equals(Tab, StringComparison.OrdinalIgnoreCase))
                .ToList();

            return Page();
        }

        public List<TaskGroup> GetTaskGroupDetails(string taskGroupType)
        {
            return (from tg in _context.TaskGroups
                    where tg.taskGroupType == taskGroupType && tg.bankId == dbFormatId(@bankId)
                    orderby tg.taskGroupLabel
                    select new TaskGroup
                    {
                        taskGroupId = tg.taskGroupId,
                        taskGroupLabel = tg.taskGroupLabel,
                        taskGroupType = tg.taskGroupType,
                        taskCount = (from t in _context.Tasks
                                     where t.taskGroupId == tg.taskGroupId
                                     select t).Count(),

                        exceptionCount = (from t in _context.Tasks
                                          join ex in _context.Exceptions on t.taskId equals ex.taskId
                                          where t.taskGroupId == tg.taskGroupId
                                          select ex).Count()
                    }).ToList();
        }

        public async Task<JsonResult> OnPostDeleteTaskGroupAsync()
        {
            using var reader = new StreamReader(Request.Body);
            var body = await reader.ReadToEndAsync();

            var data = JsonSerializer.Deserialize<Dictionary<string, int>>(body);
            int taskGroupId = data.ContainsKey("taskGroupId") ? data["taskGroupId"] : 0;

            if (taskGroupId == 0)
            {
                return new JsonResult(new { success = false, message = "Invalid Task Group ID." });
            }

            var taskGroup = _context.TaskGroups.FirstOrDefault(t => t.taskGroupId == taskGroupId);

            if (taskGroup == null)
            {
                taskGroup = new TaskGroup
                {
                    taskGroupId = taskGroupId,
                    taskGroupLabel = "Hardcoded Test Label",
                    TaskProcessing = "P",
                };
            }

            _context.TaskGroups.Remove(taskGroup);
            await _context.SaveChangesAsync();

            return new JsonResult(new { success = true });
        }

        private string dbFormatId(string bankId)
        {
            return bankId.ToUpper();
        }
    }
}
