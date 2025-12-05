using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class loanTypes
    {
        [Key]
        public int loanTypeId { set; get; }
        public int accountClassId { set; get; }
        public string loanTypeDescription { set; get; }
    }
}
