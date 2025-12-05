using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("user")]
    public class User
    {
        [Key]
        public string userLogin { get; set; }
        public string userEmail { get; set; }
    }
}
