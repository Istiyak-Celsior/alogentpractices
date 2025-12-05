using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;

namespace alogentpractices.Pages
{
    public class ExpiredQ2Model : PageModel
    {
        [BindProperty]
        public string searchName{ get; set; }
        [BindProperty]
        public string searchCustomerNumber { get; set; }
        [BindProperty]
        public string searchTaxId { get; set; }
        [BindProperty]
        public string searchCustomerStatus { get; set; }
        [BindProperty]
        public string searchLoan { get; set; }
        [BindProperty]
        public string searchLoanStatus { get; set; }
        [BindProperty]
        public string searchLoanTypeId { get; set; }
        [BindProperty]
        public string searchLoanOfficer { get; set; }
        [BindProperty]
        public string searchBank { get; set; }
        [BindProperty]
        public string searchCustomerTypeId { get; set; }
        [BindProperty]
        public string searchFromLoanOrgDate { get; set; }
        [BindProperty]
        public string searchToLoanOrgDate { get; set; }
        [BindProperty]
        public string searchPageSize { get; set; }
        [BindProperty]
        public string searchCustomerOfficer { get; set; }
        [BindProperty]
        public string searchLoanDescription { get; set; }
        [BindProperty]
        public string searchCustomerBranch { get; set; }
        [BindProperty]
        public string searchLoanBranch { get; set; }
        [BindProperty]
        public string searchClassificationId { get; set; }
        [BindProperty]
        public string searchAccountClassId { get; set; }
        [BindProperty]
        public string searchMaxResult { get; set; }
        [BindProperty]
        public string searchDocumentFilter { get; set; }
        [BindProperty]
        public string searchDisplayDocs { get; set; }
        [BindProperty]
        public string searchAppDateFrom { get; set; }
        [BindProperty]
        public string searchAppDateTo { get; set; }
        [BindProperty]
        public string searchAppLender { get; set; }
        [BindProperty]
        public string searchAppDelegate { get; set; }
        [BindProperty]
        public string searchAppAnalyst { get; set; }
        [BindProperty]
        public string searchApprovalStatusId { get; set; }
        [BindProperty]
        public string searchLoanStatusId { get; set; }
        [BindProperty]
        public string searchAppApprover { get; set; }
        public void OnGet()
        {
        }

        //GetAccountClassByLoanType

        //GetAllAccountClasses
        public List<AccountClass> getAllAccountClasses()
        {
                //using (var conn = new SqlConnection("YourConnectionString"))  //ADO.Net Connection String
                //using (var cmd = new SqlCommand("SELECT accountClassName, accountClassCode, accountClassId FROM AccountClasses", conn))
                //{
                //    conn.Open();
                //    using (var reader = cmd.ExecuteReader())
                //    {
                //        while (reader.Read())
                //        {
                //            accountClasses.Add(new
                //            {
                //                AccountClassName = reader["accountClassName"].ToString(),
                //                AccountClassCode = reader["accountClassCode"].ToString(),
                //                AccountClassId = Convert.ToInt32(reader["accountClassId"])
                //            });
                //        }
                //    }
                //}

            List<AccountClass> accClassesList = new List<AccountClass>
            {
                new AccountClass{accountClassId =101,accountClassCode="001",accountClassName="Test Acc class 1"},
                new AccountClass{accountClassId =102,accountClassCode="002",accountClassName="Test Acc class 2"},
                new AccountClass{accountClassId =103,accountClassCode="003",accountClassName="Test Acc class 3"},
                new AccountClass{accountClassId =104,accountClassCode="004",accountClassName="Test Acc class 4"},
            };
            
            return accClassesList;
        }
        public string GetAccountClassByLoanType(string loanTypeId)
        {
            string resultId = "101"; // null; // Mocking
            //string sqlQuery = "";@* "SELECT accountClassId FROM loanType WHERE loanTypeId = @loanTypeId"; *@
                        
            // using (var connection = new SqlConnection(ConnectionString))
            // {
            //     resultId = connection.ExecuteScalar<string>(sqlQuery, new { loanTypeId });
            // }

            return resultId;
        }



