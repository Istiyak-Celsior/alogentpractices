using alogentpractices.Entities;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Collections.Generic;

namespace alogentpractices.Pages
{
    public class SearchQ1Model : PageModel
    {
        [BindProperty]
        public string searchHeader { set; get; }

        [BindProperty]
        public string searchType { set; get; }
        //public List<CustomerType> CustomerTypeList { get; set; }
        public string SelectedCustomerType { get; set; }
        public List<CustomerStatus> CustomerStatusList { get; set; }
        public string SelectedCustomerStatus { get; set; }
        public List<AccountClassType> AccountClassTypes { get; set; }
        public List<AccountStatusType> AccountStatusTypes { get; set; }
        public void OnGet()
        {
            searchHeader = "SearchQ1";
        }

        public List<AccountClassData> getAccClassData()
        {
            List<AccountClassData> accountClassDataList = new List<AccountClassData> {
                new AccountClassData { Name = "All", Id = "0" },
                new AccountClassData { Name = "Acc1", Id = "1" },
                new AccountClassData { Name = "Acc2", Id = "2" }
            };
            return accountClassDataList;
        }

        public List<CreditClassification> getClassification()
        {


            List<CreditClassification> creditClassifications = new List<CreditClassification> {
            new CreditClassification { classificationId = "classf1", classificationName = "a1", classificationStyle = "font-weight: normal",displayColor="black",displayEmphasis=false },
            new CreditClassification { classificationId = "classf2", classificationName = "a2", classificationStyle = "font-weight: bold",displayColor="black",displayEmphasis=true }
            };

            return creditClassifications;          

        }


        public List<ClassificationData> getClassificationData()
        {
            List<ClassificationData> classificationDataList= new List<ClassificationData>();
            foreach (var clf in getClassification()) {
                classificationDataList.Add(new ClassificationData() { Name = clf.classificationName, Value = clf.classificationId, Style = clf.classificationStyle});
            }
           return classificationDataList;
        }

        public List<AccountClassType> getAccountClassTypes()
        {
            List<AccountClassType> accountClassTypes = new List<AccountClassType>
            {
                 new AccountClassType { AccountClassId = "", AccountClassName = "",LoanTypeId="",LoanTypeDescription="All" },
                new AccountClassType { AccountClassId = "", AccountClassName = "",LoanTypeId="",LoanTypeDescription="" },
                new AccountClassType { AccountClassId = "{62A68692-C594-4ECD-B957-78554DDA5ED0}", AccountClassName = "Loan" },
                new AccountClassType { AccountClassId = "{62A68692-C594-4ECD-B957-78554DDA5ED0}", AccountClassName = "Loan",LoanTypeId="{24B4A2F9-6FED-4B63-9AC3-1E24DE697C65}",LoanTypeDescription="AC Assignment" }
                //new AccountClassType { Name = "Savings", Value = "1" },
                //new AccountClassType { Name = "Checking", Value = "2" }
            };
            return accountClassTypes;
        }

        //accountList[0] = new Array('','All');
        //accountTypeList[0] = new Array('', '', '', 'All');
        //accountList[1] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan');
        //accountTypeList[1] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{24B4A2F9-6FED-4B63-9AC3-1E24DE697C65}','AC Assignment');
        //accountTypeList[2] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{787CFEA9-4A21-4B84-8C01-0817B21820C1}','AC Real Estate');
        //accountTypeList[3] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{4A88B542-BE2B-429A-B83A-0BAA0E68865F}','AC Titled Vehicle');
        //accountTypeList[4] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{94B0D737-5F71-4B44-AE6C-746E6B048E7F}','AC UCC');
        //accountTypeList[5] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{5E08184E-E91C-4442-B350-4086DFAB3501}','Commercial Non Real Estate');
        //accountTypeList[6] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{05FFC52E-C588-4D47-998D-9179BAE7ADCA}','Commercial Real Estate');
        //accountTypeList[7] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{44EA63DC-5755-4483-8DE8-6AE0ACE349AD}','Consumer Non Real Estate');
        //accountTypeList[8] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{29AD8714-9615-4402-B1A3-D4EAD014D706}','Consumer Real Estate');
        //accountList[2] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit');
        //accountTypeList[9] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit','{E8E126F0-F34D-4F6F-A650-78E4AD38DB20}','Business Certificate of Deposit');
        //accountTypeList[10] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit','{58E0ABD5-1505-47F3-BA8A-AAD0CEC00337}','Business Checking');
        //accountTypeList[11] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit','{93078A44-E9CA-4B51-A3EA-CB6ADF11C319}','Business Savings');
        //accountTypeList[12] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit','{AA120632-B784-4B90-9952-4E6B26A6DB3D}','Personal Checking');
        //accountList[3] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust');
        //accountTypeList[13] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{34DC5F00-1B9E-4EE9-8912-07F9780EC1CB}','Corporate Trusts and Agencies');
        //accountTypeList[14] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{F81CE5F3-383B-4A0E-A30A-6263202ACC90}','Emp Benefit Trusts and Agency Accts');
        //accountTypeList[15] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{122E25DC-F222-4F02-B745-6EC1764323A5}','Funeral and Cemetery Trusts');
        //accountTypeList[16] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{8CA2F207-4362-458D-B44B-551E2035D53B}','Personal Trusts and Personal Agencies');
        //accountStatusList[0] = new Array('', '', '', 'All');
        //accountStatusList[1] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{1711CC11-F441-4D52-9035-14B0745F3E22}','Active');
        //accountStatusList[2] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{50CE9657-34A9-45C2-A9B5-FAB063EFCABD}','Charged Off');
        //accountStatusList[3] = new Array('{62A68692-C594-4ECD-B957-78554DDA5ED0}','Loan','{7A8571A2-06E1-42D5-B55C-090E2FAF3DCA}','Paid Off');
        //accountStatusList[4] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit','{29287466-F524-4102-8621-32D350F6412B}','Closed');
        //accountStatusList[5] = new Array('{DA113DBE-F79B-408C-907C-6F7A81E4E5B0}','Deposit','{A1CEBDAF-30F7-4D0C-9388-22CA7AF1885D}','Open');
        //accountStatusList[6] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{25201932-3244-48CA-AF1C-2BC29C575FB6}','Closed');
        //accountStatusList[7] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{CA30F720-BBB9-4C24-9C24-B6522CD92FDF}','Open - Restricted');
        //accountStatusList[8] = new Array('{0D64E977-6865-471B-9E86-6FAE000AD1CC}','Trust','{FC725A88-11E6-47F1-8989-5B67903430E7}','Open - Unrestricted');



    }
}