({
	doInit : function(component, event, helper) {
		
	var action = component.get("c.getAccountInfo");
        action.setParams({
            "AID":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {              
                var ResultSet=response.getReturnValue();   
                //alert(ResultSet.RFO_OracleId__c);
                component.set("v.OracleID",ResultSet.RFO_OracleId__c)                
              
            }  
            else{
               
            }
        });
        $A.enqueueAction(action);
    },
})