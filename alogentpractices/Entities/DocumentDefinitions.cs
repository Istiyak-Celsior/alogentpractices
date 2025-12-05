using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace alogentpractices.Entities
{
    [Table("documentDefinitions")]
    public class DocumentDefinitions
    {
        [Key]
        public string documentDefId { get; set; }
        public int? documentTypeId { get; set; }
        public int? documentSubTypeId { get; set; }
        public string hideEmployeeFileYN { get; set; }
    }
}
