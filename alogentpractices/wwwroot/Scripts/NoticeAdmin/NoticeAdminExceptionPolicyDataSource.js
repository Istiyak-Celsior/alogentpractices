var NoticeAdminExceptionPolicyDataSource = (function ($, kendo, undefined) {

    return function(data) {
        return new kendo.data.DataSource({
            data: data,
            pageSize: 10,
            group: [
                { field: "type" }
            ],
            sort: [
                { field: "accountClass", dir: "asc" },
                { field: "accountType", dir: "asc" },
                { field: "type", dir: "desc" },
                { field: "name", dir: "asc" }
            ]
        })
    };

})(window.kendo.jQuery, window.kendo, undefined);