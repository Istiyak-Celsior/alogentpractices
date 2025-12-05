var EmailReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service, user, report) {
            ViewModel.fn.init.call(this);

            this.service = service;
            this.user    = user;
            this.report  = report;

            this.set("users", this._dataSource());
        },
        message: undefined,
        user: undefined,
        users: undefined,
        selectedUsers: [],
        showDialog: undefined,
        _dataSource: function() {
            var that = this;

            return new kendo.data.DataSource({
                transport: {
                    read: {
                        url: that.report.isSharedBankwide ? "api/DynamicReporting/GetUsers" : "api/DynamicReporting/GetSharedUsers",
                        type: "POST"
                    },
                    parameterMap: function(data, type) {
                        if (that.report.isSharedBankwide) {
                            return {
                                UserName: that.user
                            }
                        } else {
                            return {
                                UserName: that.user,
                                ReportName: that.report.name
                            }
                        }
                    }
                },
                schema: {
                    data: function(response) {
                        return that._users(response.Users);
                    }
                },
                group: {
                    field: "group"
                }
            });
        },
        _getFullName: function(user) {
            if ((user.FirstName == null || user.FirstName.length === 0) && (user.LastName == null || user.LastName.length === 0)) {
                return null;
            }

            if (user.LastName == null || user.LastName.length < 1) {
                return user.FirstName;
            }
            else if (user.FirstName == null || user.FirstName.length < 1) {
                return user.LastName;
            } 
            else {
                return user.FirstName + " " + user.LastName;
            }
        },
        _getGroup: function(user) {
            return user.LastName === undefined || user.LastName.length === 0 ? "" : user.LastName[0].toLowerCase();
        },
        _getLabel: function(user) {
            var label = this._getFullName(user);

            // No first or last name
            if (label === null) {
                if (user.Email == null) {
                    return user.UserName;
                } else {
                    return user.Email + " (" + user.UserName + ")";
                }
            }
        
            // Has a name part
            if (user.Email === undefined || user.Email.length === 0) {
                return label + " (" + user.UserName + ")";
            }

            return label + " (" + user.Email + ")";
        },
        _users: function(users) {
            var that  = this;
            var array = new kendo.data.ObservableArray([]);

            $.each(users, function(i, dataItem) {
                array.push({
                    userName: dataItem.UserName,
                    fullName: that._getFullName(dataItem),
                    email: dataItem.Email,
                    label: that._getLabel(dataItem),
                    group: that._getGroup(dataItem)
                });
            });

            return array;
        }
    });
})(window.kendo.jQuery);