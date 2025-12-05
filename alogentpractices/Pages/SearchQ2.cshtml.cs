using alogentpractices.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using System.Text.Json; // For serializing/deserializing the ViewModel

namespace alogentpractices.Pages
{

    public class SearchQ2Model : PageModel
    {
        [BindProperty]
        public string SearchName { get; set; }
        [BindProperty]
        public string SearchCustomerNumber { get; set; }
        [BindProperty]
        public string SearchTaxId { get; set; }
        [BindProperty]
        public string SearchCustomerStatus { get; set; }
        [BindProperty]
        public string SearchLoan { get; set; }
        [BindProperty]
        public string SearchLoanStatus { get; set; }
        [BindProperty]
        public string SearchLoanTypeId { get; set; }
        [BindProperty]
        public string SearchLoanOfficer { get; set; }
        [BindProperty]
        public string SearchBank { get; set; }
        [BindProperty]
        public string SearchCustomerTypeId { get; set; }
        [BindProperty]
        public string SearchFromLoanOrgDate { get; set; }
        [BindProperty]
        public string SearchToLoanOrgDate { get; set; }
        [BindProperty]
        public string SearchPageSize { get; set; }
        [BindProperty]
        public string SearchCustomerOfficer { get; set; }
        [BindProperty]
        public string SearchLoanDescription { get; set; }
        [BindProperty]
        public string SearchCustomerBranch { get; set; }
        [BindProperty]
        public string SearchLoanBranch { get; set; }
        [BindProperty]
        public string SearchClassificationId { get; set; }
        [BindProperty]
        public string SearchAccountClassId { get; set; }
        [BindProperty]
        public string SearchMaxResult { get; set; }
        [BindProperty]
        public string SearchDocumentFilter { get; set; }
        [BindProperty]
        public string SearchDisplayDocs { get; set; }
        [BindProperty]
        public string SearchAppDateFrom { get; set; }
        [BindProperty]
        public string SearchAppDateTo { get; set; }
        [BindProperty]
        public string SearchAppLender { get; set; }
        [BindProperty]
        public string SearchAppDelegate { get; set; }
        [BindProperty]
        public string SearchAppAnalyst { get; set; }
        [BindProperty]
        public string SearchApprovalStatusId { get; set; }
        [BindProperty]
        public string SearchLoanStatusId { get; set; }
        [BindProperty]
        public string SearchAppApprover { get; set; }


        // Binds form data directly to this property on POST requests
        [BindProperty]
        public SearchViewModel SearchData { get; set; }
        // Add these properties to your SearchQ2Model class

        public string searchLoanTypeId { get; set; }
        public string searchAccountClassId { get; set; }
       
