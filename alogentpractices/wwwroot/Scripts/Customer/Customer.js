var Customer = kendo.data.Model.extend({
    init: function (customerService, documentService) {
        kendo.data.Model.fn.init.call(this);

        this._customerService = customerService;
        this._documentService = documentService;
    },
    id: undefined,
    name: undefined,
    number: undefined,
    taxId: undefined,
    status: undefined,
    type: undefined,
    officer: undefined,
    branch: undefined,
    email: undefined,
    isEmployee: undefined,
    address: {
        address1: undefined,
        address2: undefined,
        city: undefined,
        state: undefined,
        zip: undefined
    },
    phoneNumbers: {
        home: undefined,
        work: undefined,
        mobile: undefined
    },
    getLoanApplications: function(customerId, user) {
        return this._customerService.getLoanApplications(customerId, user);
    },
    getLoans: function (customerId, user) {
        return this._customerService.getLoans(customerId, user);
    },
    getDeposits: function (customerId, user) {
        return this._customerService.getDeposits(customerId, user);
    },
    getTrusts: function (customerId, user) {
        return this._customerService.getTrusts(customerId, user);
    },
    getDocuments: function (customerId, user, take, skip, search) {
        return this._documentService.getCustomerDocuments(customerId, user, take, skip, search);
    },
    totalLoanBalance: undefined,
    totalLoanCommitment: undefined,
    _customerService: undefined
});
