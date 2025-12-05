using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("loanStatus")]
    public class LoanStatus
    {
        [Key]
        public int statusId { get; set; }
        public int? accountClassId { get; set; }
        public bool? isApplicationStatus { get; set; }
        public string statusDescription { get; set; }
        public string statusCode { get; set; }
        public bool isDefault { get; set; }
        public bool isActive { get; set; }
        public bool isActiveApplicationStatus { set; get; }
        public bool isApprovedApplicationStatus { set; get; }
        public bool isDefaultApplicationStatus { set; get; }
        public int accountCount { set;get; }
    }
}
