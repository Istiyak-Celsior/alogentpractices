using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("documentType")]
    public class DocumentType
    {
        [Key]
        public int documentTypeId { get; set; }
        public string documentTypeName { get; set; }
    }
}
