using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class documentDefinations
    {
        [Key]
        public int loanTypeId { set; get; }
        public string bankId { set; get; }
        public int documentDefinationId { set; get; }
    }
}
