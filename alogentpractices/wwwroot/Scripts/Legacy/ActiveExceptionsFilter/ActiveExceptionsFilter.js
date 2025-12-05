var ActiveExceptionsFilter = (function (document) {
    var that = {
        validateCheckboxes: undefined,
        enableDropdowns: undefined,
        disableSection: undefined,
        clearAll: undefined,
        checkAll: undefined,
        checkBank: undefined,
        checkItem: undefined,
        updateCheckList: undefined
    };

    that.validateCheckboxes = function () {
        var alertMessage = '';
        var currentFilter = document.frmDisplayPrefs.hidFilterBy.value;
        var f = document.frmDisplayPrefs;
        var somethingChecked = false;
        if (currentFilter == 0) {
            somethingChecked = true;
        }
        else if (currentFilter == 1) // Filter - Loan Officer
        {
            for (i = 0; i < f.chkOfficerId.length; i++) {
                if (f.chkOfficerId[i].checked) {
                    somethingChecked = true;
                }
            }
            if (f.chkOfficerAll.checked) { somethingChecked = true; }
            if (f.chkOfficerBankId.checked) { somethingChecked = true; }
            alertMessage = 'Please select at least one officer.'
        }
        else if (currentFilter == 2) // Filter - Assigned User
        {
            for (i = 0; i < f.chkUserId.length; i++) {
                if (f.chkUserId[i].checked) {
                    somethingChecked = true;
                }
            }
            if (f.chkUserAll.checked) { somethingChecked = true; }
            if (f.chkUserBankId.checked) { somethingChecked = true; }
            alertMessage = 'Please select at least one user.'
        }

        if (somethingChecked == true) {
            document.frmDisplayPrefs.submit();
        }
        else {
            alert(alertMessage);
        }
    };

    that.enableDropdowns = function (filterBy) {
        var obj;
        var bankIdx, bankObj, bankDone;
        var itemIdx, itemObj, itemDone;

        document.frmDisplayPrefs.hidFilterBy.value = filterBy;

        if (filterBy == 1) {
            that.disableSection("chkOfficerAll", "chkOfficerBank", "chkOfficerItem", false);
            that.disableSection("chkUserAll", "chkUserBank", "chkUserItem", true);
            that.clearAll("chkUserAll", "chkUserBank", "chkUserItem");
        }
        else if (filterBy == 2) {
            that.disableSection("chkOfficerAll", "chkOfficerBank", "chkOfficerItem", true);
            that.clearAll("chkOfficerAll", "chkOfficerBank", "chkOfficerItem");
            that.disableSection("chkUserAll", "chkUserBank", "chkUserItem", false);
        }
        else {
            that.disableSection("chkOfficerAll", "chkOfficerBank", "chkOfficerItem", true);
            that.clearAll("chkOfficerAll", "chkOfficerBank", "chkOfficerItem");
            that.disableSection("chkUserAll", "chkUserBank", "chkUserItem", true);
            that.clearAll("chkUserAll", "chkUserBank", "chkUserItem");
        }
    };

    that.disableSection = function (chkAllName, chkBankName, chkItemName, newState) {
        obj = document.getElementById(chkAllName);
        obj.disabled = newState;

        bankIdx = 0;
        bankDone = false;
        while (!bankDone) {
            bankObj = document.getElementById(chkBankName + "_" + bankIdx);

            if (bankObj == null) {
                bankDone = true;
            }
            else {
                bankObj.disabled = newState;

                itemIdx = 0;
                itemDone = false;
                while (!itemDone) {
                    itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        itemObj.disabled = newState;
                    }

                    itemIdx++;
                }
            }

            bankIdx++;
        }

        return true;
    };

    that.clearAll = function (chkAllName, chkBankName, chkItemName) {
        var chkAllObj;
        var bankObj, bankIdx, bankDone;
        var itemObj, itemIdx, itemDone;

        chkAllObj = document.getElementById(chkAllName);
        chkAllObj.checked = false;

        bankDone = false;
        bankIdx = 0;
        while (!bankDone) {
            bankObj = document.getElementById(chkBankName + "_" + bankIdx);
            if (bankObj == null) {
                bankDone = true;
            }
            else {
                bankObj.checked = false;

                itemDone = false;
                itemIdx = 0;
                while (!itemDone) {
                    itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        itemObj.checked = false;
                    }

                    itemIdx++;
                }
            }
            bankIdx++;
        }
    };

    that.checkAll = function (chkAllName, chkBankName, chkItemName) {
        var elementId;
        var bankIdx, itemIdx;
        var bankObj, itemObj;
        var bankDone, itemDone;

        var chkAllObj = document.getElementById(chkAllName);

        bankIdx = 0;
        bankDone = false;
        itemDone = false;
        while (!bankDone) {
            elementId = chkBankName + "_" + bankIdx;
            bankObj = document.getElementById(elementId);
            if (bankObj == null) {
                bankDone = true;
            }
            else {
                bankObj.checked = chkAllObj.checked;
                itemIdx = 0;
                itemDone = false;
                while (!itemDone) {
                    elementId = chkItemName + "_" + bankIdx + "_" + itemIdx;
                    itemObj = document.getElementById(elementId);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        itemObj.checked = chkAllObj.checked;
                    }

                    itemIdx++;
                }
            }

            bankIdx++;
        }
    };

    that.checkBank = function (bankObj, chkAllName, chkBankName, chkItemName) {
        var itemIdx, itemObj, itemDone;
        var bankIdx = bankObj.id.split("_")[1];

        itemIdx = 0;
        itemDone = false;
        while (!itemDone) {
            itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
            if (itemObj == null) {
                itemDone = true;
            }
            else {
                itemObj.checked = bankObj.checked;
            }

            itemIdx++;
        }

        that.updateCheckList(chkAllName, chkBankName, chkItemName);
    };

    that.checkItem = function (chkAllName, chkBankName, chkItemName) {
        that.updateCheckList(chkAllName, chkBankName, chkItemName);
    };

    that.updateCheckList = function (chkAllName, chkBankName, chkItemName) {
        var bankDone, bankIdx, bankObj, checkBankState;
        var itemDone, itemIdx, itemObj;
        var chkAllObj = document.getElementById(chkAllName);
        var checkAllState = true;

        bankIdx = 0;
        bankDone = false;
        while (!bankDone) {
            bankObj = document.getElementById(chkBankName + "_" + bankIdx);
            if (bankObj == null) {
                bankDone = true;
            }
            else {
                checkBankState = true;
                itemIdx = 0;
                itemDone = false;
                while (!itemDone) {
                    itemObj = document.getElementById(chkItemName + "_" + bankIdx + "_" + itemIdx);
                    if (itemObj == null) {
                        itemDone = true;
                    }
                    else {
                        if (!itemObj.checked) {
                            checkBankState = false;
                            checkAllState = false;
                        }
                    }

                    itemIdx++;
                }
                bankObj.checked = checkBankState;
            }
            bankIdx++;
        }
        chkAllObj.checked = checkAllState;
    };

    return that;
})(window.document);