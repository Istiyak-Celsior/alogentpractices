using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("documentHistory")]
    public class DocumentHistory
    {
        [Key]
        public string historyId { get; set; }
        public string documentId { get; set; }
        public string documentType { get; set; }
        public int? qcStatus { get; set; }
        public string qcHistory { get; set; }
        public string userLogin { get; set; }
    }
}
