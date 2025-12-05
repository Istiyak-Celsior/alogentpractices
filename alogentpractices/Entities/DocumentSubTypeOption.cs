using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("documentSubTypeOption")]
    public class DocumentSubTypeOption
    {
        [Key]
        public int documentSubTypeId { get; set; }
        public bool? hasDemographicData { get; set; }
    }
}
