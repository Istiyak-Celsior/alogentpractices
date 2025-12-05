using alogentpractices.DAL;
using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Metadata.Ecma335;

namespace alogentpractices.Pages
{
    public class taskgroupmaintModel : PageModel
    {
        [BindProperty]
        public string subHeaderText { set; get; }
        [BindProperty]
        public string action { set; get; }
        [BindProperty]
        public string taskGroupType { set; get; }
        [BindProperty]
        public int taskGroupId { set; get; }
        [BindProperty]
        public int bankId { set; get; }
        [BindProperty]
        public string taskGroupLabel { set; get; }
        [BindProperty]
        public string taskProcessing { set; get; }
        [BindProperty]
        public string taskTypeLabel { set; get; }

        [BindProperty]
        public TaskGroup taskGroup { set; get; }

        private readonly ApplicationDbContext _dbContext;

        public taskgroupmaintModel(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public IActionResult OnPostSave()
        {
            if (taskGroup == null)
            {
                return Page();
            }
            if (taskGroup.taskGroupId == 0)
            {
                var lastRecord = _dbContext.TaskGroups.OrderByDescending(x => x.taskGroupId).First();
                taskGroup.taskGroupId = lastRecord.taskGroupId + 1;

                //this i filled only for testing 
                string processing = taskGroup.TaskProcessing; // "C" or "L"
                string label = taskGroup.taskGroupLabel;
              
                _dbContext.TaskGroups.Add(taskGroup);
            }
            else
            {
                _dbContext.TaskGroups.Update(taskGroup);
            }

            _dbContext.SaveChanges();

            return RedirectToPage("/TaskGroupList", new { bankid = "1" });
        }

        public void OnGet()
        {
            var id = Request.Query["bankId"];

            if (string.IsNullOrEmpty(id))
            {
                throw new System.Exception("Invalid Bank id found.");
            }

            var taskgroupid = Request.Query["taskGroupId"];
            bankId = int.Parse(id);
            action = Request.Query["action"];
            taskGroupType = Request.Query["taskGroupType"];

            if (!string.IsNullOrEmpty(taskgroupid))
            {
                taskGroupId = int.Parse(taskgroupid);
            }

            subHeaderText = "Add New";

            if (action == "ADD")
            {
                taskGroup = new TaskGroup();
                taskTypeLabel = "Credit";
            }
            else
            { 
                taskGroup = (from n in _dbContext.TaskGroups
                             where n.taskGroupId == dbFormatId(taskGroupId)
                             orderby n.ProcessOrder, n.TaskLabel
                             select n).FirstOrDefault();

                if (taskGroup.TaskProcessing == "Execute Task in Order")
                {
                    taskProcessing = "S";
                }
                else
                {
                    taskProcessing = "P";
                }
            }
        }

        private int dbFormatId(int taskGroupId)
        {
            return taskGroupId;
        }

        public bool TaskHasException(int value)
        {
            return false;
        }

        public IEnumerable<Tasks> LoadTable()
        {
            return (from n in _dbContext.Tasks
                    where n.taskGroupId == dbFormatId(taskGroupId)
                    orderby n.ProcessOrder, n.TaskLabel
                    select n).ToList<Tasks>();
        }

        private void OldCode()
        {
            //            <%
            //Dim taskTypeLabel, subHeaderText
            //Dim action: action = Request("action")
            //Dim taskGroupId : taskGroupId = Request("taskGroupId")
            //Dim taskGroupType : taskGroupType = Request("taskGroupType")
            //Dim bankId : bankId = Request("bankId")
            //Dim taskGroupLabel : taskGroupLabel = ""
            //Dim taskProcessing : taskProcessing = "P"

            //Dim taskGroupRS : Set taskGroupRS = Server.CreateObject("ADODB.RecordSet")
            //IF action = "EDIT" THEN
            //    Dim taskGroupQuery: taskGroupQuery = "SELECT * FROM taskGroup WHERE taskGroupId=" & dbFormatId(taskGroupId)
            //    taskGroupRS.Open taskGroupQuery, db, adOpenStatic, adCmdText
            //    IF NOT taskGroupRS.EOF THEN
            //        taskGroupLabel = taskGroupRS("taskGroupLabel")
            //        taskProcessing = taskGroupRS("taskProcessing")
            //        taskGroupType = taskGroupRS("taskGroupType")
            //        bankId = taskGroupRS("bankId")
            //    END IF
            //    taskGroupRS.Close
            //END IF

            //FUNCTION TaskHasException(nTaskId)
            //    IF Trim(nTaskId &"") = "" THEN EXIT FUNCTION
            //    Dim hasExceptions: hasExceptions = false
            //    Dim TaskExceptionRS : Set TaskExceptionRS = Server.CreateObject("ADODB.RecordSet")
            //    Dim TaskExceptionQuery : TaskExceptionQuery = _
            //        "SELECT TOP 1 1 FROM exception WHERE TaskId = " & dbFormatId(nTaskId)
            //    TaskExceptionRS.Open TaskExceptionQuery, db, adOpenStatic, adCmdText
            //    IF NOT TaskExceptionRS.EOF THEN hasExceptions = true
            //    TaskExceptionRS.Close
            //    TaskHasException = hasExceptions
            //END FUNCTION

            //IF taskGroupType = "C" THEN
            //    taskTypeLabel = "Credit"
            //ELSE
            //    taskTypeLabel = "Account"
            //END IF

            //IF action = "ADD" THEN
            //    subHeaderText = "Add New " & taskTypeLabel & " Task Group"
            //ELSE
            //    subHeaderText = "Edit "
            //END IF
            //%>
        }
    }

    public class TaskItem
    {
        public int TaskId { get; set; }
        public int TaskGroupId { get; set; }
        public string TaskLabel { get; set; }
        public string ProcessOrder { get; set; }
        public bool EnableNotification { get; set; }
        public bool TransferableByUser { get; set; }
    }
}
