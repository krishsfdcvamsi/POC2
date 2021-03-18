({
    doInit : function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var action = component.get("c.syncContractToTAS");
        action.setParams({
            "contractId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                var errMsg = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                cmp.set("v.recordSaveError", errMsg);
            }
            else {
                component.set("v.recordUpdateError", "");
            }
            $A.util.addClass(spinner, "slds-hide");

        });
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.enqueueAction(action);
    },
    SyncTAS : function(component, event, helper) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
        var action = component.get("c.syncContractToTAS");
        action.setParams({
            "contractId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "ERROR") {
                var errMsg = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                cmp.set("v.recordSaveError", errMsg);
            }
            else {
                component.set("v.recordUpdateError", "");
            }
            $A.util.addClass(spinner, "slds-hide");

        });
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.enqueueAction(action);
    },
    showSpinner : function(component,event,helper){
        // display spinner when aura:waiting (server waiting)
        component.set("v.toggleSpinner", true);  
        },
    hideSpinner : function(component,event,helper){
    // hide when aura:downwaiting
        component.set("v.toggleSpinner", false);
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    // Control the component behavior here when record is changed (via any component)
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            // get the fields that are changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed so refresh the component (or other component logic)
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Synced!",
                "message": "The record was updated."
            });
            resultsToast.fire();
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            console.log('Error: ' + component.get("v.error"));
        }
    }
})