var ReportEditorViewModel = (function($, undefined) {
    var SAVE = "save";

    return ReportViewModel.extend({
        init: function(service, isOwner, description, canExport) {
            ReportViewModel.fn.init.call(this, service);

            this.set("description", description);
            this.set("isShared", !isOwner);
            this.set("pageSize", 100);

            this.canExport(canExport);
        },
        canExport: function(value) {
            if (value !== undefined) {
                this._canExport = value && this.get("isLicensed");
            }
            else {
                return this._canExport && this.get("isLicensed");
            }
        },
        currentName: undefined,
        description: undefined,
        editFilter: function(e) {
            var that = this;

            e.stopPropagation();

            if (that.isBusy) {
                return;
            }

            var field     = e.data;
            var result    = new $.Deferred();
            var viewModel = new FilterViewModel(that._service, field);
            var args      = { viewModel: viewModel, result: result, filter: undefined };

            that.trigger("filter", args);

            result.then(function() {
                var filter      = undefined;
                var filterLabel = that._getFieldLabel(that.template, field);

                switch (viewModel.selectedOption.value) {
                    case "DateRange":
                        filter = new DateRangeFilterViewModel(filterLabel, field.name);
                        break;
                    case "Search":
                        filter = new SearchFilterViewModel(filterLabel, field.name, field.type);
                        filter.set("value", "");
                        break;
                    case "Multi":
                        filter = new MultiFilterEditViewModel(filterLabel, field.name);
                        that._getMultiFilterItems(that._service, that.owner, that.name, filter);
                        break;
                }

                that.filters.push(filter);
            });
        },
        error: undefined,
        exportData: function(e) {
            var that = this;

            e.stopPropagation();

            that.save()
                .done(function() {
                    that.trigger("export", { report: that });
                });
        },
        _getMultiFilterItems: function (service, user, reportName, filter) {
            var that = this;

            that.set("isBusy", true);
            that.set("items", []);

            var request = service.getReportFilterData(user, reportName, filter.field);

            request.done(function (e) {
                var items = [];
                var set = {};

                $.each(e.Data, function (i, dataItem) {
                    if (!dataItem.Value) {
                        dataItem.Value = "";
                    }

                    set[dataItem.Value] = dataItem;
                });

                $.each(set, function (i, member) {
                    items.push(member);
                });

                items.sort(function (x, y) {
                    return x.Value.localeCompare(y.Value);
                });

                $.each(items, function (j, item) {
                    filter.add(item.Value);
                });
            });

            request.always(function () {
                that.set("isBusy", false);
            });

            return request;
        },
        _getMultiFilters: function loadMultiFilters(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field     = that._getTemplateField(template, value.Field);
                var label     = that._getFieldLabel(that.template, field);
                var viewModel = new MultiFilterEditViewModel(label, field.name);

                filters.push(viewModel);
            });

            return filters;
        },
        _getMultiFilterPromise: function (MultiFilters, multifilter) {
            var that = this;

            return that._getMultiFilterItems(that._service, that.owner, that.name, multifilter)
                .then(function () {
                    $.each(MultiFilters, function (i, Filter) {
                        if (Filter.Field === multifilter.field) {
                            $.each(Filter.Values, function (j, serverValue) {
                                multifilter.selectValue(serverValue);
                            });
                        }
                    });
                });
        },
        hasError: false,
        hasColumns: function() {
            var columns = this.get("columns");

            var visibleColumns = $.grep(columns, function(column) {
                return column.hidden === false && column.field !== "";
            });

            return visibleColumns.length > 0;
        },
        hasFilters: function() {
            return this.get("filters").length > 0;
        },
        isBusy: false,
        isShared: undefined,
        view: function(owner, name) {
            var that = this;

            that.set("currentName", name);

            return ReportViewModel.fn
                                  .view
                                  .call(that, owner, name)
                                  .done(function() {
                                      that.refresh();
                                  });
        },
        refresh: function() {
            var that = this;

            that._toggleIsBusy(true);

            if (!that.hasColumns()) {
                that._toggleIsBusy(false);
                return null;
            }

            var request = that.data.fetch();

            request.done(function(e) {
                that._hideError();
            });

            request.fail(function(e) {
                that._showError(e.responseJSON.ErrorMessage);
            });

            request.always(function() {
                setTimeout(function() {
                    that._toggleIsBusy(false);
                });
            });

            return request;
        },
        removeFilter: function(e) {
            var that = this;

            var index = that.filters.indexOf(e.data);

            that.filters.splice(index, 1);
        },
        save: function() {
            var that = this;

            that._toggleIsBusy(true);

            var groups                = that._serializeGroups(that.data.group());
            var fieldSortDescriptions = that.data.sort();
            var fields                = that._serializeColumns(that.columns, fieldSortDescriptions);
            var filterSerializer      = new FilterSerializer();
            var filters               = filterSerializer.serialize(that.filters);

            var request = that._service
                              .updateReport(that.owner,
                                            that.name,
                                            that.currentName,
                                            that.description,
                                            fields,
                                            groups,
                                            filters);

            request.fail(function(e) {
                that._showError(e.responseJSON.ErrorMessage);
            });

            request.done(function(e) {
                that._hideError();

                that.trigger(SAVE, that);

                that.set("name", that.currentName);
            });

            request.always(function() {
                setTimeout(function() {
                    that._toggleIsBusy(false);
                },
                25);
            });

            return request;
        },
        toggleColumn: function(e) {
            var that = this;

            that._toggleIsBusy(true);

            if (e.data.checked) {
                that._showColumn(e.data.name);
            } else {
                that._hideColumn(e.data.name);
            }

            if (!that.hasColumns()) {
                that.data.data([]);
                that._toggleIsBusy(false);
                return;
            }

            var isSorted = that._isColumnSorted(e.data.name);

            if (e.data.checked || !isSorted) {
                that.refresh();
            }
            else {
                that.data.sort(that._removeColumnSortConfiguration(e.data.name));
            }

            that._toggleIsBusy(false);
        },
        toggleBehavior: function (e) {
            var that = this;

            that._toggleIsBusy(true);

            var behaviorType = e.target.dataset.behaviortype;

            switch (behaviorType) {
                case "link":
                    that._toggleLinkBehavior(e.data, e.data.behaviors.linkBehavior, that.data);
                    break;
            }

            that.refresh()
                .done(function () {
                    that._toggleIsBusy(false);
                });
        },
        _getDataSourceGroup: function(groups, columnName) {
            var group;

            $.each(groups, function(i, datasourceGroup) {
                if (datasourceGroup.field === columnName) {
                    group = datasourceGroup;
                    return false;
                }
                return true;
            });

            return group;
        },
        _hideColumn: function(name) {
            var that   = this;
            var column = that._getColumn(name);

            if (column) {
                that._canRead = false;

                that._ungroupColumn(column.field);

                that._canRead = true;

                var index = that.columns.indexOf(column);

                that.columns.splice(index, 1);
            }
        },
        _hideError: function() {
            var that = this;

            that.set("hasError", false);
            that.set("error", "");
        },
        _isColumnSorted: function(column) {
            var that = this;

            var sortConfiguration = that.data.sort();

            if (sortConfiguration == null || sortConfiguration.length === 0) {
                return false;
            }

            var isColumnSorted = false;

            for (var i = 0; i < sortConfiguration.length; i++) {
                if (sortConfiguration[i].field.toLowerCase() === column.toLowerCase()) {
                    isColumnSorted = true;
                    break;
                }
            }

            return isColumnSorted;
        },
        _removeColumnSortConfiguration: function(column) {
            var sort  = this.data.sort();
            var index = -1;

            for (var i = 0; i < sort.length; i++) {
                if (sort[i].field.toLowerCase() === column.toLowerCase()) {
                    index = i;
                    break;
                }
            }

            if (index !== -1) {
                sort.splice(index, 1);
            }

            return sort;
        },
        _serializeGroups: function(groupDescriptors) {
            var groups = [];

            $.each(groupDescriptors, function(i, gridGroup) {
                var dir;

                switch (gridGroup.dir) {
                    case "asc":
                        dir = 0;
                        break;
                    case "desc":
                        dir = 1;
                        break;
                    default:
                        dir = -1;
                        break;
                }

                groups.push(new ReportGroup(gridGroup.field, dir));
            });

            return groups;
        },
        _showColumn: function(name) {
            var that = this;

            var templateField = that._getTemplateField(that.template, name);
            var column        = that._createColumn(that.template, templateField);

            that.columns.push(column);
        },
        _showError: function(error) {
            var that = this;

            that.set("hasError", true);
            that.set("error", error);
        },
        _toggleIsBusy: function(isBusy) {
            this.set("isBusy", isBusy);
            this.trigger("busy", { isBusy: this.get("isBusy") });
        },
        _disableLinkBehavior: function(templateField, column, datasource) {
            var that    = this;
            var options = datasource.options;

            options.group = datasource.group();

            var group = that._getDataSourceGroup(options.group, kendo.format("{0}.Value", templateField.name));

            if (group) {
                group.field = templateField.name;
            }

            options.schema.model.fields[templateField.name] = {
                type: "string"
            };

            that.set("data", new kendo.data.DataSource(options));

            column.set("field", templateField.name);
        },
        _enableLinkBehavior: function(templateField, column, datasource) {
            var that    = this;
            var options = datasource.options;

            options.group = datasource.group();

            var group = that._getDataSourceGroup(options.group, templateField.name);

            if (group) {
                group.field = kendo.format("{0}.Value", templateField.name);
            }

            options.schema.model.fields[templateField.name] = {
                type: "object"
            };

            that.set("data", new kendo.data.DataSource(options));

            column.set("field", kendo.format("{0}.Value", templateField.name));
        },
        _toggleLinkBehavior: function(templateField, behavior, datasource) {
            var that = this;
            var column;

            if (behavior.isEnabled === true) {
                column = that._getColumn(kendo.format("{0}.Value", templateField.name));

                that._disableLinkBehavior(templateField, column, datasource);
            }
            else {
                column = that._getColumn(templateField.name);

                that._enableLinkBehavior(templateField, column, datasource);
            }

            behavior.set("isEnabled", !behavior.isEnabled);

            var columnTemplate = that._getColumnTemplate(templateField);

            column.set("template", columnTemplate);
        },
        _ungroupColumn: function(columnName) {
            var that       = this;
            var datasource = this.data;
            var groups     = datasource.group();
            var group      = that._getDataSourceGroup(datasource.group(), columnName);

            if (group) {
                var index = groups.indexOf(group);

                groups.splice(index, 1);

                datasource.group(groups);
            }
        }
    });
})(window.kendo.jQuery);