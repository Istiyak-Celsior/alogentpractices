using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("accountClass")]
    public class AccountClass
    {
        [Key]
        public int accountClassId { get; set; }
        public string accountClassCode { get; set; }
        public string accountClassName { set; get; }
        public string accountClassSortOrder { set; get; }
    }
}
