var ReportViewModel = (function($, undefined) {
    return ViewModel.extend({
        init: function(service) {
            ViewModel.fn.init.call(this);
    
            this._service = service;
            this._canRead = true;
        },
        behaviors: new kendo.data.ObservableArray([]),
        columns: [],
        data: undefined,
        filters: [],
        isLicensed: true,
        name: undefined,
        owner: undefined,
        pageSize: 25,
        template: undefined,
        view: function(owner, name) {
            var that = this;
    
            that.set("owner", owner);
            that.set("name", name);

            return $.when(that._service.getReportTemplate(owner, name), that._service.getReportDefinition(owner, name))
                    .then(function(templateResponse, definitionResponse) {
                        return $.proxy(that._initialize, that, templateResponse[0], definitionResponse[0])();
                    });
        },
        _createColumn: function(template, templateField) {
            var that   = this;
            var column = new kendo.data.ObservableGridColumn(templateField.name);

            if (templateField.behaviors.linkBehavior.isSupported && templateField.behaviors.linkBehavior.isEnabled) {
                column.set("field", templateField.name + ".Value");
            }

            column.title     = that._getFieldLabel(template, templateField);
            column.hidden    = false;
            column.format    = that._getColumnFormat(templateField);
            column.template  = that._getColumnTemplate(templateField);

            return column;
        },
        _data: function(template, groupDescriptions, sortDescriptions, pageSize) {
            var that  = this;
            var model = {};
            
            $.each(template, function (i, group) {
                $.each(group.fields, function (j, field) {
                    model[field.name] = {
                         type: that._getFieldType(field)
                    };
                });
            });
    
            return new kendo.data.DataSource({
                transport: {
                    read: function(options) {
                        $.proxy(that._read, that)(options);
                    }
                },
                schema: {
                    data: "Data",
                    total: "Total",
                    model: { fields: model }
                },
                pageSize: pageSize,
                serverGrouping: false,
                serverPaging: true,
                serverFiltering: true,
                serverSorting: true,
                sort: sortDescriptions,
                group: groupDescriptions
            });
        },
        _getColumnName: function(column) {
            if (column.indexOf(".") > -1) {
                return column.substr(0, column.indexOf("."));
            } else {
                return column;
            }
        },
        _getColumn: function(fieldName) {
            var foundColumn;
            var that = this;

            $.each(this.columns, function(i, column) {
                if (that._getColumnName(column.field) === that._getColumnName(fieldName)) {
                    foundColumn = column;
                    return false;
                }
                return true;
            });

            return foundColumn;
        },
        _getColumnFormat: function(templateField) {
            switch (templateField.type) {
                case "DateTime": return "{0:MM/dd/yyyy hh:mm:ss tt}";
                case "Money": return "{0:c2}";
                default: return undefined;
            }
        },
        _getColumns: function(template, selectedFields) {
            var that    = this;
            var columns = [];
            var fields  = [];

            $.each(template, function (i, group) {
                $.each(group.fields, function(j, field) {
                    fields.push(field);
                });
            });

            $.each(selectedFields, function(i, selectedField) {
                $.each(fields, function(j, field) {
                    if (selectedField.name === field.name) {
                        var column = that._createColumn(template, field);

                        column.width = selectedField.width;

                        columns.splice(i, 0, column);

                        return false;
                    }
                });
            });

            return columns;
        },
        _getColumnTemplate: function (templateField) {
            if (templateField.behaviors.linkBehavior.isSupported) {
                if (templateField.behaviors.linkBehavior.isEnabled) {
                    return "<a href='#= " + templateField.name + ".Link #'><span data-bind='text: " + templateField.name + ".Value'></span></a>";
                } else {
                    return undefined;
                }
            } else {
                switch (templateField.type) {
                case "True/False":
                    return "#= " + templateField.name + ' == true ? "Y" : "N"#';
                default:
                    return undefined;
                }
            }
        },
        _getDateRangeFilters: function(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field  = that._getTemplateField(template, value.Field);
                var label  = that._getFieldLabel(template, field);
                var filter = new DateRangeFilterViewModel(label, value.Field);

                filter.set("fromDate", value.FromDate);
                filter.set("toDate", value.ToDate);
                filter.set("filterType", value.FilterType);
                filter.set("relativeType", value.RelativeType);
                filter.set("relativeValue", value.RelativeValue);

                filters.push(filter);
            });

            return filters;
        },
        _getFields: function(Fields) {
            var fields = [];
    
            $.each(Fields, function (key, value) {
                var field = new ReportField(value.Name, value.SortOrder, value.SortDirection, value.Width);

                field.behaviors.linkBehavior = value.Behaviors.LinkBehavior;

                fields.push(field);
            });
    
            return fields;
        },
        _getFieldType: function(field) {
            if (field.behaviors.linkBehavior.isSupported && field.behaviors.linkBehavior.isEnabled) {
                return "object";
            }

            switch (field.type) {
                case "True/False": return "boolean";
                case "DateTime":   return "date";
                case "Money":      return "number";
                case "Number":     return "number";
                default:           return "string";
            }
        },
        _getFilters: function(template, Filters) {
            var searchFilters = this._getSearchFilters(template, Filters.SearchFilters);
            var dateFilters   = this._getDateRangeFilters(template, Filters.DateRangeFilters);
            var multiFilters  = this._getMultiFilters(template, Filters.MultiFilters);

            return [].concat.apply([], [searchFilters, dateFilters, multiFilters]);
        },
        _getFieldLabel: function(template, field) {
            var label = field.label;

            $.each(template, function(i, currentGroup) {
                $.each(currentGroup.fields, function(j, currentField) {
                    if (field.group !== currentGroup.name && field.label === currentField.label) {
                        label = field.label + " (" + field.group + ")";
                    }
                });
            });

            return label;
        },
        _getGroups: function(Groups) {
            var groups = [];
    
            $.each(Groups, function (key, value) {
                groups.push({ field: value.Name, dir: value.SortDirection === 1 ? "desc" : "asc" });
            });
    
            return groups;
        },
        _getMultiFilterPromise: function (MultiFilters, multifilter) {
            $.each(MultiFilters, function (i, Filter) {
                if (Filter.Field === multifilter.field) {
                    $.each(Filter.Values, function (j, serverValue) {
                        multifilter.add(serverValue);
                    });
                }
            });

            return new $.Deferred().resolve();
        },
        _getMultiFilters: function loadMultiFilters(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field     = that._getTemplateField(template, value.Field);
                var label     = that._getFieldLabel(that.template, field);
                var viewModel = new MultiFilterViewModel(label, field.name);

                filters.push(viewModel);
            });

            return filters;
        },
        _getSearchFilters: function(template, Filters) {
            var that    = this;
            var filters = [];

            $.each(Filters, function (key, value) {
                var field  = that._getTemplateField(template, value.Field);
                var label  = that._getFieldLabel(template, field);
                var filter = new SearchFilterViewModel(label, value.Field, field.type);
    
                filter.set("operator", value.Operator);
                filter.set("value", value.Value);

                filters.push(filter);
            });

            return filters;
        },
        _getSortDescriptions: function(template, fields) {
            var descriptions = [];
            var that = this;

            var array = fields.sort(function(x, y) {
                return ((x.sortOrder < y.sortOrder) ? -1 : ((x.sortOrder > y.sortOrder) ? 1 : 0));
            });

            $.each(array, function(i, field) {
                if (field.sortOrder !== -1) {
                    var templateField = that._getTemplateField(template, field.name);
                    var columnName;

                    if (templateField.behaviors.linkBehavior.isSupported === true && templateField.behaviors.linkBehavior.isEnabled) {
                        columnName = kendo.format("{0}.Value", field.name);
                    } else {
                        columnName = field.name;
                    }

                    descriptions.push({ field: columnName, dir: field.sortDirection === 1 ? "desc" : "asc" });

                }
            });

            return descriptions;
        },
        _getSortDirection: function(direction) {
            switch (direction) {
                case 0:
                    return "asc";
                case 1:
                    return "desc";
                default:
                    return "asc";
            }
        },
        _getSortDirectionInt: function(direction) {
            switch (direction) {
                case "asc":
                    return 0;
                case "desc":
                    return 1;
                default:
                    return -1;
            }
        },
        _getTemplate: function (Template, selectedFields) {
            var template = [];

            $.each(Template, function (i, templateGroup) {
                var group = new ReportTemplateGroupViewModel(templateGroup.Name);

                $.each(templateGroup.Fields, function (j, field) {
                    var templateField = new ReportTemplateFieldViewModel(group.name, field.Name, field.Label, field.Type);

                    templateField.behaviors.linkBehavior.set("isSupported", field.Behaviors.LinkBehavior);

                    $.each(selectedFields, function (k, selectedField) {
                        if (selectedField.name === field.Name) {
                            templateField.set("checked", true);

                            if (templateField.behaviors.linkBehavior.isSupported === true && selectedField.behaviors.linkBehavior !== null) {
                                templateField.behaviors.linkBehavior.set("isEnabled", true);
                            } else {
                                templateField.behaviors.linkBehavior.set("isEnabled", false);
                            }
                        }
                    });

                    group.fields.push(templateField);
                });

                template.push(group);
            });

            return template;
        },
        _getTemplateField: function(template, name) {
            var value;

            $.each(template, function (i, group) {
                $.each(group.fields, function(j, field) {
                    if (field.name === name) {
                        value = field;
                        return false;
                    }
                });

                if (value) {
                    return false;
                }
            });

            return value;
        },
        _initialize: function(Template, Definition) {
            var that             = this;
            var groups           = that._getGroups(Definition.Groups);
            var fields           = that._getFields(Definition.Fields);
            var template         = that._getTemplate(Template.Groups, fields);
            var columns          = new kendo.data.ObservableArray(that._getColumns(template, fields));
            var sortDescriptions = that._getSortDescriptions(template, fields);

            that.set("template", template);
            that.set("data", this._data(template, groups, sortDescriptions, that.pageSize));
            that.set("columns", columns);
            that.set("filters", that._getFilters(that.template, Definition.Filters));
            that.set("isLicensed", Template.IsLicensed);

            var filterPromises = [];
    
            $.each(that.filters, function(i, filter) {
                if (filter.type === "Multi") {
                    filterPromises.push(that._getMultiFilterPromise(Definition.Filters.MultiFilters, filter));
                }
            });

            var deferred = new $.Deferred();

            $.when.apply($, filterPromises)
                  .then(function() {
                      deferred.resolve();
                  });

            return deferred;
        },
        _read: function(options) {
            if (this._canRead === false) {
                return options.success([]);
            }
            var that = this;

            var filterSerializer = new FilterSerializer();
            var filters          = filterSerializer.serialize(that.filters);
            var fields           = that._serializeColumns(that.columns, options.data.sort);

            var api = that._service.getData(that.owner, that.name, fields, filters, options.data);

            api.fail(function (result) {
                options.error(result);
            });

            api.done(function (result) {
                options.success(result);
            });
        },
        _serializeBehaviors: function (templateField) {
            var behaviors = {
                linkBehavior: null
            };

            if (templateField.behaviors.linkBehavior.isSupported === true && templateField.behaviors.linkBehavior.isEnabled === true) {
                behaviors.linkBehavior = {};
            }
        
            return behaviors;
        },
        _serializeColumns: function (columns, sorts) {
            var fields = [];
            var that   = this;

            $.each(columns, function(i, column) {
                var field = new ReportField(column.field, -1, -1, column.width);

                $.each(that.template, function(i, templateGroup) {
                    $.each(templateGroup.fields, function(j, templateField) {
                        var columnName = that._getColumnName(column.field);

                        if (templateField.name === columnName) {
                            if (templateField.behaviors.linkBehavior.isSupported === true && templateField.behaviors.linkBehavior.isEnabled === true) {
                                field.name      = columnName;
                                field.behaviors = that._serializeBehaviors(templateField);
                            }
                        }
                    });
                });

                fields.push(field);
            });

            var order  = 0;

            $.each(sorts, function(i, sort) {
                $.each(fields, function(j, field) {
                    var columnName = that._getColumnName(sort.field);

                    if (columnName === field.name) {
                        switch (sort.dir) {
                            case "asc":
                                field.sortDirection = 0;
                                break;
                            case "desc":
                                field.sortDirection = 1;
                                break;
                        }

                        field.sortOrder = ++order;

                        return false;
                    }

                    return true;
                });

                return true;
            });

            return fields;
        },
        _service: undefined
    });
})(window.kendo.jQuery);