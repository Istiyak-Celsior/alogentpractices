using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class customerTypeDescription
    {
        [Key]
        public int customerTypeId {  get; set; }
        public string bankId { get; set; }
        public int customerTypeDescriptionId { get; set; }
    }
}
