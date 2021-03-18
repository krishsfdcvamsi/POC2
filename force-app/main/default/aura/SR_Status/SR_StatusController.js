({
	doInit : function(component, event, helper) {
		var action = component.get("c.getNewSrs");
        action.setParams({ newSrIds : component.get("v.srIds") });
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.srs",response.getReturnValue());
            }
         });
        $A.enqueueAction(action);
	}
})