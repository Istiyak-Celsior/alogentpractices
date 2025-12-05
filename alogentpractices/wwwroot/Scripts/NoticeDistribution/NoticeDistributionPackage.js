var NoticeDistributionPackage = (function($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function() {
            kendo.data.ObservableObject.fn.init.call(this, this);
        },
        deliverable: [],
        undeliverable: [],
        inProcess: [],
        addDeliverable: function(notices) {
            this.deliverable.empty();
            
            this.deliverable.push.apply(this.deliverable, notices);
        },
        addInProcess: function(notices) {
            this.inProcess.empty();

            this.inProcess.push.apply(this.inProcess, notices);
        },
        addUndeliverable: function(notices) {
            this.undeliverable.empty();

            let groupedNotices = this.groupUndeliverableNotices(notices);

            this.undeliverable.push.apply(this.undeliverable, groupedNotices);
        },
        _getDeliverByValue: function(envelope) {
            let deliverBy;

            if (envelope.holdLetter) {
                deliverBy = "Do Not Contact";
            }
            else if (envelope.usePaper && !envelope.useEmail) {
                deliverBy = "Paper";
            }
            else if (envelope.useEmail && !envelope.usePaper) {
                deliverBy = "Email";
            }
            else if (!envelope.holdLetter && !envelope.useEmail && !envelope.usePaper) {
                deliverBy = "Unspecified";
            }
            else {
                deliverBy = "Any";
            }

            return deliverBy;
        },
        groupUndeliverableNotices: function(notices) {
            let groups = notices.reduce((result, envelope) => {
                const group = result.find(g => g.recordNumber == envelope.recordNumber)

                if (group) {
                    group.items.push(envelope);
                }
                else {
                    result.push({
                        recordLink: envelope.recordLink,
                        recordName: envelope.recordName,
                        recordNumber: envelope.recordNumber,
                        usePaper: envelope.usePaper,
                        useEmail: envelope.useEmail,
                        hasValidAddress: envelope.hasValidAddress,
                        hasValidEmail: envelope.hasValidEmail,
                        contactName: envelope.contactName,
                        contactAddress: envelope.contactAddress == null ? "" : envelope.contactAddress,
                        contactEmail: envelope.contactEmail == null ? "" : envelope.contactEmail,
                        contactMethod: envelope.contactMethod,
                        holdLetter: envelope.holdLetter,
                        deliverBy: this._getDeliverByValue(envelope),
                        items: [envelope]
                    });
                }

                return result;
            }, []);

            return groups;
        }
    });

})(window.kendo.jQuery, window.kendo);