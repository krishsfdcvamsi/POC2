({
	doInit : function(component, event, helper) {
        
		var lineItemId = component.get("v.lineItemId");
        console.log('lineItemId>>>>>>>lineItemId>>>>',lineItemId);
        //alert(lineItemId);
        var action = component.get("c.getAssetInformation");
        action.setParams({
            "lineItemId": lineItemId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                console.log('resultData>>>>>',resultData);
                if(resultData.success){
                    console.log('resultData>AssetGroup>>>>',resultData.AssetGroup);
                    component.set("v.assetGroup", resultData.AssetGroup);
                    var lstAssetLines = resultData.AssetLines;
                    console.log('lstAssetLines>AssetGroup>>>>',lstAssetLines);
                    /*
                    //var objListView = '/lightning/o/Asset/list?filterName='+resultData.AssetListView.Id;
                    //console.log('objListView>>>>>>',objListView);
                   // component.set("v.listViewId", objListView);
                    var AssetLines	=[];
                    for(var i=0;i<lstAssetLines.length;i++){
                        console.log('lstAssetLines',lstAssetLines[i]);
                        var AssetLine = {};
                        AssetLine.Id = lstAssetLines[i].Id;
                        if(	!$A.util.isEmpty(lstAssetLines[i].Asset_Group__c)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset_Group__c)
                          ){
                            AssetLine.AssetGroupName = lstAssetLines[i].Asset_Group__r.Group_Name__c;
                            AssetLine.AssetGroupLink = '/'+lstAssetLines[i].Asset_Group__c;
                        }
                        if(	!$A.util.isEmpty(lstAssetLines[i].Asset__c)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__c)
                          ){
                            AssetLine.AssetId 				= 	lstAssetLines[i].Asset__c;
                            AssetLine.AssetName 			= 	lstAssetLines[i].Asset__r.Name;
                            AssetLine.AssetLink 			= 	'/'+lstAssetLines[i].Asset__c;
                            AssetLine.Orgion 				= 	lstAssetLines[i].Asset__r.RFO_Origin__c;
                            AssetLine.CarType 				= 	lstAssetLines[i].Asset__r.RFO_CarType__c;
                            AssetLine.TRNumber 				= 	lstAssetLines[i].Asset__r.RFO_TRNumber__c;
                            //AssetLine.ProjectNumber 		= 	lstAssetLines[i].Asset__r.Project_Number__c;
                            AssetLine.CarFile 				= 	lstAssetLines[i].Asset__r.RFO_File__c;
                            AssetLine.CarCondition 			= 	lstAssetLines[i].Asset__r.RFO_CarCondition__c;
                            AssetLine.LocationStatus 		= 	lstAssetLines[i].Asset__r.RFO_LocationStatus__c;
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.Price)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.Price)
                          ){
                                AssetLine.AssetPrice 			= 	lstAssetLines[i].Asset__r.Price;
                            }
                            
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.ProductCode)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.ProductCode)
                          ){
                                AssetLine.AssetProductCode 			= 	lstAssetLines[i].Asset__r.ProductCode;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.ProductFamily)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.ProductFamily)
                          	){
                                AssetLine.AssetProductFamily 			= 	lstAssetLines[i].Asset__r.ProductFamily;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.PurchaseDate)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.PurchaseDate)
                          	){
                                AssetLine.AssetPurchaseDate 			= 	lstAssetLines[i].Asset__r.PurchaseDate;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.Quantity)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.Quantity)
                          	){
                                AssetLine.AssetQuantity 			= 	lstAssetLines[i].Asset__r.Quantity;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.SerialNumber)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.SerialNumber)
                          	){
                                AssetLine.AssetSerialNumber 			= 	lstAssetLines[i].Asset__r.SerialNumber;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.Status)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.Status)
                          	){
                                AssetLine.AssetStatus 			= 	lstAssetLines[i].Asset__r.Status;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.Status)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.Status)
                          	){
                                AssetLine.AssetManufactureDate 			= 	lstAssetLines[i].Asset__r.ManufactureDate;
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.AccountId)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.AccountId)
                              ){
                                AssetLine.AccountName = lstAssetLines[i].Asset__r.Account.Name;
                                AssetLine.Accountlink = '/'+lstAssetLines[i].Asset__r.AccountId;
                                
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.Product2Id)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.Product2Id)
                              ){
                                AssetLine.ProuctName = lstAssetLines[i].Asset__r.Product2.Name;
                                AssetLine.Productlink = '/'+lstAssetLines[i].Asset__r.Product2Id;
                                
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.ContactId)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.ContactId)
                              ){
                                AssetLine.ContactName = lstAssetLines[i].Asset__r.Contact.Name;
                                AssetLine.Contactlink = '/'+lstAssetLines[i].Asset__r.ContactId;
                                
                            }
                            if(	!$A.util.isEmpty(lstAssetLines[i].Asset__r.ParentId)
                   							&& 
                   			!$A.util.isUndefinedOrNull(lstAssetLines[i].Asset__r.ParentId)
                              ){
                                AssetLine.ParentName = lstAssetLines[i].Asset__r.Parent.Name;
                                AssetLine.Parentlink = '/'+lstAssetLines[i].Asset__r.ParentId;
                                
                            }
                            
                        }
                        console.log('AssetLine>>>>>',AssetLine);
                        AssetLines.push(AssetLine);
                    }
                    console.log('AssetLines>>>>>>',AssetLines);
                    */
                    component.set("v.assetLinesCount",lstAssetLines.length);
                    component.set("v.totalAssetLines",lstAssetLines);
                    component.set("v.tempTotalAssetLines",lstAssetLines);
                    var assetLineLimit = component.get("v.assetLineLimit");
                    var firstAssets  = lstAssetLines.slice(0,assetLineLimit);
                    component.set("v.assetlineQueryOffset",0);
                    component.set("v.assetLines",firstAssets);
                    console.log('firstAssets>>>>>>',firstAssets);
                    if(lstAssetLines.length == firstAssets.length){
                        component.set("v.enableInfiniteLoadingLine",false);
                    }else if(lstAssetLines.length > firstAssets.length){
                        component.set("v.enableInfiniteLoadingLine",true);
                    }else{
                        component.set("v.enableInfiniteLoadingLine",false);
                    }
                    //var selectedRows =  [];
                    //component.set("v.selectedRowsAssetLines",selectedRows);
                    //component.set("v.SelectedAssets",selectedRows);
                    
                }else{
                    (resultData.msg);
                    //this.showToast(component,resultData.msg,'error','Error!!');
                }
                component.set("v.SpinnerLoaded",false);
            }else if(state === "ERROR" ){
                let errors = response.getError();
                console.log('errors>>>>>',errors);
                
                alert('Some error, Please contact with your system Admin.');
                //this.showToast(component,'Some error, Please contact with your system Admin.','error','Error!!');
            	component.set("v.SpinnerLoaded",false);
            }else{
                alert('Something went wrong, Please contact with your system Admin.');
                //this.showToast(component,'Something went wrong, Please contact with your system Admin.','error','Error!!');
            	component.set("v.SpinnerLoaded",false);
            }
        });
        $A.enqueueAction(action);
        //component.set('v.SpinnerLoaded',false);
	},
    loadMoreAssetLinesData:function(component, event, helper){
        var totalAssetLines 				= component.get("v.totalAssetLines");
        var totalQueriedAssets 				= component.get("v.tempTotalAssetLines");
        var assetLines 						= component.get("v.assetLines");
        var assetLinesCount 				= component.get("v.assetLinesCount");
        var totalRecordCount 	 = 0;
        if(!$A.util.isEmpty(totalQueriedAssets) && !$A.util.isUndefinedOrNull(totalQueriedAssets)){
                totalRecordCount = totalQueriedAssets.length; 
        }
        event.getSource().set("v.isLoading", true);
        component.set("v.enableInfiniteLoadingLine",true);
        console.log('totalQueriedAssets>>>>>',totalQueriedAssets);
        console.log('totalQueriedAssets>>>>>.length>>',totalRecordCount);
        console.log('assetLines.length>>>>>.length>>',assetLines.length);
        if(totalRecordCount > assetLines.length){
            var assetlineQueryOffset =  component.get("v.assetlineQueryOffset");
            var assetLineLimit =  component.get("v.assetLineLimit");
            console.log('assetLineLimit>>>>>>',assetlineQueryOffset);
            console.log('queryLimit>>>>>>',assetLineLimit);
            assetlineQueryOffset = assetlineQueryOffset+assetLineLimit;
            console.log('assetlineQueryOffset>>>>>>',assetlineQueryOffset);
            var secondSetValues  = totalAssetLines.slice(assetlineQueryOffset,assetlineQueryOffset+assetLineLimit);
            console.log('loadMoreData secondSetValues>>>>>>',secondSetValues);
            var finalAssets = assetLines.concat(secondSetValues);
            console.log('loadMoreData finalAssets>>>>>>',finalAssets);
            component.set("v.assetlineQueryOffset",assetlineQueryOffset);
            component.set("v.assetLines",finalAssets);
            
            event.getSource().set("v.isLoading", false);
            component.set("v.enableInfiniteLoadingLine",true);
        }else{
            console.log('assetline lenth is greater then queried valeus....');
            event.getSource().set("v.isLoading", false);
             component.set("v.enableInfiniteLoadingLine",false);
        }
    },
    helperSearchAssets : function(component, event, helper){
        var assetSearchKey =  component.get("v.assetSearchKey");
        component.set('v.assetSearching',true);
        console.log('assetSearchKey>>>>>',assetSearchKey);
        console.log('limit>>>>>',queryOffset);
        var queryOffset =  component.get("v.queryOffset");
        if(queryOffset<2000){
            helper.getSeacrhAllAssets(component, event, helper);
        }
        /*
        var tempArray = [];
        if(assetSearchKey){
            for(var i=0; i < allRecords.length; i++){
            if((allRecords[i].AssetName && allRecords[i].AssetName.toUpperCase().indexOf(assetSearchKey) != -1) ||
               (allRecords[i].CarType && allRecords[i].CarType.toUpperCase().indexOf(assetSearchKey) != -1 )
                ||
                (allRecords[i].TRNumber && allRecords[i].TRNumber.toUpperCase().indexOf(assetSearchKey) != -1 )
                ||
                (allRecords[i].ProjectNumber && allRecords[i].ProjectNumber.toUpperCase().indexOf(assetSearchKey) != -1 )
                )
            {
                tempArray.push(allRecords[i]);
            }
            }
        console.log('tempArray>>>>>',tempArray);
        	component.set("v.allAssets",tempArray);
        }else{
            
        }
        */
            
    },
    setColumns : function(component, event, helper){
        component.set('v.columns', [
            {label: 'Asset Name', fieldName: 'AssetLink', type: 'url',  sortable: true,
            typeAttributes: {label: { fieldName: 'AssetName' }, target: '_blank'}},
			{label: 'Account Name', fieldName: 'AccountLink', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'AccountName' }, target: '_blank'}},
            {label: 'Product Name', fieldName: 'ProductLink', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'ProductName' }, target: '_blank'}},
            {label: 'TR Number', fieldName: 'TRNUmber', type: 'text',sortable: true},
            {label: 'Project Number', fieldName: 'Projectnumber', type: 'text',sortable: true},
            {label: 'Car Type', fieldName: 'CarType', type: 'text',sortable: true},
            {label: 'Car File', fieldName: 'CarFile', type: 'text',sortable: true},
            {label: 'Service Status', fieldName: 'ServiceStatus', type: 'text',sortable: true},
            {label: 'Location', fieldName: 'AssetLocation', type: 'text',sortable: true},
            {label: 'Location Status', fieldName: 'LocationStatus', type: 'text',sortable: true},
            {label: 'Days Not Moved', fieldName: 'AssetAge', type: 'text',sortable: true},
            {label: 'Status', fieldName: 'Status', type: 'text',  sortable: true,sortable: true}
        ]);
    },
    handleDelete : function(component, event, helper){
        var SeletedRows = component.get("v.selectedRowsAssetLines");
        console.log('SeletedRowsAL>>>',SeletedRows);
        /*
        var SeletedRows=[];
        for(var i=0;i<SeletedRowsAL.length;i++){
            SeletedRows.push(SeletedRowsAL.Id);
        }
        */
        console.log('SeletedRows>>>>>',SeletedRows);
        if(
        !$A.util.isEmpty(SeletedRows)
                   							&& 
        !$A.util.isUndefinedOrNull(SeletedRows)
        ){
            console.log('SeletedRows>>>>'+SeletedRows);
            var action = component.get("c.deleteAssestLineItems");
            action.setParams({
                "SeletedRows" : SeletedRows
            });
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                        //console.log('resultData>>>>>>>>',resultData);
                        
                        if(resultData.success == true){
                            alert('Asset Line Successfully Deleted');
                            component.set("v.selectedRowsAssetLines",null);
                            //this.showToast(component,'Asset Line Successfully Deleted','success','Success!!');
                        	helper.doInit(component, event, helper);
                            //component.set("v.enableInfiniteLoadingLine",true);
                        }else if(resultData.success == false){
                            alert(resultData.msg);
                            //this.showToast(component,resultData.msg,'error','Error!!');
                        }
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                        //this.showToast(component,'From server:' + response.getReturnValue(),'error','Error');
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            	component.set('v.SpinnerLoaded',false);
                            }
                        } 
                        component.set('v.SpinnerLoaded',false);
                    }else{
                        alert('Something went wrong try again..');
                        //this.showToast(component,'Something went wrong try again..','error','Error!!');
                        component.set('v.SpinnerLoaded',false);
                    }
                }catch(exc){
                    console.log('exc>>>>>',exc);
                }
            });
            $A.enqueueAction(action);
        }else{
            alert('Please select Assest to Delete.');
           //this.showToast(component,'Please select Assest to Delete.','error','Error!!'); 
        component.set("v.SpinnerLoaded",false);
        }
        //console.log('SeletedRows',SeletedRows);
    },
    handleAdd : function(component, event, helper){
        //alert('adding..');
        component.set("v.showAddAssets",true);
        helper.Assetcolumns(component, event, helper);
        helper.getAllAssets(component, event, helper);
    },
    handleNext : function(component, event, helper){
        helper.getInitialAssets(component, event, helper,false,true);
    },
    handlePrev : function(component, event, helper){
        helper.getInitialAssets(component, event, helper,true,false);
    },
    getTotalAssets : function(component, event, helper){
        var action = component.get("c.getTotalAssetsAvailable");
       	action.setCallback(this, function(response) {
                try{
                    var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                        console.log('resultData>>>>>',resultData);
                        component.set("v.totalRows",resultData);
                    }
                }catch(exc){
                    console.log('exc>>>>>',exc);
                }
            });
            $A.enqueueAction(action);
    },
    //getInitialAssets : function(component, event, helper,pre,nxt){
    getInitialAssets : function(component, event, helper){
    	//component.set('v.SpinnerLoaded',true);
        //var assetSearchKey =  component.get("v.assetSearchKey");
    	var limit = component.get("v.initialRows");
        var offset = 0;
        var currentAssets = component.get("v.assetsToadd");
        console.log('currentAssets>>>>>>',currentAssets);
        if($A.util.isEmpty(currentAssets) && $A.util.isUndefinedOrNull(currentAssets)){
            offset = 0;
        }else{
            if(currentAssets.length >0 || currentAssets.length == null){
                offset = 0;
            }else{
                offset = currentAssets.length;
            }
        }
        //var offset = component.get("v.assetsToadd");
        var action = component.get("c.getAssetsInformation");
          action.setParams({
              "rowLimit" :  limit,
              "rowOffset" : offset
          });
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                       
                        var resultData = response.getReturnValue();
                        console.log('resultData>>>>',resultData);
                        var currentData = component.get('v.assetsToadd');  
                        if(!$A.util.isEmpty(currentData) && !$A.util.isUndefinedOrNull(currentData)){
                            var  finalresultData = currentData.concat(resultData);
                             component.set("v.currentCount", finalresultData.length);
                         component.set("v.assetsToadd", finalresultData);
                        }else{
                            component.set("v.assetsToadd", resultData);
                            component.set("v.currentCount", resultData.length);
                        }
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                        //this.showToast(component,'From server:' + response.getReturnValue(),'error','Error');
                        //component.set('v.SpinnerLoaded',false);
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            }
                        } 
                        //component.set('v.SpinnerLoaded',false);
                    }else{
                        alert('Something went wrong try again..');
                        //this.showToast(component,'Something went wrong try again..','error','Error!!');
                        //component.set('v.SpinnerLoaded',false);
                    }
                }catch(exc){
                    console.log('exc>>>>>',exc);
                }
                
            });
            $A.enqueueAction(action);
	},
    getSeacrhAllAssets : function(component, event, helper){
        	var queryOffset = 0;
            var queryLimit =  50;
        	var assetSearchKey =  component.get("v.assetSearchKey");
            var action = component.get("c.getAssetsInformation");
        var assetLines =  component.get('v.assetLines');
        	var SelectedAssetIDs = [];
        			assetLines.forEach(function (assetLine) { 
                         SelectedAssetIDs.push(assetLine.AssetId);
                    });    
        	console.log('SelectedAssetIDs>>>>>>>>',SelectedAssetIDs);
        
            console.log('limit>>>>>',queryOffset);
            console.log('offset>>>>>',queryLimit);
            action.setParams({
                "rowLimit" :  queryLimit,
                "rowOffset" : queryOffset,
                "SelectedAssetIDs":SelectedAssetIDs,
                'searchKey' :assetSearchKey
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                        console.log('resultData>>>>>>',resultData);
                        if(resultData.success){
                            var resultsvals = resultData.allAssets;
                            var totalAssets = resultData.TotalAssets;
                            if(resultsvals.length == totalAssets){
                                
                            }
                            console.log('totalAssets>>>',totalAssets);
                            console.log('resultsvals>>>',resultsvals);
                            component.set("v.allAssets",resultsvals);
                            component.set("v.totalAssets",totalAssets);
                        }else{
                            alert(resultData.msg);
                        }
                         event.getSource().set("v.isLoading", false);
                        
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            }
                        } 
                      
                    }else{
                        alert('Something went wrong try again..');
                        
                    }
            });
            $A.enqueueAction(action);
    },
    getAllAssets : function(component, event, helper){
        	var queryOffset =  component.get("v.queryOffset");
        	var assetLines =  component.get('v.totalAssetLines');
        	console.log('assetLines>>>>>',assetLines);
        	var SelectedAssetIDs = [];
            if(assetLines.length>0){
                assetLines.forEach(function (assetLine) { 
                             SelectedAssetIDs.push(assetLine.AssetId);
                });   
            }
        	/*
        	var evt = $A.get("e.force:navigateToComponent");  
        	evt.setParams({
             componentDef:"c:AssetGroupAdd",
            });
        	evt.fire();
        
               var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__AssetGroupAdd',
                    }
                };
        	pageReference.state = {"c__SelectedAssetIDs": SelectedAssetIDs};
        	var navService = component.find("navService");
            event.preventDefault();
            //navigate function navigates to page reference
            navService.navigate(pageReference);
        	*/
        	console.log('SelectedAssetIDs>>>>>>>>',SelectedAssetIDs);
            var queryLimit =  component.get("v.queryLimit");
        	var assetSearchKey =  component.get("v.assetSearchKey");
        	var lineItemId = component.get("v.lineItemId");
            var action = component.get("c.getAssetsInformation");
            console.log('limit>>>>>',queryOffset);
            console.log('offset>>>>>',queryLimit);
            action.setParams({
                //"rowLimit" :  queryLimit,
                //"rowOffset" : queryOffset,
                //'SelectedAssetIDs':SelectedAssetIDs,
                'SelectedAssetIDs':SelectedAssetIDs,
                'lineItemId':lineItemId
                //'searchKey' :assetSearchKey
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                        console.log('resultData>>>>>>',resultData);
                        if(resultData.success){
                            var resultsvals = resultData.allAssets;
                            console.log('resultsvals>>>>>>',resultsvals);
                            var totalAssets = resultData.TotalAssets;
                            var allAssets 	= component.get("v.allAssets");
                            console.log('allAssets>>>>>>',allAssets);
                            component.set("v.totalAssets",totalAssets);
                           /*
                            if($A.util.isEmpty(resultsvals) 
                               && 
                               $A.util.isUndefinedOrNull(resultsvals)){
                                //component.set("v.totalAssets",NULL);
                                //component.set("v.allAssets",resultsvals);
                            }else{
                                */
                            if(resultsvals.length > queryLimit){
                                var firstAssets  = resultsvals.slice(0,queryLimit);
                                console.log('firstAssets>>>>>',firstAssets);
                                component.set("v.allAssets",firstAssets);
                                component.set("v.totalQueriedAssets",resultsvals);
                                component.set("v.tempTotalQueriedAssets",resultsvals);
                                
                            }else{
                                component.set("v.allAssets",resultsvals);
                                component.set("v.totalQueriedAssets",resultsvals);
                                component.set("v.tempTotalQueriedAssets",resultsvals);
                            }
                            
                            
                            /*
                                  if($A.util.isEmpty(allAssets) 
                                     && 
                                     $A.util.isUndefinedOrNull(allAssets)){
                                      console.log('adding new>>>>');
                                    component.set("v.totalAssets",totalAssets);
                                    component.set("v.allAssets",resultsvals);
                                }else{
                                    console.log('allAssets>>>>',allAssets);
                                    var finalAssets = allAssets.concat(resultsvals);
                                    console.log('finalAssets>>>>',finalAssets);
                                    component.set("v.totalAssets",totalAssets);
                                    component.set("v.allAssets",finalAssets);
                                }  
                            //}
                            
                        }else{
                            alert(resultData.msg);
                        }
                         event.getSource().set("v.isLoading", false);
                        */
                      component.set("v.spinnerLoadedAssetAdd",false);      
                     }else{
                            alert(resultData.msg);
                          component.set("v.spinnerLoadedAssetAdd",false); 
                        }
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                          component.set("v.spinnerLoadedAssetAdd",false); 
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            }
                        } 
                        component.set("v.spinnerLoadedAssetAdd",false); 
                    }else{
                        alert('Something went wrong try again..');
                          component.set("v.spinnerLoadedAssetAdd",false); 
                        
                    }
            });
            $A.enqueueAction(action);
    },
    Assetcolumns : function(component, event, helper){
        	component.set('v.Assetcolumns', [
            {label: 'Asset Name', fieldName: 'AssestLink', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'AssestName' , sortable: true}, target: '_blank'}},
			{label: 'Account Name', fieldName: 'AccountLink', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'AccountName' }, target: '_blank'}},
            {label: 'Product Name', fieldName: 'ProductLink', type: 'url', sortable: true,
            typeAttributes: {label: { fieldName: 'ProductName' }, target: '_blank'}},
            {label: 'TR Number', fieldName: 'TRNUmber', type: 'text',sortable: true},
            {label: 'Project Number', fieldName: 'Projectnumber', type: 'text',sortable: true},
            {label: 'Car Type', fieldName: 'CarType', type: 'text',sortable: true},
            {label: 'Car File', fieldName: 'CarFile', type: 'text',sortable: true},
            {label: 'Service Status', fieldName: 'ServiceStatus', type: 'text',sortable: true},
                {label: 'Location', fieldName: 'Location', type: 'text',sortable: true},
                
            {label: 'Location Status', fieldName: 'LocationStatus', type: 'text',sortable: true},
            {label: 'Days Not Moved', fieldName: 'AssetAge', type: 'text',sortable: true},
            {label: 'Status', fieldName: 'Status', type: 'text',sortable: true}
            
        ]);
    },
    handleSaveGroupEdit : function(component, event, helper){
        var Description 		=  component.find("Description").get("v.value");
        var groupName 			=	component.find("GroupName").get("v.value");
        //var projectNumber 	=  component.find("projectNumber").get("v.value");
        //var TRNumber 		=  component.find("TRNumber").get("v.value");
        var groupId			=	component.get("v.editAssetGroupId");
        //console.log('groupName>>>',groupName);
        //console.log('projectNumber>>>',projectNumber);
        //console.log('TRNumber>>>',TRNumber);
        //console.log('groupId>>>',groupId);
        
        var action = component.get("c.updateAssetGroup");
          action.setParams({
              	"Description" 		: 	Description,
            	//"projectNumber" 	: 	projectNumber,
              	//"TRNumber" 			: 	TRNumber,
              	"groupId" 			:	groupId,
                "groupName"			:	groupName
          });
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                        	alert('Assets Group SuccessfullyUpdated');
                            //this.showToast(component,'Assets Group SuccessfullyUpdated','success','Success!!');
                        component.set("v.showEditAssetGroup",false);	
                        component.set('v.SpinnerLoaded',true);
                        helper.doInit(component, event, helper);
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                        //this.showToast(component,'From server:' + response.getReturnValue(),'error','Error');
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            }
                        } 
                        component.set('v.SpinnerLoaded',false);
                    }else{
                        //this.showToast(component,'Something went wrong try again..','error','Error!!');
                        alert('Something went wrong try again..');
                        component.set('v.SpinnerLoaded',false);
                    }
                }catch(exc){
                    console.log('exc>>>>>',exc);
                }
            });
            $A.enqueueAction(action);
    },
    handleSave : function(component, event, helper){
        var SelectedAssets =  component.get("v.SelectedAssetsLatest");
        console.log('SelectedAssetsLatest>>>',SelectedAssets);
        if(SelectedAssets.length>0){
            helper.handleFinalSave(component, event, helper,SelectedAssets);      
        }else{
            alert('Please select Asset to Add.');
            //this.showToast(component,'Please select Asset to Add.','error','Error!!');
            component.set("v.SpinnerLoaded",false);
        }
    },
    handleFinalSave : function(component, event, helper,SelectedAssets){
        console.log('SelectedAssets>>>>>>',SelectedAssets);
        console.log('assetGroup>>>>>>',component.get("v.assetGroup"));
        var action = component.get("c.addAssetsToLines");
          action.setParams({
              	"objAssetGroup" : component.get("v.assetGroup"),
            	"lstAssets" : SelectedAssets
          });
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();
                    	console.log('state',state);
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                         if(resultData.success == true){
                            //this.showToast(component,'Assets Successfully Added','success','Success!!');
                        	alert('Assets Successfully Added');
                             component.set("v.showAddAssets",false);
                             helper.doInit(component, event, helper);
                        }else if(resultData.success == false){
                            alert(resultData.msg);
                            //this.showToast(component,resultData.msg,'error','Error!!');
                        }
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                        //this.showToast(component,'From server:' + response.getReturnValue(),'error','Error');
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            }
                        } 
                        component.set('v.SpinnerLoaded',false);
                    }else{
                        alert('Something went wrong try again..');
                        //this.showToast(component,'Something went wrong try again..','error','Error!!');
                        component.set('v.SpinnerLoaded',false);
                    }
                }catch(exc){
                    console.log('exc>>>>>',exc);
                }
            });
            $A.enqueueAction(action);
    },
    sortData : function(component,event,helper){
        //var fieldName = event.getParam("fieldName");
        var fieldName  = 'AssetAge';
        var sortDirection = component.get("v.shortingOrder");
        console.log('sortDirection>>>>',sortDirection);
        var data = component.get("v.tempTotalQueriedAssets");
        console.log('data>>>>>>',data);
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'AssetAge'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        if(sortDirection == 'desc'){
            component.set("v.shortingOrder",'asc');
        }else if(sortDirection == 'asc'){
            component.set("v.shortingOrder",'desc');
        }
        component.set("v.totalQueriedAssets",data);
        component.get("v.queryOffset",0);
        var queryLimit = component.get("v.queryLimit");
        var firstAssets  = data.slice(0,queryLimit);
        component.set("v.allAssets",firstAssets);
	},
    sortRecords : function(component, event, helper){
        var sortOrder = component.get("v.shortingOrder");
        console.log('sortOrder>>>>>>',sortOrder);
        var totalQueriedAssets  = component.get("v.totalQueriedAssets");
        if(sortOrder == 'DESC'){
            totalQueriedAssets.sort(function(a, b){
                console.log('a.ASC>>>AssetAge>>>>>',a.AssetAge);
                console.log('b.ASC>>>>AssetAge>>>>>',b.AssetAge);
                return a.AssetAge-b.AssetAge;
            });
            
            component.set("v.shortingOrder",'ASC');
        }else if(sortOrder == 'ASC'){
            totalQueriedAssets.sort(function(a, b){
                console.log('a.DESC>>>AssetAge>>>>>',a.AssetAge);
                console.log('b.DESC>>>>AssetAge>>>>>',b.AssetAge);
                return b.AssetAge-a.AssetAge;
            });
            component.set("v.shortingOrder",'DESC');
        }
        console.log('totalQueriedAssets>after shot>>>>',totalQueriedAssets);
        var firstAssets  = totalQueriedAssets.slice(0,queryLimit);
        console.log('firstAssets>>>>>',firstAssets);
        component.set("v.allAssets",firstAssets);
        component.get("v.queryOffset",0);
        component.set("v.totalQueriedAssets",totalQueriedAssets);
    },
    filter: function(component, event, helper) {
        try{
            var SelectedAssetsLatest = component.get("v.SelectedAssetsLatest");
             var SelectedAssetsList = component.get("v.SelectedAssetsList");
            var SelectedAssets = component.get("v.SelectedAssets");
            var allAssetsObj = component.get("v.allAssetsObject");
            console.log('SelectedAssetsLatest !!!!!!!!!~~~~: '+SelectedAssetsLatest);
            console.log('SelectedAssets !!!!!!!!!~~~~: '+SelectedAssets);
            
            component.set("v.enableInfiniteLoading",true);
        	var data = component.get("v.totalQueriedAssets");
        	var term = component.get("v.assetSearchKey");
            var term1 = component.get("v.assetSearchKey1");
            var term2 = component.get("v.assetSearchKey2");
            var term3 = component.get("v.assetSearchKey3");
            if($A.util.isEmpty(term) && $A.util.isUndefinedOrNull(term)){
                //var queryLimit = component.get("v.queryLimit");
                //var totalQueriedAssets = component.get("v.totalQueriedAssets");
                //var firstAssets  = totalQueriedAssets.slice(0,queryLimit);
                console.log('firstAssets>>>>>',firstAssets);
                //component.set("v.allAssets",firstAssets);
                //component.set("v.queryOffset",0);
                //component.set("v.tempTotalQueriedAssets", totalQueriedAssets);
                //component.set("v.enableInfiniteLoading",true);
            }else{
            console.log('term>>>>>',term);
            if(term.includes('|')){/*
                console.log('multiple filters are activated.');
                var searchValues = term.split('|');
                console.log('searchValues>>>>>>',searchValues);
                var finalSearchResults= [];
                var finalSearchResultsId = [];
                for(var x of searchValues){
                  	console.log('x>>>>>>',x);  
                    var results = data, regex;
                	regex = new RegExp(x, "i");
                    results = data.filter(
                        					row =>regex.test(row.AssestName) 
                                                ||
                                           regex.test(row.ProductName)
                                                ||
                                           regex.test(row.AccountName)
                                                ||
                                           regex.test(row.Status)
                                                ||
                                           regex.test(row.CarFile)
                                                ||
                                           regex.test(row.ServiceStatus)
                                                ||
                                           regex.test(row.LocationStatus)
                                                || 
                                           regex.test(row.TRNUmber)
                        						||
                        					regex.test(row.Location)
                                                ||
                                           regex.test(row.CarType)
                                          );
                    console.log('after search>>>>>>',results);
                    	for(var i = 0; i < results.length; i++){
                            if(finalSearchResultsId.includes(results[i].Id) == false){
                                finalSearchResultsId.push(results[i].Id);
                                finalSearchResults.push(results[i]);
                            }
                    	}
                    console.log('finalSearchResultsId>>>>>>',finalSearchResultsId);
                    console.log('finalSearchResults>>>>>>',finalSearchResults);
                }
                var queryLimit = component.get("v.queryLimit");
                var firstAssets  = finalSearchResults.slice(0,queryLimit);
                console.log('firstAssets>>>>>',firstAssets);
                component.set("v.allAssets",firstAssets);
                component.set("v.queryOffset",0);
                component.set("v.tempTotalQueriedAssets", finalSearchResults);
                //component.set("v.totalAssets",finalSearchResults.length);*/
            }else{
                /*
                console.log('no multiple filters are activated.');
        		var results = data, regex;
        		regex = new RegExp(term, "i");
            	// filter checks each row, constructs new array where function returns true
            	results = data.filter(
                    			 row =>regex.test(row.AssestName) 
                                 	||
                                  regex.test(row.ProductName)
                                  	||
                                  regex.test(row.AccountName)
                                    ||
                                  regex.test(row.Status)
                    				||
                    			  regex.test(row.CarFile)
                    				||
                    			  regex.test(row.ServiceStatus)
                    				||
                    			  regex.test(row.LocationStatus)
                    				|| 
                    			  regex.test(row.TRNUmber)
                    				||
                        		  regex.test(row.Location)
                    				||
                    		      regex.test(row.CarType)
                    			);
                console.log('after search>>>>>>',results);
                var queryLimit = component.get("v.queryLimit");
                var firstAssets  = results.slice(0,queryLimit);
                console.log('firstAssets>>>>>',firstAssets);
                /////////component.set("v.allAssets",firstAssets);
                /////////component.set("v.queryOffset",0);
                //////component.set("v.tempTotalQueriedAssets", results);
                //component.set("v.totalQueriedAssets", results);*/
            }
            }
            //if($A.util.isEmpty(term1) && $A.util.isUndefinedOrNull(term1)){
                
            //}
            //else{
                console.log('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
            var data = component.get("v.totalQueriedAssets");/////
				var results = data, regex, regex1, regex2;
            var searchResultsMultiple = data;
        		regex = new RegExp(term1, "i");
                regex1 = new RegExp(term2, "i");
            regex2 = new RegExp(term3, "i");
            	// filter checks each row, constructs new array where function returns true
            if(term1 != null && !$A.util.isEmpty(term1) && !$A.util.isUndefinedOrNull(term1)){
                if(term1.includes(',')){
                console.log('multiple filters are activated.');
                var searchValues = term1.split(',');
                console.log('searchValues>>>>>>',searchValues);
                var finalSearchResults= [];
                var finalSearchResultsId = [];
                    for(var x of searchValues){
                        if(x != null && x != ''){
                            console.log('x>>>>>>',x); 
                            regex = new RegExp(x, "i");
                            results = data.filter(
                                row =>regex.test(row.CarFile) 
                            );
                            console.log('after search>>>>>>',results);
                            for(var i = 0; i < results.length; i++){
                                if(finalSearchResultsId.includes(results[i].Id) == false){
                                    finalSearchResultsId.push(results[i].Id);
                                    finalSearchResults.push(results[i]);
                                }
                            }
                            console.log('finalSearchResultsId>>>>>>',finalSearchResultsId);
                            console.log('finalSearchResults>>>>>>',finalSearchResults);
                        }
                    }
                var queryLimit = component.get("v.queryLimit");
                results  = finalSearchResults;
                searchResultsMultiple = finalSearchResults;
                //console.log('firstAssets>>>>>',firstAssets);
                //component.set("v.allAssets",firstAssets);
                //component.set("v.queryOffset",0);
                //component.set("v.tempTotalQueriedAssets", finalSearchResults);
                   ///////////////////////////////////////////////////////////////////////////
                }
                else{
                    results = data.filter(
                    			 row =>   regex.test(row.CarFile)
                    			);
                    searchResultsMultiple = results;
                }
            }
            if(term2 != null && !$A.util.isEmpty(term2) && !$A.util.isUndefinedOrNull(term2)){
                if(term2.includes(',')){
                	console.log('multiple filters are activated.');
                	var searchValues = term2.split(',');
                	console.log('searchValues>>>>>>',searchValues);
                	var finalSearchResults= [];
                	var finalSearchResultsId = [];
                    for(var x of searchValues){
                        if(x != null && x != ''){
                            console.log('x>>>>>>',x); 
                            regex = new RegExp(x, "i");
                            results = searchResultsMultiple.filter(
                                row =>regex.test(row.AssestName) 
                            );
                            console.log('after search>>>>>>',results);
                            for(var i = 0; i < results.length; i++){
                                if(finalSearchResultsId.includes(results[i].Id) == false){
                                    finalSearchResultsId.push(results[i].Id);
                                    finalSearchResults.push(results[i]);
                                }
                            }
                            console.log('finalSearchResultsId>>>>>>',finalSearchResultsId);
                            console.log('finalSearchResults>>>>>>',finalSearchResults);
                        }
                    }
                	var queryLimit = component.get("v.queryLimit");
                	results  = finalSearchResults;
                    searchResultsMultiple = finalSearchResults;
                }
                else{
            		results = results.filter(
                    			 row =>   regex1.test(row.AssestName)
                    				
                    			);   
                    searchResultsMultiple = results;
                }
            
            }
            if(term3 != null && !$A.util.isEmpty(term3) && !$A.util.isUndefinedOrNull(term3)){
                if(term3.includes(',')){
                	console.log('multiple filters are activated.');
                	var searchValues = term3.split(',');
                	console.log('searchValues>>>>>>',searchValues);
                	var finalSearchResults= [];
                	var finalSearchResultsId = [];
                    for(var x of searchValues){
                        if(x != null && x != ''){
                            console.log('x>>>>>>',x); 
                            regex = new RegExp(x, "i");
                            results = searchResultsMultiple.filter(
                                row =>regex.test(row.TRNUmber) 
                            );
                            console.log('after search>>>>>>',results);
                            for(var i = 0; i < results.length; i++){
                                if(finalSearchResultsId.includes(results[i].Id) == false){
                                    finalSearchResultsId.push(results[i].Id);
                                    finalSearchResults.push(results[i]);
                                }
                            }
                            console.log('finalSearchResultsId>>>>>>',finalSearchResultsId);
                            console.log('finalSearchResults>>>>>>',finalSearchResults);
                        }
                    }
                	var queryLimit = component.get("v.queryLimit");
                	results  = finalSearchResults;
                }
                else{
            	results = results.filter(
                    			 row =>   regex2.test(row.TRNUmber)
                    				
                    			);   
            }
            }
                var queryLimit = component.get("v.queryLimit");
                //var firstAssets  = results.slice(0,queryLimit);
                var firstAssets  = results;
            var firstAssets1 = [];
            for(var i=0;i<firstAssets.length;i++){
                console.log('All about to be spliced: '+firstAssets[i].Id);
                if(!SelectedAssetsLatest.includes(firstAssets[i].Id)){
                    console.log('Splice: '+firstAssets[i].Id);
                    firstAssets1.push(firstAssets[i]);
                }
            }
            if(allAssetsObj != null){
            firstAssets1 = [...firstAssets1,...allAssetsObj];
            }
                console.log('firstAssets>>>>>',firstAssets);
                component.set("v.allAssets",firstAssets1);
                component.set("v.queryOffset",0);
                component.set("v.tempTotalQueriedAssets", results);
         // component.set("v.SelectedAssets",SelectedAssets);
           // component.set("v.SelectedAssetsLatest",SelectedAssets);
           console.log('SelectedAssetsLatest !!!!!!!!!~~~~ b bbbb : '+SelectedAssetsLatest);
            console.log('SelectedAssets !!!!!!!!!~~~~: bbbbbb  '+SelectedAssets);
            console.log('get Latest::: '+component.get("v.SelectedAssetsLatest"));
            console.log('get ::: '+component.get("v.SelectedAssets"));
            //}
        }catch(error){
            console.log('err>>>>>>',error);
        }
    },
    filterAssetGroup : function(component, event, helper){
        component.set("v.enableInfiniteLoading",true);
        var data = component.get("v.totalAssetLines");
				var results = data, regex, regex1, regex2;
        var assetName = component.get("v.assetGroupNameSearch");
        var TRN = component.get("v.assetGroupTRSearch");
        var carFile = component.get("v.assetGroupCarFileSearch");
        var selectedAssetGroupId = component.get("v.selectedRowsAssetLines");
        var assetLinesObj = component.get("v.assetLinesObj");
        
        		regex = new RegExp(assetName, "i");
        regex1 = new RegExp(TRN, "i");
        regex2 = new RegExp(carFile, "i");
            	// filter checks each row, constructs new array where function returns true
            
            if(assetName != null && !$A.util.isEmpty(assetName) && !$A.util.isUndefinedOrNull(assetName)){
            	results = data.filter(
                    			 row =>   regex.test(row.AssetName)
                    				
                    			);   
            }
        if(TRN != null && !$A.util.isEmpty(TRN) && !$A.util.isUndefinedOrNull(TRN)){
            	results = results.filter(
                    			 row =>   regex1.test(row.TRNUmber)
                    				
                    			);   
            }
            if(carFile != null && !$A.util.isEmpty(carFile) && !$A.util.isUndefinedOrNull(carFile)){
            	results = results.filter(
                    			 row =>   regex2.test(row.CarFile)
                    				
                    			);   
            }
        
        var firstAssets1 = [];
        //var queryLimit = component.get("v.queryLimit");
        var firstAssets  = results;
        for(var i=0;i<firstAssets.length;i++){
            console.log('All about to be spliced: '+firstAssets[i].Id);
            if(!selectedAssetGroupId.includes(firstAssets[i].Id)){
                console.log('Splice: '+firstAssets[i].Id);
                firstAssets1.push(firstAssets[i]);
            }
        }
        if(assetLinesObj != null){
            firstAssets1 = [...firstAssets1,...assetLinesObj];
        }
        
        component.set("v.assetLines",firstAssets1);
   },
    handleNavigateListView : function(component, event, helper){
        var assetGroup  = component.get("v.assetGroup");
        console.log('assetGroup>>>>>',assetGroup.Id);
        component.set('v.SpinnerLoaded',true);
        var action = component.get("c.getListViewDetails");
          action.setParams({
              	"assetGroupId" 		: 	assetGroup.Id
          });
            action.setCallback(this, function(response) {
                try{
                    var state = response.getState();
                    	console.log('state',state);
                    
                    if (state === "SUCCESS" ) {
                        var resultData = response.getReturnValue();
                        if(resultData.success){
                            //listViewId
                            window.open('/lightning/o/Asset_Lines__c/list?filterName='+resultData.listViewId,'_blank');
                        }else{
                            alert(resultData.msg);
                        }
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "INCOMPLETE"){
                        alert('From server:' + response.getReturnValue());
                        //this.showToast(component,'From server:' + response.getReturnValue(),'error','Error');
                        component.set('v.SpinnerLoaded',false);
                    }else if (state === "ERROR"){
                        var errors = action.getError();
                        console.log('errors',errors);
                        if (errors){
                            if (errors[0].message){
                                alert('Error Message:'+errors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].message,'error','Error!!');
                            }else if(errors[0].pageErrors[0].message){
                                alert('Error Message:'+errors[0].pageErrors[0].message);
                                //this.showToast(component,'Error Message:'+errors[0].pageErrors[0].message,'error','Error!!');
                            }
                        } 
                        component.set('v.SpinnerLoaded',false);
                    }else{
                        //this.showToast(component,'Something went wrong try again..','error','Error!!');
                        alert('Something went wrong try again..');
                        component.set('v.SpinnerLoaded',false);
                    }
                }catch(exc){
                    console.log('exc>>>>>',exc);
                }
            });
            $A.enqueueAction(action);
    },
    showToast : function(component,message,msgType,titleVal) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":titleVal,
            "type":msgType,
            "message":message
        });
        toastEvent.fire();
   },
    sortData : function(component,fieldName,sortDirection,assetGroupPage){
        if(assetGroupPage ==  'assetGroupPage'){
            var data = component.get("v.assetLines");
        }
        else{
        	var data = component.get("v.allAssets");
        }
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'TRNUmber' || fieldName == 'AssetAge'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        if(assetGroupPage ==  'assetGroupPage'){
            component.set("v.assetLines",data);
            if(fieldName == 'AssetName'){
                component.set("v.sortBy",'AssetLink');
            }
        }
        else{
        	component.set("v.allAssets",data);
             if(fieldName == 'AssestName'){
                component.set("v.sortBy",'AssestLink');
                console.log("Assessst Name");
             }
        }
    },
    convertListToCSV : function(component, objectRecords, whichOne){
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        if(whichOne == "asset"){
        	keys = ['AssestName','AccountName','ProductName','TRNUmber','Projectnumber','CarType','CarFile','ServiceStatus','Location','LocationStatus','AssetAge','Status' ];
        }
        else{
           keys = ['AssetName','AccountName','ProductName','TRNUmber','Projectnumber','CarType','CarFile','ServiceStatus','Location','LocationStatus','AssetAge','Status' ]; 
        }
        console.log('asdf');
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                 if(skey == 'CarFile' && objectRecords[i][skey] && objectRecords[i][skey].includes("-") && !objectRecords[i][skey].includes(",")){
                     csvStringResult += '="'+ objectRecords[i][skey]+'"';
                 }
                 else{
                     csvStringResult += '"'+ objectRecords[i][skey]+'"';
                 }
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;
    }
})