({
	doInit : function(component,event,helper) {
		var mechDataAction = component.get("c.getMechanicalData");
		mechDataAction.setParams({
			"assetId" : component.get("v.recordId")
   		});
		mechDataAction.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				component.set("v.mechDataId",response.getReturnValue());
			}
		});
		$A.enqueueAction(mechDataAction);
    },

})