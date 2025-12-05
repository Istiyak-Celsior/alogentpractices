using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("documentSubType")]
    public class DocumentSubType
    {
        public int? documentTypeId { get; set; }
        public int? documentSubTypeId { get; set; }
        public string documentSubTypeName { get; set; }
    }
}
