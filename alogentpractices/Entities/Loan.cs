using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("loan")]
    public class Loan
    {
        [Key]
        public string loanId { get; set; }
        public int? loanStatusId { get; set; }
        public string loanBranchId { get; set; }
    }
}
