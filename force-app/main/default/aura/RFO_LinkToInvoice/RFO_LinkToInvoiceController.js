({
	 doInit: function(component, event, helper) {
       // alert(component.get("v.recordId"));
        var action = component.get("c.getInvoiceLink");
        action.setParams({
            "AID":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {              
                var ResultSet=response.getReturnValue();
              component.set("v.Link",ResultSet.RFO_LinktoInvoice__c);
            }
        });
          $A.enqueueAction(action);
     }
                           
})