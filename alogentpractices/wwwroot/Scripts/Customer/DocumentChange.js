var DocumentEvent = kendo.data.ObservableObject.extend({
    id: undefined,
    author: undefined,
    authorEmail: undefined,
    date: undefined,
    eventSource: undefined,
    information: undefined,
    quality: undefined,
    pagesAdded: undefined,
    pagesDeleted: undefined,
    approvals: [],
    approvalCount: function() {
        return this.get("approvals").length;
    },
    approvalStatus: function() {
        var quality = this.get("quality");

        switch (quality) {
            case 1:
                return "Approved";
            case 2:
                return "Rejected";
            default:
                return "Not Verified";
        }
    },
    hasApprovals: function() {
        return this.get("approvals").length > 0;
    }
});

var DocumentChange = DocumentEvent.extend({
    /*
     * TODO: separate changes from events
     */
});