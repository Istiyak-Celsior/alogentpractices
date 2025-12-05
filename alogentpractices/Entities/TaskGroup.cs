using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class TaskGroup
    {
        [Key]
        public int taskGroupId { get; set; }
        public string taskGroupType { set; get; }
        public string taskGroupLabel { set; get; }
        public string bankId { set; get; }
        public int taskCount { set; get; }
        public int exceptionCount { set; get; }
        public string TaskProcessing { set; get; }
        public int taskId { set; get; }
        public string ProcessOrder { set; get; }
        public string TaskLabel { set; get; }
        public bool enableNotification { set; get; }
        public bool transferableByUser { set; get; }

    }
}
