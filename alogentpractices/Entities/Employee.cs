using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table(name: "employees")]
    public class Employee
    {
        [Required]
        [Key]
        public long EmployeeUid { get; set; }

        [Column("FirstName")]
        public string FirstName { get; set; }

        [Column("LastName")]
        public string LastName { get; set; }

        [Column("Email")]
        public string Email { get; set; }

        [Column("Mobile")]
        public string Mobile { get; set; }
    }
}
