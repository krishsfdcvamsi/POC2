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
                //alert(ResultSet.length);
                if(ResultSet.length>0){            
                component.set("v.ExtObject",ResultSet[0])            
                component.set("v.truthy",true);
                }
            }  
            else{
                 var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Error!",
        "message": "External Object Exception.",
        'type':"error"
    });
  //  toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    hideSpinner:function(component, event, helper) {      
        component.set("v.SpinnerTag",false);
    },
     showSpinner : function (component, event, helper) {
         component.set("v.SpinnerTag",true); 
    }
})