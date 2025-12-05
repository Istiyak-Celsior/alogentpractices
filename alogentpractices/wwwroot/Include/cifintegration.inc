<%
SUB SaveCifInquiryResult()
    Session("cifInquiryResult.CustomerName") = Request("CustomerName")
    Session("cifInquiryResult.CustomerNumber") = Request("CustomerNumber")
    Session("cifInquiryResult.TaxId") = Request("TaxId")
    Session("cifInquiryResult.Employee") = Request("Employee")
    Session("cifInquiryResult.Branch") = Request("BranchName")
    Session("cifInquiryResult.OfficerName") = Request("OfficerName")
    Session("cifInquiryResult.Address1") = Request("Address1")
    Session("cifInquiryResult.Address2") = Request("Address2")
    Session("cifInquiryResult.City") = Request("City")
    Session("cifInquiryResult.State") = Request("State")
    Session("cifInquiryResult.Zip") = Request("Zipcode")
    Session("cifInquiryResult.PhoneHome") = Request("PhoneHome")
    Session("cifInquiryResult.PhoneWork") = Request("PhoneWork")
    Session("cifInquiryResult.PhoneMobile") = Request("PhoneMobile")
    Session("cifInquiryResult.Email") = Request("Email")
    Session("cifInquiryResult.ResponseCode") = Request("ResponseCode")
    Session("cifInquiryResult.ResponseMessage") = Request("ResponseMessage")
    Session("cifInquiryResult.CifNumber") = Request("CifNo")
END SUB

SUB ClearCifInquiryResult()
    Session("cifInquiryResult.CustomerName") = ""
    Session("cifInquiryResult.CustomerNumber") = ""
    Session("cifInquiryResult.TaxId") = ""
    Session("cifInquiryResult.Employee") = ""
    Session("cifInquiryResult.Branch") = ""
    Session("cifInquiryResult.OfficerName") = ""
    Session("cifInquiryResult.Address1") = ""
    Session("cifInquiryResult.Address2") = ""
    Session("cifInquiryResult.City") = ""
    Session("cifInquiryResult.State") = ""
    Session("cifInquiryResult.Zip") = ""
    Session("cifInquiryResult.PhoneHome") = ""
    Session("cifInquiryResult.PhoneWork") = ""
    Session("cifInquiryResult.PhoneMobile") = ""
    Session("cifInquiryResult.Email") = ""
    Session("cifInquiryResult.ResponseCode") = ""
    Session("cifInquiryResult.ResponseMessage") = ""
    Session("cifInquiryResult.CifNumber") = ""
END SUB

SUB SaveCifSearchParams()
    Session("cifSearchParams.BankId") = Request("bankId")
    Session("cifSearchParams.CustomerTypeId") = Request("customerTypeId")
    Session("cifSearchParams.UserLogin") = Request("userLogin")
    Session("cifSearchParams.BankCode") = Request("cifBank")
    Session("cifSearchParams.CustomerTypeCode") = Request("cifCustomerType")
    Session("cifSearchParams.SsnTin") = Request("cifSsnTin")
    Session("cifSearchParams.CustomerName") = Request("cifCustomerName")
END SUB

SUB ClearCifSearchParams()
    Session("cifSearchParams.BankId") = ""
    Session("cifSearchParams.CustomerTypeId") = ""
    Session("cifSearchParams.UserLogin") = ""
    Session("cifSearchParams.BankCode") = ""
    Session("cifSearchParams.CustomerTypeCode") = ""
    Session("cifSearchParams.SsnTin") = ""
    Session("cifSearchParams.CustomerName") = ""
END SUB
%>