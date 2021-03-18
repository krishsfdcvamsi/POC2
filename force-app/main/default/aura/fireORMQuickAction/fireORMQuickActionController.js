({
	doinit : function(component, event, helper) {
        var action = component.get("c.getOrderId");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response) {
            if (response.getState() === "SUCCESS") {
                var responseVal =  response.getReturnValue();
                component.set("v.orderId",responseVal);
                var navEvt = $A.get("e.force:navigateToSObject");
                if(responseVal != "Order"){
                navEvt.setParams({
                    "recordId": responseVal,
                    "slideDevName": "related"
                });
                }
                //navEvt.fire();
                //
                var evt = $A.get("e.force:navigateToComponent");
                if(responseVal != "Order"){
                evt.setParams({
                    componentDef : "c:ORM_Notes",
                    componentAttributes: {
                        recordId : responseVal
                    }
                });
                }
                else{
                    evt.setParams({
                    componentDef : "c:ORM_Notes",
                    componentAttributes: {
                        recordId : component.get("v.recordId")
                    }
                });
                }
                
                evt.fire();
                //
                var actionAPI = component.find("quickActionAPI");
                var fields = {Id: {value: component.get("v.recordId")}};//{value: component.get("v.recordId")}
                var args = {actionName: "Order.ORM_Notes",entityName: "Order", targetFields: fields};
                console.log(actionAPI.getAvailableActions());
                actionAPI.setActionFieldValues(args).then(function(result) {
                    //actionAPI.invokeAction(args);
                }).catch(function(e) {
                    if(e.errors) {
                        console.log(e.errors);
                        console.log("error");
                    }
                });
            }
        });
        $A.enqueueAction(action);
        
        
	}
    
    
    

})