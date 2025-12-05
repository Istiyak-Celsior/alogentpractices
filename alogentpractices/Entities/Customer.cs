using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("customer")]
    public class Customer
    {
        [Key]
        public string customerId { get; set; }
        public string customerName { get; set; }
        public string bankId { get; set; }
        public string customerBranchId { get; set; }
        public string customerNumber { get; set; }
        public bool employee { get; set; }
    }
}