        public List<DocumentItem> BuildTabList(
            string tabType,
            int accountClassId,
            string searchCustomerTypeId,
            string searchLoanTypeId,
            string connectionString)
        {
            //    var documents = new List<DocumentItem>();

            //    using (var conn = new SqlConnection(connectionString))
            //    using (var cmd = conn.CreateCommand())
            //    {
            //        string baseQuery = @"
            //        SELECT DISTINCT
            //            dt.documentTypeId,
            //            dt.documentTypeName,
            //            dst.documentSubTypeId,
            //            dst.documentSubTypeName
            //        FROM documentType dt
            //        INNER JOIN documentSubType dst ON dt.documentTypeId = dst.documentTypeId
            //        LEFT OUTER JOIN documentDefinitions dd ON dd.documentTypeId = dt.documentTypeId AND dd.documentSubTypeId = dst.documentSubTypeId
            //    ";

            //        string whereClause = @" WHERE (ISNULL(dd.requireExpDate, 0) = 1 OR dst.subTypeRequireExpDateYN LIKE 'Y')
            //                           AND dt.typeCode LIKE @tabType
            //                           AND dst.documentSubTypeId IN (SELECT documentSubTypeId FROM documentDefinitions)";

            //        string joinClause = "";
            //        string filterClause = "";

            //        if (tabType == "C")
            //        {
            //            // Customer logic with optional customerType filter
            //            if (!string.IsNullOrEmpty(searchCustomerTypeId))
            //            {
            //                filterClause = " AND dd.customerTypeId = @searchCustomerTypeId";
            //                cmd.Parameters.AddWithValue("@searchCustomerTypeId", searchCustomerTypeId);
            //            }
            //        }
            //        else
            //        {
            //            // Loan logic with extra joins and filters
            //            joinClause = @"
            //            INNER JOIN documentTabAccountSecurity dtas ON dtas.documentSubTypeId = dst.documentSubTypeId AND dtas.accountClassId = @accountClassId
            //        ";

            //            if (!string.IsNullOrEmpty(searchLoanTypeId))
            //            {
            //                filterClause = " AND dd.loanTypeId = @searchLoanTypeId";
            //                cmd.Parameters.AddWithValue("@searchLoanTypeId", searchLoanTypeId);
            //            }

            //            cmd.Parameters.AddWithValue("@accountClassId", accountClassId);
            //        }

            //        cmd.CommandText = baseQuery + joinClause + whereClause + filterClause + @"
            //        ORDER BY dt.documentTypeName, dst.documentSubTypeName";

            //        cmd.Parameters.AddWithValue("@tabType", tabType);

            //        conn.Open();

            //        using (var reader = cmd.ExecuteReader())
            //        {
            //            while (reader.Read())
            //            {
            //                documents.Add(new DocumentItem
            //                {
            //                    DocumentTypeId = Convert.ToInt32(reader["documentTypeId"]),
            //                    DocumentTypeName = reader["documentTypeName"].ToString(),
            //                    DocumentSubTypeId = Convert.ToInt32(reader["documentSubTypeId"]),
            //                    DocumentSubTypeName = reader["documentSubTypeName"].ToString()
            //                });
            //            }
            //        }
            //    }
            List<DocumentItem> documents = new List<DocumentItem> { 
            new DocumentItem{DocumentTypeId=101,DocumentTypeName="DocTypeTest1",DocumentSubTypeId=201, DocumentSubTypeName="DocSubTypeTest1"},

            new DocumentItem{DocumentTypeId=102,DocumentTypeName="DocTypeTest2",DocumentSubTypeId=202, DocumentSubTypeName="DocSubTypeTest2"},

            new DocumentItem{DocumentTypeId=103,DocumentTypeName="DocTypeTest3",DocumentSubTypeId=203, DocumentSubTypeName="DocSubTypeTest3"},

            new DocumentItem{DocumentTypeId=104,DocumentTypeName="DocTypeTest4",DocumentSubTypeId=204, DocumentSubTypeName="DocSubTypeTest4"}
        };

            return documents;
        }
    

}
}
