({
	doInit : function(component, event) {
		var action = component.get("c.getAccounts");
        //  action.setParams({orderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            
            var resp = response.getReturnValue();
            var accountsMap = {};
            for(var i=0;i<resp.length;i++){
                accountsMap[resp[i].Id] = resp[i].Name
            }
            component.set("v.accounts", resp);
            component.set("v.accountsMap", accountsMap);
            var helper = this;
            const urlParams = new URLSearchParams(window.location.search);
            window.setTimeout(
                $A.getCallback( function() {
                    component.set("v.accountName", urlParams.get('id'));
                    helper.getRiderNumbersByAccount(component,event);
                }));
        });
        $A.enqueueAction(action);
    },
     setDataByAccount :  function(component, event){
        var selectedAccount = component.get("v.accountName");
		 this.getRiderNumbersByAccount(component, event,selectedAccount,null);        
        
    },
    getRiderNumbersByAccount : function(component, event,accountId,searchText){
        console.log(accountId, searchText);
        try{
        var action = component.get("c.getRiderNumbers");
        action.setParams({
            				accountId : accountId,
                          	searchText : searchText
                         });
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            component.set("v.riderNumbers", response.getReturnValue());
        });
            
        $A.enqueueAction(action);
        }
        catch(e){
            console.log(e);
        }
    },
   
    validateForm : function(component,event){
        /*var fromCarNumber = parseInt(component.get("v.fromCarNumber"));
        var toCarNumber = parseInt(component.get("v.toCarNumber"));
        console.log(component.find("earnedStartDate").get("v.validity").valid)
        console.log()*/

        if(!component.get("v.earnedStartDate") || !component.get("v.earnedEndDate")){
            this.showToast('error','Error','Please provide Start date and End date');
            return false;
        }
        else if(!component.find("earnedEndDate").get("v.validity").valid){
             this.showToast('error','Error','Invalid End Date');
            return false;
        }

        /*else if(component.get("v.fromCarNumber") != 'All' && !(fromCarNumber <= toCarNumber)){
            this.showToast('error','Error','Please check Car Number range');
            return false;
        }*/

        return true;
    },
    showToast : function(type,tittle,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title": tittle,
            "message": message
        });
        toastEvent.fire();
}
})