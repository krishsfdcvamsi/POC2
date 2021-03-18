({
    doInit : function(component, event, helper){
        var orderId = component.get("v.recordId");
        
		var action = component.get("c.getOrderDetails");

        action.setParams({
            "orderId" : orderId
        });       
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.orderRecord", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    handleLoad : function(component, event, helper) {
	component.set("v.showSpinner", false);
	//use this to pre populate fields wth some data
        //component.find('accountid').set('v.value', 'test');
        console.log(component.get("v.order"));                
	},       
    handleSubmit : function(component, event, helper) {
       //We don't need to put basic validation here as that are handle by lightning:inputfield and recordEditForm
       //event.preventDefault(); use this to stop default flow
    },
    handleSuccess : function(component, event, helper) {
	    
	//Redirect to detail page on success
	var payload = event.getParams().response;
        var navService = component.find("navService");
    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": payload.id,
                "objectApiName": component.get("v.sObjectName"),
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
    }
})