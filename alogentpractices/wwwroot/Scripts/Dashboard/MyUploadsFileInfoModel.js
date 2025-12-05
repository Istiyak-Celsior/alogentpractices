var MyUploadsFileInfoModel = Model.extend({
    init: function (customerName, customerNumber, customerLink, account, accountType, accountLink, document, comment, expirationDate, uploadSource, uploadUser, fileClass, moveLink, documentGroup, documentTab, authorization) {
        Model.fn.init.call(this);

        this.customerName   = customerName;
        this.customerNumber = customerNumber;
        this.customerLink   = customerLink;
        this.account        = account;
        this.accountType    = accountType;
        this.accountLink    = accountLink;
        this.document       = document;
        this.comment        = comment;
        this.expirationDate = expirationDate;
        this.uploadSource   = uploadSource;
        this.uploadUser     = uploadUser;
        this.fileClass      = fileClass;
        this.moveLink       = moveLink;
        this.documentGroup  = documentGroup;
        this.documentTab    = documentTab;
        this.authorization  = authorization;
    },
    customerName: undefined,
    customerNumber: undefined,
    customerLink: undefined,
    account: undefined,
    accountType: undefined,
    accountLink: undefined,
    document: undefined,
    link: undefined,
    comment: undefined,
    expirationDate: undefined,
    uploadSource: undefined,
    uploadUser: undefined,
    fileClass: undefined,
    moveLink: undefined,
    documentGroup: undefined,
    documentTab: undefined,
    authorization: undefined
});