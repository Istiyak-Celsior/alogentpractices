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
        public int? isApplicationStatus { get; set; }
        public string statusDescription { get; set; }
        public string statusCode { get; set; }
        public bool isDefault { get; set; }
        public bool isActive { get; set; }
    }
}
