({
   getAccounts: function(component, page, recordToDisplay, surveyType) {
      component.set("v.IsSpinner",true);
      // create a server side action. 
      var action = component.get("c.fetchAccount");
      // set the parameters to method 
      action.setParams({
         "pageNumber": page,
         "recordToDisplay": recordToDisplay,
          "surveyType":surveyType
      });
      // set a call back   
      action.setCallback(this, function(a) {
         // store the response return value (wrapper class insatance)  
         var result = a.getReturnValue();
         //console.log('result ---->' + JSON.stringify(result));
         // set the component attributes value with wrapper class properties.   
 		 result.accounts.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
         component.set("v.Accounts", result.accounts);
         component.set("v.page", result.page);
         component.set("v.total", result.total);
         component.set("v.pages", Math.ceil(result.total / recordToDisplay));
 		 component.set("v.IsSpinner",false);
      });
       
      // enqueue the action 
      $A.enqueueAction(action);
      
       
   },
   showSpinner:function(component){
	  component.set("v.IsSpinner",true);
   },
  
  hideSpinner:function(component){
	component.set("v.IsSpinner",false);
  },  
})