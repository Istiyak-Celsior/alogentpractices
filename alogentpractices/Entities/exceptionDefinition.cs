using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class exceptionDefinition
    {
        [Key]
        public int exceptionDefId { get; set; }
        public string bankId { get; set; }
        public string exceptionDefType { get; set; }
        public int loanTypeId { get; set; }
        public int customerTypeId { get; set; }
        public string sortOrder { get; set; }
        public string exceptionDefName { get; set; }
        public string computationType { get; set; }
        public int targetTypeId { set; get; }
        public int weight { set; get; }
        public string PolicyId { get; set; }
    }
}
