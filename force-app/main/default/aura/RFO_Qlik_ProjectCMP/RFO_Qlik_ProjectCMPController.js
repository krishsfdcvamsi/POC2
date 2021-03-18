({
	doInit : function(component, event, helper) {
		
	var action = component.get("c.RFO_Projects__c");
        action.setParams({
            "AID":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {              
                var ResultSet=response.getReturnValue();   
                alert(ResultSet.RFO_projectId__c);
                component.set("v.projectID",ResultSet.RFO_ProjectId__c)                
              
            }  
            else{
               
            }
        });
        $A.enqueueAction(action);
    },
})