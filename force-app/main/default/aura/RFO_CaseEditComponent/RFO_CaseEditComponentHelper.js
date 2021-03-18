({
    EditCaseRecord : function(component,event,helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.showWarningMessage");
        action.setParams({"caseId":recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var jsonResp=response.getReturnValue();
                component.set("v.caseErrorMessage",jsonResp);
            }
        });
        $A.enqueueAction(action);        
    }
})