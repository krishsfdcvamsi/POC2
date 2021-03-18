({
    init: function (cmp, event, helper) {
         cmp.set("v.rejectBool",false);
       
            
            helper.fetchData(cmp,event, helper);
          
    },
     updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
     ,  
            
	approveAll : function(component, event, helper)
	{
		var action =component.get("c.approveAllList");
     action.setParams({
            "estimateId" : component.get("v.recordId")
         });
		component.set("v.rejectBool",false);
		action.setCallback(this, function(response) {
			var state = response.getState();
            
            if(response.getReturnValue())
            {
               
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info Message',
                message: 'You have processed all of the line items!',
                
                duration:'1000',
                key: 'info_alt',
                type: 'Success',
                mode: 'dismissible'
            });
            toastEvent.fire(); 
            }
            else
            {
               
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info Message',
                message: 'There are no Customer Waiting line items to approve',
                
                duration:'1000',
                key: 'info_alt',
                type: 'info',
                mode: 'dismissible'
            });
            toastEvent.fire();  
            }
			$A.get('e.force:refreshView').fire();
    	});
            
		$A.enqueueAction(action);      
	},
    
    handleEditCellChange : function(component, event, helper)
    {
      var records = component.get("v.selectedAccts");
        if(records[0])
        {
        var draft=event.getParam('draftValues');
       
        
        helper.draftList.push(draft[0]);
        }
    } ,
    
    
    approveRecord: function(component, event, helper)
    {
        
        console.log("In Approve Record");
        var records = component.get("v.selectedAccts");
        //alert('recordsInitial>>>>'+JSON.stringify(records));
        component.set("v.rejectBool",false);            
        //console.log(JSON.parse(JSON.stringify(records)));
        if(records[0])
        {
            var pendingRecords=[];
            for(var i = 0; i<records.length ; i++)
            {
                if(records[i].CDX_Status__c == 'CustomerWaiting')
                    pendingRecords.push(records[i]);
            }
            
            if(!pendingRecords[0])
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'You may only process Customer Waiting line items.',
                    
                    duration:'1000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                var draftListToProcess=[];
                draftListToProcess=getDrafts();
                //alert('draftListToProcess>>>'+JSON.stringify(draftListToProcess));
                
                function getDrafts()
                {
                    var draftListForApproval=[];
                    var SlicedArray=[];
                    var getIndexArray=[];
                    var SegregatedArray=[];
                    var draftArray=[];
                    var length;
                    
                    // alert(JSON.stringify(helper.draftList));
                    helper.draftList.forEach(function(draft)
                                             {
                                                 SlicedArray.push(draft.Id);
                                                 
                                             });
                    // alert(SlicedArray);
                    for(var i=0;i<SlicedArray.length;i++)
                    {
                        getIndexArray.push(SlicedArray.lastIndexOf(SlicedArray[i]));  
                        
                    }
                    //alert('getIndexArray>>>'+getIndexArray);
                    var uniqueValues = getUnique(getIndexArray);
                    // alert('uniqueValues>>>'+uniqueValues); 
                    
                    uniqueValues.forEach(function(rec)
                                         {
                                             draftArray.push(helper.draftList[rec]);
                                             
                                         });
                    //  alert('draftArray>>>'+JSON.stringify(draftArray)); 
                    
                    function getUnique(array){
                        var uniqueArray = [];
                        
                        // Loop through array values
                        for(i=0; i < array.length; i++){
                            if(uniqueArray.indexOf(array[i]) === -1) {
                                uniqueArray.push(array[i]);
                            }
                        }
                        return uniqueArray;
                    }
                    return   draftArray;    
                }          
                
                
                var action = component.get("c.approve");
                action.setParams({"lineItemforApproval" :pendingRecords,"draftList":draftListToProcess});
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    
                    helper.fetchData(component,event, helper);
                    
                    var nullList=[];
                    component.set("v.selectedAccts",nullList);
                    $A.get('e.force:refreshView').fire();
                    
                });
                
                $A.enqueueAction(action);
            }
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info Message',
                message: 'Please select an item to Approve',
                
                duration:'1000',
                key: 'info_alt',
                type: 'Warning',
                mode: 'dismissible'
            });
            toastEvent.fire(); 
            component.set('v.defaultRows',[]);
            
            $A.get('e.force:refreshView').fire(); 
        }
    },
 
            
    onChange: function(component, event, helper)
    {
        var statusOnChange = component.find("statusid").get("v.value");
        if(statusOnChange=='Approved'||statusOnChange=='Rejected')
        {
            component.set('v.bool',true);
            component.set('v.selectedBool',true);
        }
        else if(statusOnChange=='All')
        {
            component.set('v.bool',true); 
            component.set('v.selectedBool',true);
        }
        else
        {
            component.set('v.bool',false);  
            component.set('v.selectedBool',false);
        }   
        helper.fetchData(component, event, helper);
    },      
    
    
    
    
    cancel:function(component, event, helper)
    {
        helper.draftList=[];
        component.set('v.defaultRows',[]);
    },
            
            
            
            
    rejectRecord: function(component, event, helper)
    {
        //alert('Only the Pending records will be changed');
        
        var records = component.get("v.selectedAccts");
        if(records[0])
        { 
            var  action= component.get('c.validateData');
            $A.enqueueAction(action);
        }
    },

    handleSelect : function(component, event, helper) {
        
        
        var selectedRows = event.getParam('selectedRows'); 
        
        component.set('v.selectedAccts',JSON.parse(JSON.stringify(selectedRows)));  
        var records = component.get("v.selectedAccts");
        
        if(records[0])
            component.set('v.rejectBool',false);
        
    },
    
   
    
    mobileApprovalButtons: function (component, event, helper)
    {
        var selectedMenuItemValue = event.getParam("value");
        var a;
        console.log(selectedMenuItemValue);
        
        if(selectedMenuItemValue == "Approve")
        {
            console.log("In Approve");
            a = component.get('c.MobileAccept');
            
        }   
        else if(selectedMenuItemValue == "Reject")
        {
            console.log("In Reject");
            a = component.get('c.MobileReject');
        }  
        else if(selectedMenuItemValue == "All")
        {
        	a = component.get('c.approveAll');
        }
        
        $A.enqueueAction(a); 
    },
    
    mobileCheckbox: function(component, event, helper)
    {
        var selectedRecords = [];
        var checkvalue = component.find("checkData");
        
        for (var i = 0; i < checkvalue.length; i++) {
            if (checkvalue[i].get("v.value") == true) {
                
                var recordsgotten = component.get("v.data");
                 //console.log(JSON.stringify(checkvalue[i].get("v.name")));
                for (var j = 0; j < recordsgotten.length; j++)
                {                  
                    if (recordsgotten[j].Id == checkvalue[i].get("v.name"))
                    {
                        selectedRecords.push(recordsgotten[j]);
                    }
                }
            }
        }
        //console.log('selectedRecords-' + selectedRecords);
        component.set('v.selectedAccts',JSON.parse(JSON.stringify(selectedRecords)));  
    },
    
    doInit: function (cmp, event, helper)
    { 
        var initial= cmp.get('c.fetchInitialData');
        $A.enqueueAction(initial);
        
    }
    ,
    
    fetchInitialData : function(cmp, event, helper)
    {
        
        var action = cmp.get("c.getAllEstimateLineItemInitial");
        action.setParams({
            "estimateId" : cmp.get("v.recordId"),
            
            
        });
        
        action.setCallback(this, function(response) 
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   var data = response.getReturnValue();
                                   
                                   data.forEach(function(record)
                                                {
                                                    
                                                    record.linkName = '/'+record.Id;
                                                    //record.linkName='https://dev-api.trinityrail.com:8431/tst/v1/customer/estimate/api/customers/estimates/'+record.CDX_Estimate__c+'/lineItems/'+record.ExternalId;
                                                });
                                   
                                   if(data!=null)
                                   {
                                       var selectOption=false;
                                       for(var i=0;i<data.length;i++)
                                       {
                                           if(data[i].CDX_Status__c=='CustomerWaiting')
                                           {
                                               selectOption=true;
                                               break;
                                           }
                                       }
                                       
                                       if(selectOption==true)
                                       {
                                           
                                           cmp.find('statusid').set('v.value','CustomerWaiting');
                                           cmp.set("v.columns", [
                                               {
                                                   label: "Line Item",
                                                   sortable: true,
                                                   fieldName: "linkName",
                                                   type: "url",
                                                   typeAttributes: {
                                                       label: { fieldName: "ExternalId" },
                                                       target: "_blank"
                                                   }
                                               },
                                               {
                                                    label: 'Qty',
                                                    sortable:true, 
                                                    fieldName: 'CDX_Quantity__c', 
                                                    type: 'text'
                                                },
                                                //Condition Code
                                                {
                                                    label: 'JCAPP ',
                                                    sortable:true, 
                                                    fieldName: 'CDX_Job_Code_Applied__c', 
                                                    type: 'text'
                                                },        
                                                //Qualifier Code
                                               {
                                                   label: "WM",
                                                   sortable: true,
                                                   fieldName: "CDX_Why_Made__c",
                                                   type: "text"
                                               },
                                               {
                                                   label: "Repair Desc",
                                                   sortable: true,
                                                   fieldName: "CDX_Description__c",
                                                   type: "text"
                                               },
                                               {
                                                    label: 'LOC',
                                                    sortable:true, 
                                                    fieldName: 'CDX_Repair_Location__c', 
                                                    type: 'text'
                                               },
                                               {
                                                   label: "Labor",
                                                   sortable: true,
                                                   fieldName: "CDX_Labor_Charge__c",
                                                   type: "text"
                                                   /*,
                                                   cellAttributes: { alignment: "left" },
                                                   typeAttributes: { currencyCode: "USD" }
                                                   */
                                               },
                                               {
                                                   label: "Mat/Misc",
                                                   sortable: true,
                                                   fieldName: "CDX_Materials_Miscellaneous_Charge__c",
                                                   type: "text"
                                                   /*,
                                                   cellAttributes: { alignment: "left" },
                                                   typeAttributes: { currencyCode: "USD" }
                                                   */
                                               },
                                               {
                                                   label: "Total",
                                                   sortable: true,
                                                   fieldName: "CDX_Total_Amount__c",
                                                   type: "text"
                                                   /*,
                                                   cellAttributes: { alignment: "left" },
                                                   typeAttributes: { currencyCode: "USD" }
                                                   */
                                               },
                                               {
                                                   label: "Comments",
                                                   sortable: true,
                                                   fieldName: "CDX_Comments__c",
                                                   type: "text",
                                                   editable: true,
                                                   cellAttributes: { class: { fieldName: "status" } }
                                               },
                                               {
                                                   label: "Status",
                                                   sortable: true,
                                                   fieldName: "CDX_Status__c",
                                                   type: "text"
                                               }
                                           ]);
                                           cmp.set('v.bool',false);  
                                           cmp.set('v.selectedBool',false);
                                       }
                                       else
                                       {
                                           cmp.find('statusid').set('v.value','All');
                                           
                                           cmp.set("v.columns", [
                                               {
                                                   label: "Line Item",
                                                   sortable: true,
                                                   fieldName: "linkName",
                                                   type: "url",
                                                   typeAttributes: {
                                                       label: { fieldName: "ExternalId" },
                                                       target: "_blank"
                                                   }
                                               },
                                               {
                                                    label: 'Qty',
                                                    sortable:true, 
                                                    fieldName: 'CDX_Quantity__c', 
                                                    type: 'text'
                                                },
                                                //Condition Code
                                                {
                                                    label: 'JCAPP ',
                                                    sortable:true, 
                                                    fieldName: 'CDX_Job_Code_Applied__c', 
                                                    type: 'text'
                                                },        
                                                //Qualifier Code
                                               {
                                                   label: "WM",
                                                   sortable: true,
                                                   fieldName: "CDX_Why_Made__c",
                                                   type: "text"
                                               },
                                               {
                                                   label: "Repair Desc",
                                                   sortable: true,
                                                   fieldName: "CDX_Description__c",
                                                   type: "text"
                                               },
                                               {
                                                    label: 'LOC',
                                                    sortable:true, 
                                                    fieldName: 'CDX_Repair_Location__c', 
                                                    type: 'text'
                                               },
                                               {
                                                   label: "Labor",
                                                   sortable: true,
                                                   fieldName: "CDX_Labor_Charge__c",
                                                   type: "text"
                                                   /*,
                                                   cellAttributes: { alignment: "left" },
                                                   typeAttributes: { currencyCode: "USD" }
                                                   */
                                               },
                                               {
                                                   label: "Mat/Misc",
                                                   sortable: true,
                                                   fieldName: "CDX_Materials_Miscellaneous_Charge__c",
                                                   type: "text"
                                                   /*,
                                                   cellAttributes: { alignment: "left" },
                                                   typeAttributes: { currencyCode: "USD" }
                                                   */
                                               },
                                               {
                                                   label: "Total",
                                                   sortable: true,
                                                   fieldName: "CDX_Total_Amount__c",
                                                   type: "text"
                                                   /*,
                                                   cellAttributes: { alignment: "left" },
                                                   typeAttributes: { currencyCode: "USD" }
                                                   */
                                               },
                                               {
                                                   label: "Comments",
                                                   sortable: true,
                                                   fieldName: "CDX_Comments__c",
                                                   type: "text",
                                                   editable: false,
                                                   cellAttributes: { class: { fieldName: "status" } }
                                               },
                                               {
                                                   label: "Status",
                                                   sortable: true,
                                                   fieldName: "CDX_Status__c",
                                                   type: "text"
                                               }
                                           ]);
                                           cmp.set('v.bool',true);  
                                           cmp.set('v.selectedBool',true);
                                           
                                       }
                                       cmp.set('v.data',data);
                                       //cmp.set('v.defaultRows',[]);
                                       
                                   }
                                   else
                                   {
                                       
                                       cmp.set('v.errors','There is no Estimate Line Items Found...');  
                                       console.log('Here'+v.errors);
                                   }
                                   
                               }
                               // error handling when state is "INCOMPLETE" or "ERROR"
                           });
        $A.enqueueAction(action);
        
    },
    

    validateData:function(cmp,event,helper)
    {
        var selectedRecordsForToast=[];
        var enterVal=true;
        console.log("In validate data");
        var selectedRecords = cmp.get("v.selectedAccts");
        var draftListToProcess=[];
        draftListToProcess=getDrafts();
        // alert('draftListToProcess>>>'+JSON.stringify(draftListToProcess));
        
        function getDrafts()
        {
            var draftListForApproval=[];
            var SlicedArray=[];
            var getIndexArray=[];
            var SegregatedArray=[];
            var draftArray=[];
            var length;
            
            //  alert(JSON.stringify(helper.draftList));
            helper.draftList.forEach(function(draft)
                                     {
                                         SlicedArray.push(draft.Id);
                                         
                                     });
            //alert(SlicedArray);
            for(var i=0;i<SlicedArray.length;i++)
            {
                getIndexArray.push(SlicedArray.lastIndexOf(SlicedArray[i]));  
                
            }
            //alert('getIndexArray>>>'+getIndexArray);
            var uniqueValues = getUnique(getIndexArray);
            // alert('uniqueValues>>>'+uniqueValues); 
            
            uniqueValues.forEach(function(rec)
                                 {
                                     draftArray.push(helper.draftList[rec]);
                                     
                                 });
            //  alert('draftArray>>>'+JSON.stringify(draftArray)); 
            
            function getUnique(array){
                var uniqueArray = [];
                
                // Loop through array values
                for(i=0; i < array.length; i++){
                    if(uniqueArray.indexOf(array[i]) === -1) {
                        uniqueArray.push(array[i]);
                    }
                }
                return uniqueArray;
            }
            return   draftArray;    
        }          
        
        
        if(selectedRecords[0] && (draftListToProcess.length)==(selectedRecords.length))
        {
            //alert(JSON.stringify(draftListToProcess))
            draftListToProcess.forEach(function(record)
                                       {
                                           
                                           if((record.CDX_Comments__c.trim()=='')||(record.CDX_Comments__c==null))
                                           {
                                               enterVal=false;
                                               return;
                                           }
                                           
                                       });
            
            if(enterVal==false)
            {
                for(var i = 0; i<selectedRecords.length ; i++)
                {
                    if(selectedRecords[i].CDX_Status__c == 'CustomerWaiting')
                    {
                        if(selectedRecords[i].CDX_Comments__c == '' || selectedRecords[i].CDX_Comments__c == null )
                        {
                            
                            selectedRecordsForToast.push(JSON.stringify(selectedRecords[i].ExternalId));
                        }
                    }
                }
                
                var rec=[];
                for(var i=0;i<selectedRecordsForToast.length;i++)
                {
                    rec.push(JSON.parse(selectedRecordsForToast[i]));
                }
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'You must enter and save comments for line item(s):'+' '+ rec,
                    
                    duration:'1000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                // helper.draftList=[];
                
            }
            else
            {
                var action = cmp.get("c.rejectInitial");
                action.setParams({
                    "rejectionList" : selectedRecords,
                    "draftList" : helper.draftList
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("updated")
                        $A.get('e.force:refreshView').fire();            
                    }
                    else{
                        alert('Process Failed');
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(action); 
            }
            
        }
        else
        {
            helper.validationHelper(cmp,event,helper);
            
        }
        
    },
    saveMethod : function(cmp,event,helper)
    {
         console.log("IN SAVE METHOD");
        cmp.set('v.draftValues', event.getParam('draftValues'));
        var sel = cmp.get('v.selectedAccts');  
        var def = cmp.get('v.defaultRows');  
        var draf = cmp.get('v.draftValues');  
        console.log("sel: "+sel.length);
        console.log("def: "+def.length);
        console.log("draf: "+draf.length);
        console.log("draft contents: "+draf[0].CDX_Comments__c);
        
    	var fetchSelectedRecords=[];
    	var selectedRecords = cmp.get("v.selectedAccts");
    	//    if(selectedRecords[0])
     	//alert('records exists');
     	//    else
        //alert('record does not exist');
        console.log("RECORDS GOTTEN");
        console.log("SELECTED RECORDS SIZE: "+selectedRecords.length);
        console.log("REJECT BOOL: "+cmp.get('v.rejectBool'));
        if(selectedRecords[0] && cmp.get('v.rejectBool'))
        {
             console.log("SELECT RECORDS EXISTS AND REJECTION BOOL TRUE");
            //selectedRecords = cmp.get("v.listToOperate");
       		var status = helper.checkRecordAndDraftValues(cmp,event,helper);
            var draft = cmp.get('v.draftValues');
            console.log("DRAFT VALUES SIZE: "+draft);
        
            if(!status)
            {
                 console.log("STATUS IS TRUE");
                 // alert('inside if it is'); 
            	var string1='You must enter and save comments for line item(s):'
    
              	for(var i=0;i<selectedRecords.length;i++)
                {
             		if(draft.length<selectedRecords.length||draft[i].Comments__c==null||draft[i].Comments__c.trim()=='')
                    {
                   		fetchSelectedRecords.push(JSON.stringify(selectedRecords[i].ExternalId));
                    }
     
                }   
                
                 var rec=[];
                           for(var i=0;i<fetchSelectedRecords.length;i++)
                           {
                               rec.push(JSON.parse(fetchSelectedRecords[i]));
                           }
            	var string2= rec;
            	var  message=string1+string2;
                
                 cmp.set('v.errors', {
                    rows: {
                        b: {
                            title: 'Error.',
                            messages: [
                                'Enter a valid comment.'
                                
                            ],
                            fieldNames: ['CDX_Comments__c']
                        }
                    },
                    table: {
                        title: 'Error.',
                        messages: [
                       message
                            //'Comments cannot be null and same'+alert(fetchSelectedRecords);
                            //'Existing Comments need to be changes for all the selected records'    
                        ]
                    }
                });
            }
            else{
               // alert('insiden first else ');
                cmp.set('v.errors',"");
                helper.updateDraftValues(cmp,event,helper);
                helper.sendForRejection(cmp,event,helper,selectedRecords);
                //helper.validationHelper(cmp,event,helper); 
         
            }
    	}
		else
        {
           	// alert('last else');
            cmp.set('v.errors',"");
           //alert('updateDraftValuesForSave');
      	//helper.updateDraftValuesForSave(cmp,event,helper);
      		helper.fetchData(cmp,event,helper);
        }
    },
    
    MobileAccept : function(cmp,event,helper)
    {
        console.log("In Mobile Reject");
        var BadRecords = [];
        var comments = cmp.find("CommentsBox");
        var recs = cmp.get('v.selectedAccts');  
        var commentdrafts = [];
        var notif = "";
        
        console.log("Comments Number: "+comments.length);
        console.log("Comments Number: "+recs.length);
        
        for (var j = 0; j < recs.length; j++) {
            var com;
            console.log("Searching...");
            for (var i = 0; i < comments.length; i++)
            {
                console.log("Box Id: "+ comments[i].get("v.id"));
                console.log("Data Id: "+ recs[j].Id);
                
                if(comments[i].get("v.id") == recs[j].Id){
                    console.log("They Equal");
                    console.log("Comments Value: "+comments[i].get("v.value"))
                    com = comments[i].get("v.value");
                }
            }
            commentdrafts.push(recs[j]);
            commentdrafts[j].CDX_Comments__c = com;
        }

        if (recs[0])
        {
            var action = cmp.get("c.rejectInitial");
            action.setParams({
                "rejectionList" : recs,
                "draftList" : commentdrafts
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("updated")
                    $A.get('e.force:refreshView').fire();            
                }
                else{
                    alert('Process Failed');
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);   
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'No records are selected',
                
                duration:'1000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },

    
    MobileReject : function(cmp,event,helper)
    {
        console.log("In Mobile Reject");
        var BadRecords = [];
        var comments = cmp.find("CommentsBox");
        var recs = cmp.get('v.selectedAccts');  
        var commentdrafts = [];
        var notif = "";
        
        console.log("Comments Number: "+comments.length);
        console.log("Comments Number: "+recs.length);
        
        for (var j = 0; j < recs.length; j++) {
            var com;
            console.log("Searching...");
            for (var i = 0; i < comments.length; i++)
            {
                console.log("Box Id: "+ comments[i].get("v.id"));
                console.log("Data Id: "+ recs[j].Id);
                
                if(comments[i].get("v.id") == recs[j].Id){
                    console.log("They Equal");
                    console.log("Comments Value: "+comments[i].get("v.value"))
                    
                    if (comments[i].get("v.value") == "" || comments[i].get("v.value") == undefined) {
                        BadRecords.push(comments[i].get("v.label"));
                        console.log("Bad Comment Found");
                        notif = notif+recs[j].ExternalId;
                    } 
                    else{ 
                        com = comments[i].get("v.value");
                    }
                }
            }
            commentdrafts.push(recs[j]);
            commentdrafts[j].CDX_Comments__c = com;
        }
        
        console.log("Bad Records: "+BadRecords.length);
        if(BadRecords.length > 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'You must enter and save comments for line item(s):'+' '+ BadRecords,
                
                duration:'1000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else 
        { 
            console.log("None are bad");
            if (recs[0])
            {
                var action = cmp.get("c.rejectInitial");
                action.setParams({
                    "rejectionList" : recs,
                    "draftList" : commentdrafts
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("updated")
                        $A.get('e.force:refreshView').fire();            
                    }
                    else{
                        alert('Process Failed');
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(action);   
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'No records are selected',
                    
                    duration:'1000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        }
    },
    
    DesktopAccept : function(cmp,event,helper)
    {
        console.log("In Desktop Accept");
        var recs = cmp.get('v.selectedAccts');
        
        for (var i = 0; i < recs.length; i++) {
            if(recs[i].CDX_Comments__c == undefined)
            {
                recs[i].CDX_Comments__c = "";
            }
        }

        if (recs[0])
        {
            var action = cmp.get("c.approve");
            action.setParams({
                "lineItemforApproval" : recs,
                "draftList" : recs,
                "estimateId" : cmp.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("updated")
                    $A.get('e.force:refreshView').fire();            
                }
                else{
                    console.log(response.getReturnValue());
                    alert('Process Failed');
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);   
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'No records are selected',
                
                duration:'1000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
    
    DesktopReject : function(cmp,event,helper)
    {
        console.log("In Desktop Reject");
        var BadRecords = [];
        var recs = cmp.get('v.selectedAccts');
        var GoodRecords = [];
        var notif = "";
        console.log("Comments Number: "+recs.length);
        
        for (var i = 0; i < recs.length; i++) {
            console.log("In Loop");
            console.log("Id of  selected: "+recs[i].ExternalId.toString());

            if(recs[i].CDX_Comments__c == undefined)
            {
                BadRecords.push(recs[i]);
                console.log("Bad Reccord Found");
                
                if(notif == "")
                	notif = notif.concat(recs[i].ExternalId.toString());
                else
                    notif = notif.concat(", "+recs[i].ExternalId.toString());
                console.log("Notif at this time: "+notif);
            }
           else if (recs[i].CDX_Comments__c.replace(/ /g, "") == "") {
                console.log("COMMENTS:"+recs[i].CDX_Comments__c.replace(/ /g, "")+"END");
                BadRecords.push(recs[i]);
                console.log("Bad Reccord Found");
                
                if(notif == "")
                	notif = notif.concat(recs[i].ExternalId.toString());
                else
                    notif = notif.concat(", "+recs[i].ExternalId.toString());
                console.log("Notif at this time: "+notif);
            } 
            else{ 
                console.log("Good Reccord Found");
                GoodRecords.push(recs[i]);
            }
            console.log("Comment on record: "+recs[i].CDX_Comments__c);
        }
        
        console.log("Bad Records: "+BadRecords.length);
        if(BadRecords.length > 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'You must enter and save comments for line item(s):'+' '+ notif,
                
                duration:'1000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else 
        { 
            console.log("None are bad");
            if (recs[0])
            {
                var action = cmp.get("c.rejectInitial");
                action.setParams({
                    "rejectionList" : recs,
                    "draftList" : GoodRecords,
                    "estimateId" : cmp.get("v.recordId")
                });
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("updated")
                        $A.get('e.force:refreshView').fire();            
                    }
                    else{
                        alert('Process Failed');
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(action);   
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'No records are selected',
                    
                    duration:'1000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        }
    },
    
    SaveMethod2 : function(cmp,event,helper)
    {
        console.log("In Save 2");
        cmp.set('v.draftValues', event.getParam('draftValues'));
        var recs = cmp.get('v.data'); 
        var draf = cmp.get('v.draftValues'); 
        var sel = cmp.get('v.selectedAccts');  

        console.log("Selected: "+sel.length);
        for (var i = 0; i < draf.length; i++) 
        {
            for(var j = 0; j < recs.length; j++)
            {
                if(draf[i].Id == recs[j].Id)
                {
                    console.log("Ids Matched");
                    recs[j].CDX_Comments__c = draf[i].CDX_Comments__c;
                }
            } 
            
            for(var k = 0; k < sel.length; k++)
            {
                console.log("Draft Id: "+draf[i].Id);
                console.log("Selected Id: "+sel[k].Id);
                if(draf[i].Id == sel[k].Id)
                {
                    console.log("Ids Matched");
                    sel[k].CDX_Comments__c = draf[i].CDX_Comments__c;
                    console.log("Selected Comments: "+sel[k].CDX_Comments__c);
                }
            } 
        }
        
        cmp.find("dtTable").set("v.draftValues", null);
    }   
})