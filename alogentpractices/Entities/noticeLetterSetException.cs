using System.ComponentModel.DataAnnotations;

namespace alogentpractices.Entities
{
    public class noticeLetterSetException
    {
        [Key]
        public string noticeLetterSetExceptionId { get; set; }
        public int exceptionDefinitionId { set; get; }
    }
}
