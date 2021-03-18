({
    draftList:[],
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    fetchData: function (cmp,event,helper) {
        helper.draftList=[];
        cmp.set('v.errors',"");
        if(cmp.find("statusid").get("v.value")=='CustomerWaiting')
        {
            //  cmp.set('v.bool',false);
            // cmp.set('v.selectCheckBoxColumn',false);
            cmp.set('v.columns', [
                {label: 'Line Item',sortable:true, fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'ExternalId' }, target: '_blank'}},
				{label: 'Qty',sortable:true, fieldName: 'CDX_Quantity__c', type: 'text'},
                //Condition Code
                {label: 'JCAPP ',sortable:true, fieldName: 'CDX_Job_Code_Applied__c', type: 'text'},        
                //Qualifier Code
                {label: 'WM',sortable:true, fieldName: 'CDX_Why_Made__c', type: 'text'},
                {label: 'Repair Desc',sortable:true, fieldName: 'CDX_Description__c', type: 'text'},
                {label: 'LOC',sortable:true, fieldName: 'CDX_Repair_Location__c', type: 'text'},
                {label: 'Labor',sortable:true, fieldName: 'CDX_Labor_Charge__c', type: 'text'},
                {label: 'Mat/Misc',sortable:true, fieldName: 'CDX_Materials_Miscellaneous_Charge__c', type: 'text'},
                {label: 'Total',sortable:true, fieldName: 'CDX_Total_Amount__c', type: 'text'},
                {label: 'Comments',sortable:true, fieldName: 'CDX_Comments__c', type: 'text', editable: true, cellAttributes: { class: { fieldName: 'status' } }},
                {label: 'Status',sortable:true, fieldName: 'CDX_Status__c', type: 'text'},
                
            ]);
                }
                else
                {
                // cmp.set('v.selectCheckBoxColumn',true);
                // if(cmp.find("statusid").get("v.value")=='All')
                //   cmp.set('v.bool',false);
                // else
                //   cmp.set('v.bool',true);
                cmp.set("v.columns", [
                {
                label:"Line Item",
                sortable:true,
                fieldName:"linkName",
                type:"url",
                typeAttributes: {
                label: { fieldName:"ExternalId" },
                target:"_blank"
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
                label:"WM",
                sortable:true,
                fieldName:"CDX_Why_Made__c",
                type:"text"
                },
                {
                label:"Repair Desc",
                sortable:true,
                fieldName:"CDX_Description__c",
                type:"text"
                },
                {
                label: 'LOC',
                sortable:true, 
                fieldName: 'CDX_Repair_Location__c', 
                type: 'text'
                },
                {
                label:"Labor",
                sortable:true,
                fieldName:"CDX_Labor_Charge__c",
                type:"text"
                },
                {
                label:"Mat/Misc",
                sortable:true,
                fieldName:"CDX_Materials_Miscellaneous_Charge__c",
                type:"text"
                },
                {
                label:"Total",
                sortable:true,
                fieldName:"CDX_Total_Amount__c",
                type:"text"
                },
                {
                label:"Comments",
                sortable:true,
                fieldName:"CDX_Comments__c",
                type:"text",
                editable:false,
                cellAttributes: { class: { fieldName:"status" } }
                },
                {
                label:"Status",
                sortable:true,
                fieldName:"CDX_Status__c",
                type:"text"
                }
            ]);
        }
        var action = cmp.get("c.getAllEstimateLineItem");
        action.setParams({
            "estimateId" : cmp.get("v.recordId"),
            "statusvalue" : cmp.find("statusid").get("v.value")
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                
                data.forEach(function(record){
                    // alert(record.Id);
                    record.linkName = '/'+record.Id;
                    //record.linkName='https://dev-api.trinityrail.com:8431/tst/v1/customer/estimate/api/customers/estimates/'+record.CDX_Estimate__c+'/lineItems/'+record.ExternalId;
                });
                
                
                if(data!=null)
                {
                    
                    cmp.set('v.data',data);
                    cmp.set('v.defaultRows',[]);
                    
                }
                else{
                    
                    cmp.set('v.errors','There is no Estimate Line Items Found...');  
                    console.log('Here'+v.errors);
                }
                
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
            
        });
        $A.enqueueAction(action);
    },
    
    sendForRejection : function(cmp,event,helper,recordstoReject){
        //var draftValues = event.getParam('draftValues')
        //  alert('sendForRejection>>>>');
        var action = cmp.get("c.rejectPendingOne");
        action.setParams({
            "lineItemforRejection" : recordstoReject
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue(); 
                var nullList=[];
                cmp.set("v.selectedAccts",nullList);
                helper.fetchData(cmp,event,helper);
                $A.get('e.force:refreshView').fire();            
            }
            else{
                //alert('Process Failed');
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    checkRecordAndDraftValues : function(cmp,event,helper)
    {
        var draftValues = event.getParam('draftValues');  
        var selectedRecords = cmp.get("v.selectedAccts");
        console.log('Selected Rows Data:'+ JSON.stringify(selectedRecords));
        var draftsMatchStatus = true;
        var draftRecordsMap = new Map();
        var selectedRecordMap = new Map();
        for( var i=0; i<selectedRecords.length ; i++){
            selectedRecordMap.set(selectedRecords[i].Id,selectedRecords[i].CDX_Comments__c);
        } 
        for( var i=0; i<draftValues.length ; i++){
            draftRecordsMap.set(draftValues[i].Id,draftValues[i].CDX_Comments__c);
        } 
        
        for( var i=0; i<selectedRecords.length ; i++){
            if(selectedRecords[i].CDX_Comments__c == null || selectedRecords[i].CDX_Comments__c.trim() == ''){
                if(draftRecordsMap.has(selectedRecords[i].Id)){
                    if(draftRecordsMap.get(selectedRecords[i].Id) == null || draftRecordsMap.get(selectedRecords[i].Id).trim() ==''){
                        draftsMatchStatus = false;
                    }
                }
                else{
                    draftsMatchStatus = false;
                }
            }
            else{
                if(draftRecordsMap.has(selectedRecords[i].Id)){
                    if(draftRecordsMap.get(selectedRecords[i].Id) == null || draftRecordsMap.get(selectedRecords[i].Id).trim() ==''){
                        draftsMatchStatus = false;
                    }
                }
                
            }
            
        }
        
        
        
        /* if(draftValues != null && selectedRecords != null){
       // if(draftValues.length == selectedRecords.length ){
            for(var i=0; i<selectedRecords.length ; i++){
                if(selectedRecords[i].CDX_Comments__c == null || draftValues[i].CDX_Comments__c.trim() == ''||draftValues[i].CDX_Comments__c == null ){
                    draftsMatchStatus = false;  
                }
            
        
        else{
            draftsMatchStatus = false;
        }
    }
    else{
        draftsMatchStatus = false; 
    } */
        return draftsMatchStatus;
        
    },
    
    updateDraftValues : function(cmp,event,helper){
        var draftValues = event.getParam('draftValues'); 
        //alert(JSON.stringify(draftValues));
        var action = cmp.get("c.updateLineItem");
        //action.setParams({"acc" : draftValues});
        action.setParams({"lineItem" : draftValues});
        action.setCallback(this, function(response) {
            
            var rejbool = cmp.get("v.rejectBool");
            
            
            var state = response.getState();
            cmp.set('v.defaultRows',[]);
            cmp.set("v.rejectBool",false);
            $A.get('e.force:refreshView').fire();  
            
            
        });
        $A.enqueueAction(action);  
    },
    
    
    
    validationHelper : function(cmp,event,helper)
    {
        console.log("In validate helper");
        //var draftValues = event.getParam('draftValues');
        //console.log("Draft Values: "+ JSON.stringify(draftValues));
        var records = cmp.get("v.selectedAccts");
        //console.log(JSON.parse(JSON.stringify(records)));
        if(records[0])
        {
            var pendingRecords=[];
            for(var i = 0; i<records.length ; i++)
            {
                
                if(records[i].CDX_Status__c == 'CustomerWaiting')
                    pendingRecords.push(records[i]);
            }
            
            if(pendingRecords.length<records.length)
            {
                //  alert('entered for Pending records');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'You can only modify Customer Waiting line items.',
                    
                    duration:'1000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                cmp.set('v.defaultRows',[]);
                var nullList=[];
                cmp.set("v.selectedAccts",nullList);
                cmp.set("v.rejectBool",false);
                //$A.get('e.force:refreshView').fire();
            }
            else
            {
                //  alert('Entered in else >>>>>');
                if(records[0])
                {
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'Only the Pending Line Items status  can be modified',
                       
                        duration:'1000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();*/
                    var data = cmp.get("v.data");
                    //console.log('Draft Values:'+ JSON.stringify(draftValues));
                    console.log('Selected Records:'+ JSON.stringify(records));
                    console.log('Actual Data:'+ JSON.stringify(data));
                    
                    if(records[0])
                    {
                        
                        var selectedRecordsForToast=[];
                        cmp.set("v.rejectBool",true);
                        var pendingRecord = [];
                        var arrayOfPendingRecords=[];
                        var commentMissing = false;
                        for(var i = 0; i<records.length ; i++)
                        {
                            if(records[i].CDX_Status__c == 'CustomerWaiting')
                            {
                                //  alert('Entered in else inner2 >>>>>');
                                //alert(JSON.stringify(records[i].ExternalId));
                                records[i].CDX_Status__c == 'Rejected';
                                pendingRecord.push(records[i]);
                                if(records[i].CDX_Comments__c == '' || records[i].CDX_Comments__c == null )
                                {
                                    commentMissing = true;
                                    selectedRecordsForToast.push(JSON.stringify(records[i].ExternalId));
                                }
                            }
                            // alert(JSON.stringify(selectedRecordsForToast));
                            cmp.set('v.listToOperate',pendingRecord);
                        }
                        // arrayOfPendingRecords = arrayOfStrings.map(selectedRecordsForToast);
                        //alert(arrayOfPendingRecords);
                        if(commentMissing)
                        {
                            // alert('Entered in else inner3 >>>>>');
                            //arrayOfPendingRecords = arrayOfStrings.map(selectedRecordsForToast);
                            var rec=[];
                            for(var i=0;i<selectedRecordsForToast.length;i++)
                            {
                                rec.push(JSON.parse(selectedRecordsForToast[i]));
                            }
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Info Message',
                                message: 'You must enter and save comments for line item(s):'+' '+rec,
                                
                                duration:'1000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();
                        }
                        else{
                            //alert('Entered in else inner4 >>>>>');
                            console.log('Record for update:'+ pendingRecord);
                            if(pendingRecord != null){
                                this.sendForRejection(cmp,event,helper,pendingRecord); 
                            }
                        }
                    }
                    else{
                        alert('No Record to update');
                    }
                }
            }
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info Message',
                message: 'Please select an item to Reject',
                
                duration:'1000',
                key: 'info_alt',
                type: 'Warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    }
    
}
)