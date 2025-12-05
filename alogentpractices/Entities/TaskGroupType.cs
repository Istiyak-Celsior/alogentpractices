using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class TaskGroupType
    {
        [Key]
        public int TaskGroupId { get; set; }
        public string TaskGroupLabel { get; set; }
        public int TaskCount { get; set; }
        public int ExceptionCount { get; set; }
        public string TaskProcessing { get; set; }
    }
}
