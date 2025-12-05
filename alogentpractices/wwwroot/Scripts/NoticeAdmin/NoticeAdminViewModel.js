var NoticeAdminViewModel = (function ($, kendo, undefined) {

    return ViewModel.extend({
        init: function (webapi, dialogService) {
            ViewModel.fn.init.call(this);

            this._webapi        = webapi;
            this._noticeClient  = new NoticeClient(webapi);
            this._dialogService = dialogService;

            let that = this;

            this.bind("change", (e) =>{
                if (e.field == "selectedSet.stageMode") {
                    if (this.get("selectedSet.stageMode") == true) {
                        this.trigger("ui.stage", { data: this.selectedSet })
                    }
                }
            });
            
            this.set("exceptionPolicies", new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        let response = that._noticeClient.getExceptionPolicies("standard");

                        response.done(data => {
                            let policies = data.map(p => that._noticeClient.maps.mapExceptionPolicy(p));
                            let models   = policies.map(p => new NoticeLetterSetExceptionPolicyModel(p));

                            options.success(models);
                        });
                        
                        response.fail(function (result) {
                            options.error(result);
                        });
                    }
                }
            }));

            this.set("sets", new kendo.data.DataSource({
                transport: {
                    read: function (options) {
                        let response = that._noticeClient.getNoticeLetterSet();

                        response.done(function (data) {
                            let sets   = data.map(p => that._noticeClient.maps.mapNoticeLetterSet(p));
                            let models = sets.map(n => new NoticeLetterSetModel(n, that._noticeClient, that.exceptionPolicies.view(), that._dialogService, that));
                            
                            options.success(models);

                            that.updateExceptionPoliciesFilter(models);

                            models.forEach(p => {
                                p.bind("change", that.onSelectedSetChange.bind(that));
                            });
                        });

                        response.fail(function (result) {
                            options.error(result);
                        });
                    }
                },
                sort: [
                    { field: "name", dir: "asc" }
                ]
            }));
        },
        addSet: function (e) {
            let set = new NoticeLetterSetModel({
                name: "New Notice Letter Set",
                isEnabled: true,
                isMailMergeEnabled: false,
                exceptionPolicies: [],
                templates: []
            }, this._noticeClient, this.exceptionPolicies.view(), this._dialogService, this);

            this.sets.add(set);

            this.trigger("selectset", { item: set });

            this.editSet();

            this.trigger("focus", { target: "setname" });
        },
        cancelSetEdit: function (e) {
            let item = this.selectedSet;

            item.reset();

            if (item.isNew()) {
                this.sets.remove(item);
                this.set("selectedSet", null);
                return;
            }

            this.selectedSet.cancelEdit();
        },
        createSet: function (e) {
            let model = {
                name: this.selectedSet.editName,
                isEnabled: this.selectedSet.editIsEnabled,
                isMailMergeEnabled: this.selectedSet.editIsMailMergeEnabled,
                exceptionPolicies: [],
                templates: []
            };

            let promise = this._noticeClient.postNoticeLetterSet(model);
            let that    = this;

            promise.done(function (response) {
                that.selectedSet.applyChanges();

                if (that.selectedSet.isNew()) {
                    that.selectedSet.set("id", response.Id);
                    that.updateExceptionPoliciesFilter(that.sets.data());
                }
            });
        },
        deleteSet: function (e) {
            let deletedSet = this.selectedSet;

            if (this.selectedSet.isNew()) {
                this.sets.remove(deletedSet);
                this.set("selectedSet", null);
                return;
            }

            let that = this;

            kendo.confirm("Are you sure you want to delete this set? It will delete all of its templates and configuration.")
                 .done(function () {                 
                     let promise = that._noticeClient.deleteNoticeLetterSet(deletedSet);
                 
                     promise.done(function (response) {
                         that.sets.remove(deletedSet);
                         that.set("selectedSet", null);
                     });
                 });
        },
        editSet: function (e) {
            if (this.selectedSet == null) {
                return;
            }

            this.selectedSet.edit();

            this.trigger("focus", { target: "setname" });
        },
        isSetVisible: function(e) {
            if (this.get("selectedSet") == null) {
                return false;
            }
            
            if (this.get("selectedSet.selectedTemplate.editMode")) {
                return false;
            }

            return true;
        },
        isLettersVisible: function(e) {
            let selectedSet = this.get("selectedSet");

            if (selectedSet == null) {
                return false;
            }

            let selectedTemplate = this.get("selectedSet.selectedTemplate");

            if (selectedTemplate != null) {
                return false;
            }

            return !selectedSet.isNew();
        },
        sets: null,
        selectedSet: null,
        onSelectedSet: function (e) {
            let selectedItem = e.sender.dataItem(e.sender.select());

            e.data.set("selectedSet", selectedItem);
        },
        onSelectedSetChange: function(e) {
            if (e.field == "exceptionPolicies") {
                this.updateExceptionPoliciesFilter(this.sets.data());
            }
        },
        previewTemplate: function(e) {
            let template = e.data;

            let placeholdersRequest = template.placeholders.fetch();

            placeholdersRequest.done(() => {
                let placeholders = template.placeholders.data();
                let templateText = template.getPreviewText();
                let templateBody = template.placeholderVisualizer.visualizeText(templateText, placeholders);
    
                this._dialogService.open("previewTemplate", {
                    title: "Preview",
                    viewModel: {
                        letter: templateBody
                    },
                    actions: [
                        { 
                            text: "OK",
                            primary: true,
                            action: () =>  true
                        }
                    ]
                });
            });
        },
        updateExceptionPoliciesFilter: function(sets) {
            let exceptionPolicyIds = [];

            sets.forEach(s => {
                s.exceptionPolicies.data().forEach(p => {
                    exceptionPolicyIds.push(p.id);
                }); 
            });
            
            sets.forEach(s => {
                s.updateUnassignedExceptionPoliciesFilter(exceptionPolicyIds);
            });
        },
        updateSet: function (e) {
            let model = {
                id: this.selectedSet.id,
                name: this.selectedSet.editName,
                isEnabled: this.selectedSet.editIsEnabled,
                isMailMergeEnabled: this.selectedSet.editIsMailMergeEnabled
            };

            let promise = this._noticeClient.patchNoticeLetterSet(model);
            let that    = this;

            promise.done(function () {
                that.selectedSet.applyChanges();
            });
        }
    });

})(window.kendo.jQuery, window.kendo);