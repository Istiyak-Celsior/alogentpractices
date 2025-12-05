var NoticeEnvelope = (function ($, kendo, undefined) {

    return kendo.data.ObservableObject.extend({
        init: function (model) {
            kendo.data.ObservableObject.fn.init.call(this, model);

            this.set("contactByMailYN", model.contactByMail == true ? "Y" : "N");
            this.set("lastEmailAlert", this._getLastEmailAlert());
            this.set("lastEmailAlertDeliveryState", this._getLastEmailAlertDeliveryState());

            if (model.deliveryDate) {
                this.set("deliveryDate", new Date(model.deliveryDate));
            }
        },
        _getLastEmailAlert: function(e) {
            let alerts = this.get("alerts");

            if (alerts.length == 0) {
                return {
                    deliveryState: "",
                    deliveryStatus: ""
                }
            }
            
            // Future: design supports more than one alert, but only one alert
            //         ever created in the current design.
            let alert = alerts[0];
            
            return alert;
        },
        _getLastEmailAlertDeliveryState: function() {
            let alert = this._getLastEmailAlert();

            if (alert == null) {
                return "";
            }

            return alert.deliveryState;
        }
    });

})(window.kendo.jQuery, window.kendo);