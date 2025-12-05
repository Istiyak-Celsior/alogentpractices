var CustomerBuilder = kendo.Class.extend({
    init: function (customerService, documentService) {
        this._customerService = customerService;
        this._documentService = documentService;
    },
    build: function (customer) {
        var customerModel = new Customer(this._customerService, this._documentService);

        customerModel.set("id", customer.Id);
        customerModel.set("name", customer.FullName);
        customerModel.set("number", customer.CustomerNumber);
        customerModel.set("taxId", customer.TaxId);
        customerModel.set("status", customer.Status);
        customerModel.set("type", customer.Type);
        customerModel.set("officer", customer.OfficerName);
        customerModel.set("branch", customer.BranchName);
        customerModel.set("email", customer.Email);
        customerModel.set("isEmployee", customer.IsEmployee);

        customerModel.set("address", {
            address1: customer.Address1,
            address2: customer.Address2,
            city: customer.City,
            state: customer.State,
            zip: customer.Zip
        });

        customerModel.set("phoneNumbers", {
            home: customer.HomePhoneNumber,
            work: customer.WorkPhoneNumber,
            mobile: customer.MobilePhoneNumber
        });

        customerModel.set("totalLoanBalance", customer.TotalLoanBalance);
        customerModel.set("totalLoanCommitment", customer.TotalLoanCommitment);

        return customerModel;
    }
});

