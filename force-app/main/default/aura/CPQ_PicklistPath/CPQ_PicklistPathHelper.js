({
    loadQuoteStatus : function(component, event, helper){
        var recordId = component.get("v.recordId");
        const action = component.get('c.getQuoteStatus');
        action.setParams({
                recordId: recordId
            });
        	action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
                //cpqRecordId
                var quoteInfo = response.getReturnValue();
                console.log('quoteInfo>>>>>',quoteInfo);
                component.set("v.cpqRecordId",quoteInfo.CPQ_Quote__c);
                component.set("v.reLoading",true);
            } else {

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

    showToast : function(title, type, message) {
        let toastEvent = $A.get('e.force:showToast');

        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
    }
})