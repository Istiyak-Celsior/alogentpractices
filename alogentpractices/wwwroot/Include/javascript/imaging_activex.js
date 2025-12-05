function OpenImageCenter(guidType, guidValue) {
    /* guidType: D = Document, A = Account/Collateral, C = Customer, DD = DocumentDefinition */
    var activeX = new ActiveXObject("AccuAccount.ActiveX");
    if (guidType == 'C') {
        activeX.ScanCustomerDocument(guidValue);
    }
    if (guidType == 'A') {
        activeX.ScanAccountDocument(guidValue);
    }
    if (guidType == 'D') {
        activeX.ScanDocument(guidValue);
    }
}

function OpenImageCenterWithDocumentDef(guidDocumentDefinition, guidCustomer, guidLoanId) {
    var activeX = new ActiveXObject("AccuAccount.ActiveX");
    activeX.ScanDocumentDef(guidDocumentDefinition, guidCustomer, guidLoanId);
}
