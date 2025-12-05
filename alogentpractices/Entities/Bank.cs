using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class Bank
    {
        [Key]
        public string bankId { set; get; }
        public string bankName { set; get; }
    }
}
