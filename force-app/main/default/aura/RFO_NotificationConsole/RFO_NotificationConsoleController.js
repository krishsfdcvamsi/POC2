({
    // Called when the component is initialized.
    // Subscribes to the channel and displays a toast message.
    // Specifies an error handler function for empApi   
    onInit: function (component, event, helper) {
      component.set('v.subscription', null);
      component.set('v.notifications', []);
      // Get empApi component.
      const empApi = component.find('empApi');
      // Define an error handler function that prints the error to the console.
      const errorHandler = function (message) {
        console.error('Received error ', JSON.stringify(message));
      };
      // Register empApi error listener and pass in the error handler function.
      empApi.onError($A.getCallback(errorHandler));
      helper.subscribe(component, event, helper);
    },
    // Clear notifications in console app.
    onClear: function (component, event, helper) {
      component.set('v.notifications', []);
    },
    // Mute toast messages and unsubscribe/resubscribe to channel.
    onToggleMute: function (component, event, helper) {
      const isMuted = !(component.get('v.isMuted'));
      component.set('v.isMuted', isMuted);
      if (isMuted) {
        helper.unsubscribe(component, event, helper);
      } else {
        helper.subscribe(component, event, helper);
      }
      helper.displayToast(component, 'success', 'info', 'Notifications ' +
        ((isMuted) ? 'muted' : 'unmuted') + '.');
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
    SyncTAS : function(component, event, helper) {
        var buttonstate = component.get('v.buttonstate');
        if (buttonstate) {
            component.set('v.buttonstate', !buttonstate);
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
        }
    }
  })