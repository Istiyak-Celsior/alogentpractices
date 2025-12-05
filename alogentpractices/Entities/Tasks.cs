using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class Tasks
    {
        [Key]
        public int taskGroupId { set; get; }
        public int taskId { set; get; }
        public string ProcessOrder { set; get; }
        public string TaskLabel { set; get; }
        public bool enableNotification { set; get; }
        public bool transferableByUser { set; get; }
    }
}
