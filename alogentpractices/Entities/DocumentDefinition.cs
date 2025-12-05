namespace alogentpractices.Entities
{
    public class DocumentDefinition
    {
        public int DocumentDefId { get; set; }
        public string DocumentDefType { get; set; }
        public int? CustomerTypeId { get; set; }
        public int? LoanTypeId { get; set; }
        public string DocumentTypeName { get; set; }
        public string DocumentSubTypeName { get; set; }
        public int SortOrder { get; set; }
        public int BankId { get; set; }
    }
}