        private readonly IConfiguration _configuration;
        public SearchQ2Model(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public void OnGet()
        {
           
        }

    

            
      
        // Mocking getAccount clss by Loan Type database data for demonstration purposes
        public List<int> getAccountClassByLoanTypeData()
        {
            List<loanTypes> loanObj = new List<loanTypes>
            {
                new loanTypes { loanTypeId = 101, accountClassId = 101, loanTypeDescription = "AC Assignment (Loan)" },
                new loanTypes { loanTypeId = 102, accountClassId = 102, loanTypeDescription = "AC Real Estate (Loan)" },
                new loanTypes { loanTypeId = 103, accountClassId = 103, loanTypeDescription = "AC Titled Vehicle (Loan)" },
                new loanTypes { loanTypeId = 104, accountClassId = 104, loanTypeDescription = "AC UCC (Loan)" },
                new loanTypes { loanTypeId = 105, accountClassId = 105, loanTypeDescription = "Commercial Non Real Estate (Loan)" },
                new loanTypes { loanTypeId = 106, accountClassId = 106, loanTypeDescription = "Commercial Real Estate (Loan)" },
            };

            // Return a list of accountClassId(s) matching the given loanTypeId
            int lid = 101;
            var filteredAccountClassIds = loanObj
                .Where(ln => ln.loanTypeId == lid)
                .Select(ln => ln.accountClassId)
                .ToList();

            return filteredAccountClassIds;
        }
        public int? GetAccountClassByLoanType(int loanTypeId)
        {
            int? resultId = null;

            // Retrieve connection string from appsettings.json
            string connectionString = _configuration.GetConnectionString("DefaultConnection");

            if (string.IsNullOrEmpty(connectionString))
            {
                // Handle error: connection string not found
                return null;
            }

            resultId = 101; // getAccountClassByLoanTypeData(loanTypeId.ToString()).FirstOrDefault();

            //using (SqlConnection conn = new SqlConnection(connectionString))
            //{
            //    // Use parameterized queries to prevent SQL injection
            //    string sqlQuery = "SELECT accountClassId FROM loanType WHERE loanTypeId = @loanTypeId";

            //    using (SqlCommand cmd = new SqlCommand(sqlQuery, conn))
            //    {
            //        cmd.Parameters.AddWithValue("@loanTypeId", loanTypeId);

            //        try
            //        {
            //            conn.Open();
            //            object accountClassId = cmd.ExecuteScalar();

            //            if (accountClassId != null && accountClassId != DBNull.Value)
            //            {
            //                resultId = Convert.ToInt32(accountClassId);
            //            }
            //        }
            //        catch (SqlException ex)
            //        {
            //            // Log the error
            //            // For example, using a logging framework like ILogger
            //            // _logger.LogError(ex, "Error retrieving account class.");
            //        }
            //    }
            //}

            return resultId;
        }

        public void GetAccountClasses()
        {

        }

       
        public List<DocumentItem> BuildTabList(string tabType, string accountClassName, int accountClassId,
                                               string searchCustomerTypeId, string searchLoanTypeId,
                                               string connectionString)
        {
            var documents = new List<DocumentItem>();

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = conn.CreateCommand())
            {
                string whereClause = " WHERE dt.typeCode = @tabType " +
                                     " AND dst.documentSubTypeId IN (SELECT documentSubTypeId FROM documentDefinitions) ";

                string joinClause = "";
                if (tabType == "C")
                {
                    // Customer type branch
                    if (!string.IsNullOrEmpty(searchCustomerTypeId))
                    {
                        joinClause = " INNER JOIN documentDefinitions AS dd " +
                                     " ON dd.documentTypeId=dt.documentTypeId " +
                                     " AND dd.documentSubTypeId=dst.documentSubTypeId " +
                                     " AND dd.customerTypeId = @searchCustomerTypeId ";
                    }
                }
                else
                {
                    // Loan type branch
                    joinClause = " INNER JOIN documentTabAccountSecurity AS dtas " +
                                 " ON dtas.documentSubTypeId = dst.documentSubTypeId " +
                                 " AND dtas.accountClassId = @accountClassId ";

                    if (!string.IsNullOrEmpty(searchLoanTypeId))
                    {
                        joinClause += " INNER JOIN documentDefinitions AS dd " +
                                      " ON dd.documentTypeId = dt.documentTypeId " +
                                      " AND dd.documentSubTypeId = dst.documentSubTypeId " +
                                      " AND dd.loanTypeId = @searchLoanTypeId ";
                    }
                }

                cmd.CommandText = @"
                SELECT DISTINCT
                    dt.documentTypeId,
                    dt.documentTypeName,
                    dst.documentSubTypeId,
                    dst.documentSubTypeName
                FROM documentType AS dt
                INNER JOIN documentSubType AS dst
                    ON dt.documentTypeId = dst.documentTypeId
                " + joinClause + whereClause + @"
                ORDER BY dt.documentTypeName, dst.documentSubTypeName";

                // Parameters
                cmd.Parameters.AddWithValue("@tabType", tabType);
                if (!string.IsNullOrEmpty(searchCustomerTypeId))
                    cmd.Parameters.AddWithValue("@searchCustomerTypeId", searchCustomerTypeId);
                if (!string.IsNullOrEmpty(searchLoanTypeId))
                    cmd.Parameters.AddWithValue("@searchLoanTypeId", searchLoanTypeId);
                cmd.Parameters.AddWithValue("@accountClassId", accountClassId);

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        documents.Add(new DocumentItem
                        {
                            DocumentTypeId = Convert.ToInt32(reader["documentTypeId"]),
                            DocumentTypeName = reader["documentTypeName"].ToString(),
                            DocumentSubTypeId = Convert.ToInt32(reader["documentSubTypeId"]),
                            DocumentSubTypeName = reader["documentSubTypeName"].ToString()
                        });
                    }
                }
            }
            return documents;
        }
    }

}


