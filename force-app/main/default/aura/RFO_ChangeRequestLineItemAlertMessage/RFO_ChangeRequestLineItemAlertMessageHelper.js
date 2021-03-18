({
    EditCRLIRecord : function(component,event,helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.showCRLIWarningMessage");
        action.setParams({"crliId":recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var jsonResp=response.getReturnValue();
                component.set("v.ChangeRequestErrorMessage",jsonResp);
            }
        });
        $A.enqueueAction(action);        
    }
})