({
	doInit : function(component, event, helper) {
        
        var page = component.get("v.page") || 1;
      	// get the select option (drop-down) values.   
      	var recordToDisplay = component.find("recordSize").get("v.value");
        var surveyType = component.find("surveyType").get("v.value");
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            //{label: 'Name', fieldName: 'Name', type: 'Name',sortable:'true'}, 
            {label: 'Owner', fieldName: 'RFO_AccountOwner__c', type: 'text',sortable:'false'},
            {label: 'Type', fieldName: 'Type', type: 'text',sortable:'false'},
            {label: 'Sales Manager', fieldName: 'RFO_PrimaryMarketSegment__c', type: 'text',sortable:'false'},
            {label: 'Delivery Manager', fieldName: 'RFO_DBA__c', type: 'text',sortable:'false'},
            {label: 'Delivery Director', fieldName: 'RFO_TASLastModifiedBy__c', type: 'text',sortable:'false'}
        ]);
		// call the helper function   
      helper.getAccounts(component, page, recordToDisplay,surveyType);
      //helper.hideSpinner(component);
	},
    
     navigate: function(component, event, helper) {
      // this function call on click on the previous page button  
      var page = component.get("v.page") || 1;
      // get the previous button label  
      var direction = event.getSource().get("v.label");
      // get the select option (drop-down) values.  
      var recordToDisplay = component.find("recordSize").get("v.value");
      // set the current page,(using ternary operator.)  
      page = direction === "Previous Page" ? (page - 1) : (page + 1);
         
      var surveyType = component.find("surveyType").get("v.value");   
      // call the helper function
      helper.getAccounts(component, page, recordToDisplay, surveyType);
 
   },
 
   onSelectChange: function(component, event, helper) {
      // this function call on the select opetion change,     
      var page = 1
      var recordToDisplay = component.find("recordSize").get("v.value");
      var surveyType = component.find("surveyType").get("v.value"); 
      helper.getAccounts(component, page, recordToDisplay, surveyType);
   },
   
   onSurveyTypeSelectChange: function(component, event, helper) {
       var page = component.get("v.page") || 1;
      	// get the select option (drop-down) values.   
      	var recordToDisplay = component.find("recordSize").get("v.value");
        var surveyType = component.find("surveyType").get("v.value");
        helper.getAccounts(component, page, recordToDisplay, surveyType);
   }, 
   
   
    
})