({
	doInit: function(component, event, helper) {
         //alert(component.get("v.recordId"));
		var action = component.get("c.getAssetExternal");
         action.setParams({
            "AID":component.get("v.recordId")
         });

        action.setCallback(this, function(response) {
            var state = response.getState();
       
            if (state === "SUCCESS") {              
                var ResultSet=response.getReturnValue();
                 if(ResultSet.length>0){                    
                component.set("v.ExtObject",ResultSet[0]);
                component.set("v.truthy",true);  
                 }
               
                   
             
            }             
        });
        $A.enqueueAction(action);
        
    },
    NavigateToFilterComp:function(component, event, helper) {
     
       
    }
})