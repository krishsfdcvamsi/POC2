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
        });
        $A.enqueueAction(action);
	},
    setDataByAccount :  function(component, event){

         
        var selectedAccount = component.get("v.accountName");
        
        if(selectedAccount){
            component.set("v.whereClause","AccountId='"+selectedAccount+"'");
          
            component.set("v.fromCarNumber","");
            component.set("v.toCarNumber","");
            component.set("v.riderNumber","");
        }
        else{
            
            component.set("v.whereClause","");
        }
        selectedAccount = selectedAccount != '' ? selectedAccount : null;
		 this.getRiderNumbersByAccount(component, event,selectedAccount,null);        
        
    },
    getRiderNumbersByAccount : function(component, event,accountId,searchText){
        console.log(accountId, searchText);
        var action = component.get("c.getRiderNumbers");
        action.setParams({
            				accountId : accountId,
                          	searchText : searchText
                         });
        action.setCallback(this, function(response) {
            component.set("v.riderNumbers", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
   
    validateForm : function(component,event){
        var fromCarNumber;
        var toCarNumber = component.get("v.toCarNumber") ? parseInt(component.get("v.toCarNumber").substring(4)) : undefined;
        var carMark ;
        
        if(component.get("v.fromCarNumber")){
            fromCarNumber = parseInt(component.get("v.fromCarNumber").substring(4));
            carMark = component.get("v.fromCarNumber").substring(0,4)
        }
        if(!component.get("v.earnedStartDate") || !component.get("v.earnedEndDate")){
            this.showToast('error','Error','Please provide Start date and End date');
            return false;
        }
        else if(!component.find("earnedEndDate").get("v.validity").valid){
             this.showToast('error','Error','Invalid End Date');
            return false;
        }
            else if(component.get("v.toCarNumber") && carMark != component.get("v.toCarNumber").substring(0,4)){
                this.showToast('error','Error','Please check Car Mark');
            return false;
            }
        else if(fromCarNumber && toCarNumber && !(fromCarNumber <= toCarNumber)){
            this.showToast('error','Error','Please check Car Number range');
            return false;
        }
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