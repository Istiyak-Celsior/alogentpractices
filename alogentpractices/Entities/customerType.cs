using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class customerType
    {
        [Key]
        public int customerTypeId {  get; set; }
        public string customerTypeDescription {  get; set; }
    }
}
