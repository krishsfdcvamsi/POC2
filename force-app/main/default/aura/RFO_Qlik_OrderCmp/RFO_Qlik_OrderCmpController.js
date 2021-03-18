({
	doInit : function(component, event, helper) {
		
	var action = component.get("c.getOrderInfo");
        action.setParams({
            "OID":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {              
                var ResultSet=response.getReturnValue();   
                //alert(ResultSet.RFO_OracleId__c);
                component.set("v.FileNumberId",ResultSet.RFO_File__c)                
              
            }  
            else{
               
            }
        });
        $A.enqueueAction(action);
    },
})