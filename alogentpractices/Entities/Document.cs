using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("document")]
    public class Document
    {
        [Key]
        public string documentId { get; set; }
        public string customerId { get; set; }
        public string loanId { get; set; }
        public string documentDefId { get; set; }
        public int? documentStatus { get; set; }
        public string documentTitle { get; set; }
        public string filename { get; set; }
    }
}
