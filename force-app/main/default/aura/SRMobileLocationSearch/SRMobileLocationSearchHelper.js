({
	doInit : function(component, event) {
		let action = component.get("c.getCurrentUser");
        action.setCallback(this, function(response) {
            let res = response.getReturnValue();
            component.set("v.accountId",res.Contact.AccountId );
        });
        
        $A.enqueueAction(action);
	},
    validate : function(component) {
        var allValid = component.find('input').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
        });
    }
})