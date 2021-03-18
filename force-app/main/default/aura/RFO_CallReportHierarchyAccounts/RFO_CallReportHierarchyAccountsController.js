({
	getCallReportList : function(component, event, helper) {
	    component.set('v.mycolumns', [
            	{label: 'CR ID', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}}
                ,{label: 'Account', fieldName: 'AccountName', type: 'text'}
                //,{label: 'Primary Contact', fieldName: 'ContactName', type: 'text'}
            	,{label: 'Purpose', fieldName: 'RFO_Purpose__c', type: 'text'}
                ,{label: 'Call Date', fieldName: 'Call_Date__c', type: 'date'}
            ]);
        //call apex class method
       	var action = component.get('c.getCallReportsForHierachyAccounts');
       	action.setParams({"objId":component.get("v.recordId")});
       	action.setCallback(this, function(response) {
        	//store state of response
        	var state = response.getState();
      		if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                console.log(rows);
                for(var i=0;i<rows.length;i++){
                    var row = rows[i];
                    row.AccountName = row.Account__r.Name;
                    row.ContactName = row.Contact__r.Name;
                    row.linkName = '/'+row.Id;
                }
       			component.set('v.ListOfCallReports', rows);
      		}
    	});
       $A.enqueueAction(action);
	},
  
 	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
    
})