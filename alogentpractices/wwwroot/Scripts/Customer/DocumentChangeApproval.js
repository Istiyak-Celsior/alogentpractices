var DocumentChangeApproval = kendo.data.ObservableObject.extend({
    date: undefined,
    approver: undefined,
    comment: undefined,
    quality: undefined,
    qualityName: function() {
        var quality = this.get("quality");

        switch (quality) {
        case 1:  return "Approved";
        case 2:  return "Rejected";
        default: return "Not Verified";
        }
    }
});