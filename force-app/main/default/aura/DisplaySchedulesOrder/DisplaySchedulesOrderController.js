({
	doInit: function(component,event, helper) {
        console.log('@--'+component.get("v.orderId"));
        component.set("v.dataProgress","Loading Schedules...");
		var action = component.get("c.getProjectList");
        action.setParams({
            "orderId" : component.get("v.orderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data!=null) {
                    console.log(JSON.stringify(data));
                    component.set("v.project",data);
                }
                if(JSON.stringify(data) == '{}') {
                    component.set("v.dataProgress","No schedule details were found.");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    closeModel : function(component) {
        component.set("v.isModalOpen",false);
    },
    
    showPopup : function(component) {
        component.set("v.isModalOpen",true);
        component.set("v.iscompletedCars",true);
        component.set("v.actualCompletedCars",false);
        component.set("v.actualshippedCars",false);
    },
    showPopup1 : function(component) {
        component.set("v.isModalOpen",true);
        component.set("v.iscompletedCars",false);
        component.set("v.actualCompletedCars",true);
        component.set("v.actualshippedCars",false);
    },
 	showPopup2 : function(component) {
        component.set("v.isModalOpen",true);
        component.set("v.iscompletedCars",false);
        component.set("v.actualCompletedCars",false);
        component.set("v.actualshippedCars",true);
    }
})