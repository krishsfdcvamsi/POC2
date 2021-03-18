({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        const action = component.get('c.getQuoteInfo');
        action.setParams({
            QuoteId: recordId
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.CPQRecordId",result);
            } else {
                // this.showToast('Message', 'error', 'An error occurred while processing your request. Please contact your administrator or try again.');
                let errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: "Unknown error", // Default error message
                    type: "error"
                };
                // Pass the error message if any
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastParams.message = errors[0].message;
                }
                // Fire error toast
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();            
            }
        });
        $A.enqueueAction(action);
    },
    handleReportClick:function(component, event, helper){
        const action = component.get('c.getReportInfo');
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
                component.set("v.reportId",response.getReturnValue());
                window.open('/'+response.getReturnValue(),'_blank');

            } else {
                // this.showToast('Message', 'error', 'An error occurred while processing your request. Please contact your administrator or try again.');
                let errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: "Unknown error", // Default error message
                    type: "error"
                };
                // Pass the error message if any
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastParams.message = errors[0].message;
                }
                // Fire error toast
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();            
            }
        });
        $A.enqueueAction(action);
    }
})