({
	doInit : function(component, event, helper) {
        component.set("v.assetSearchKey","");
        var currentRecordId = component.get("v.lineItemId");
        if(	$A.util.isEmpty(currentRecordId) || $A.util.isUndefinedOrNull(currentRecordId)){
            component.set("v.noLineItemId",true);
            
        }else{
            component.set("v.noLineItemId",false);
            component.set("v.SpinnerLoaded",true);
            helper.doInit(component, event, helper);
            //helper.getInitialAssets(component, event, helper);
            helper.setColumns(component, event, helper);
            helper.getTotalAssets(component, event, helper);
        }
        
        
	},
    backtoQuote : function(component, event, helper){
        /*
        var appEvent = $A.get("e.c:OpenQuoteline");
        appEvent.setParams({
            "popup" : "GAPProcess" 
        });
        appEvent.fire();
        */
        /*
        var navService = cmp.find("navService");
        var pageReference = cmp.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference);
       */ 
        window.open('/a2b3D0000009QzlQAE?c__actionvalue=QuoteEditor');
        console.log('console log.. to back to quote..');
    },
    sortRecords : function(component, event, helper){
        helper.sortData(component,event,helper);
    },
    loadMoreAssetLinesData : function(component, event, helper){
        helper.loadMoreAssetLinesData(component, event, helper);
    },
    LineSelect:function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.assetLinesObj",selectedRows);
        console.log('selectedRows>>>>>',selectedRows);
        //component.set("v.selectedRowsAssetLines",selectedRows);
       	console.log('selectedRows>>>',selectedRows);
        var selectedRowsIds = [];
        for(var i=0;i<selectedRows.length;i++){
            selectedRowsIds.push(selectedRows[i].Id);
        }
        component.set("v.selectedRowsAssetLines",selectedRowsIds);
        console.log("v.selectedRowsAssetLines",component.get("v.selectedRowsAssetLines"));
    },
    AssettoSave : function(component, event, helper){
        var selectedRowsAss = event.getParam('selectedRows');
        component.set("v.allAssetsObject",selectedRowsAss);
        component.set("v.SelectedAssetsList",selectedRowsAss);
        console.log('selectedRows>>>',selectedRowsAss);
        console.log('selectedRows>>>',selectedRowsAss.length);
        //component.set("v.SelectedAssets",selectedRowsAss);
        var SelectedAssetsLatest = [];
        //var SelectedAssetsId = [];
        var latestId = '';
        for(var i=0;i<selectedRowsAss.length;i++){
            SelectedAssetsLatest.push(selectedRowsAss[i].Id);
            /*
            if( i == selectedRowsAss.length-1){
                latestId = selectedRowsAss[i].Id;
            }
            */
        }
        component.set("v.SelectedAssetsLatest",SelectedAssetsLatest);
        /*
        //console.log('latestId>>>>>',latestId);
        console.log("SelectedAssetsLatest>>>",SelectedAssetsLatest);
        //component.set("v.SelectedAssets",SelectedAssetsLatest);
        if(selectedRowsAss.length > 0){
            var assetLines = component.get("v.assetLines");
            console.log('assetLines>>>>>>',assetLines);
            var assetIds =  [];
                if(assetLines !=null){
                    if(assetLines.length>0){
                    assetLines.forEach(function (assetLine) { 
                        console.log('assetLine>>>>',assetLine);
                        assetIds.push(assetLine.AssetId);
                    });    
                }
                console.log('assetIds>>>>>',assetIds);
                if(assetIds.length>0){
                        selectedRowsAss.forEach(function (asset){
                        console.log('asset>>>>>>',asset);
                        if(assetIds.includes(asset.Id)){
                            var SelectedAssets = component.get('v.SelectedAssetsLatest');
                            
                            var index = SelectedAssets.indexOf(latestId);
                            if (index > -1) {
                                   SelectedAssets.splice(index, 1);
                                }
							console.log('SelectedAssetsAfter delete>>>>',SelectedAssets);
                            component.set('v.SelectedAssetsLatest',SelectedAssets);
                            alert('Assest Already Added, Please select different Asset to Add.');
                            //helper.showToast(component,'Assest Already Added, Please select different Asset to Add.','error','Error!!');
                        }else{
                            component.set("v.SelectedAssets",SelectedAssetsLatest);
                        }
                    });    
                }else{
                    console.log('no assets added>>>>');
                    console.log('SelectedAssetsLatest>>>>>>',SelectedAssetsLatest);
                    component.set("v.SelectedAssetsLatest",SelectedAssetsLatest);
                }  
                }else{
                    console.log('no assets>>>>');
                    console.log('SelectedAssetsLatest>>>>>>',SelectedAssetsLatest);
                    component.set("v.SelectedAssetsLatest",SelectedAssetsLatest);
                }
                
        }  */   
        
    },
    handleDelete : function(component, event, helper){
        component.set("v.SpinnerLoaded",true);
        helper.handleDelete(component, event, helper);
    },
    handleAdd : function(component, event, helper){
       /*
        var urlEvent = $A.get("e.force:navigateToURL");
        var listViewId = component.get("v.listViewId");
        console.log('listViewId>>>>>>',listViewId);
        var URL = '/'+listViewId;
        urlEvent.setParams({
          "url": URL
        });
        urlEvent.fire();
        */
        
        component.set("v.spinnerLoadedAssetAdd",true);
        var allAssets = [];
        component.set("v.allAssets",allAssets);
        helper.handleAdd(component, event, helper);
    },
    closeModal : function(component, event, helper){
        component.set("v.showAddAssets",false);
        component.set("v.SelectedAssetsLatest",[]);
        component.set("v.SelectedAssetsList",[]);
        component.set("v.allAssetsObject",[]);
        component.set("v.assetSearchKey1",null);
        component.set("v.assetSearchKey2",null);
        component.set("v.assetSearchKey3",null);
        component.set("v.displaySelected",false);
    },
    handleGroupEdit : function(component, event, helper){
       component.set("v.showEditAssetGroup",true);
       component.set("v.SpinnerLoaded",true);
       var assetGroup =  component.get("v.assetGroup");
        component.set("v.editAssetGroupId",assetGroup.Id);
        component.set("v.SpinnerLoaded",false);
    },
    handleNext : function(component, event, helper) {
        helper.handleNext(component, event, helper);
    },
     
    handlePrev : function(component, event, helper) {   
        helper.handlePrev(component, event, helper);
    },
    
    loadMoreData : function(component, event, helper){
        try{
        var tempAssets 			= component.get("v.tempTotalQueriedAssets");
        var totalRecordCount 	 = 0;
        if(!$A.util.isEmpty(tempAssets) && !$A.util.isUndefinedOrNull(tempAssets)){
                totalRecordCount = tempAssets.length; 
        }
        console.log('totalRecordCount>>>>>>',totalRecordCount);
        console.log('totalRecordCount>>>>>',totalRecordCount);
        //console.log('totalAssets>>>>>>',totalAssets);
        //var totalRecordCount 		= totalAssets.length;
        var totalQueriedAssets 		= component.get("v.tempTotalQueriedAssets");
        console.log('totalQueriedAssets>>>>',totalQueriedAssets);
        var allAssets 				= component.get("v.allAssets");
        console.log('loadMoreData totalRecordCount>>>>>>',totalRecordCount);
        console.log('loadMoreData allAssets>>>>>>',allAssets);
        var totalRecords = 0;
        if(!$A.util.isEmpty(allAssets) && !$A.util.isUndefinedOrNull(allAssets)){
            totalRecords = allAssets.length;
        }
        console.log('loadMoreData allAssets length>>>>>>',totalRecords);
        event.getSource().set("v.isLoading", true);
        component.set("v.enableInfiniteLoading",true);
        if(totalRecordCount > totalRecords){
            var queryOffset =  component.get("v.queryOffset");
            var queryLimit =  component.get("v.queryLimit");
            console.log('queryOffset>>>>>>',queryOffset);
            console.log('queryLimit>>>>>>',queryLimit);
            queryOffset = queryOffset+queryLimit;
            console.log('queryOffset>>>>>>',queryOffset);
            var secondSetValues  = totalQueriedAssets.slice(queryOffset,queryOffset+queryLimit);
            console.log('loadMoreData secondSetValues>>>>>>',secondSetValues);
            var finalAssets = allAssets.concat(secondSetValues);
            console.log('loadMoreData finalAssets>>>>>>',finalAssets);
            component.set("v.queryOffset",queryOffset);
            component.set("v.allAssets",finalAssets);
            component.set("v.enableInfiniteLoading",true);
            event.getSource().set("v.isLoading", false);
        }else if(totalRecordCount == allAssets.length){
            console.log('length is same>>>');
            event.getSource().set("v.isLoading", false);
            component.set("v.enableInfiniteLoading",false);
            
        }else{
            console.log('total records are very less>>>>');
            component.set("v.enableInfiniteLoading",false);
            event.getSource().set("v.isLoading", false);
        }
        }catch(error){
            console.log(error);
        }
        
    },
     handleLoadMore : function(component,event,helper){
        if(!(component.get("v.currentCount") >= component.get("v.totalRows"))){
            //To display the spinner
            event.getSource().set("v.isLoading", true); 
            var queryOffset =  component.get("v.queryOffset");
        	if(queryOffset<2000){
            //To handle data returned from Promise function
                helper.getAssets(component,event,helper).then(function(data){ 
                    var currentData = component.get("v.assetsToadd");
                    var newData = currentData.concat(data);
                    component.set("v.assetsToadd", newData);
                    //To hide the spinner
                    event.getSource().set("v.isLoading", false); 
                });
            }
        }
        else{
            //To stop loading more rows
            component.set("v.enableInfiniteLoading",false);
            event.getSource().set("v.isLoading", false);
            alert("All Assets are loaded");
            /*
            var toastReference = $A.get("e.force:showToast");
            toastReference.setParams({
                "type":"Success",
                "title":"Success",
                "message":"All Account records are loaded",
                "mode":"dismissible"
            });
            toastReference.fire();
            */
        }
    },
    handleSaveGroupEdit : function(component, event, helper){
        helper.handleSaveGroupEdit(component, event, helper);
    },
    closeGroupEditModal : function(component, event, helper){
        component.set("v.showEditAssetGroup",false);
    },
    handleSave : function(component, event, helper){
        component.set("v.SpinnerLoaded",true);
        helper.handleSave(component, event, helper);        
    },
    serachAssets : function(component, event, helper){
        
        helper.filter(component, event, helper);
    },
    serachAssetsGroup : function(component, event, helper){
        
        helper.filterAssetGroup(component, event, helper);
    },
    handleNavigateListView : function(component, event, helper){
      helper.handleNavigateListView(component, event, helper);  
    },
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        console.log('Handle Sort: '+sortBy);
        if(sortBy == 'AssestLink'){
            console.log('AssessstLInk Handle Sortr');
            sortBy = 'AssestName';
        }
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection,'');
    },
    handleSort1 : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        console.log("Sort By Name: "+sortBy);
        if(sortBy == 'AssetLink'){
            sortBy = 'AssetName';
        }
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection,'assetGroupPage');
    },
    clearFilters : function(component,event,helper){
        component.set("v.assetSearchKey1",null);
        component.set("v.assetSearchKey2",null);
        component.set("v.assetSearchKey3",null);
        var data = component.get("v.totalQueriedAssets");
        component.set("v.allAssets",data);
        component.set("v.displaySelected",false);
    },
    clearFiltersAssetGroup : function(component, event, helper){
		component.set("v.assetGroupNameSearch",null);
        component.set("v.assetGroupTRSearch",null);
        component.set("v.assetGroupCarFileSearch",null);
        var data = component.get("v.totalAssetLines");
        component.set("v.assetLines",data); 
        component.set("v.displaySelectedAssetGroup",false);
    },
    displayFilters : function(component,event,helper){
        if(component.get("v.hideFilters") == false)
        	component.set("v.hideFilters",true);
        else
            component.set("v.hideFilters",false);
    },
    displaySelected : function(component,event,helper){
        var selectedAssetsList = component.get("v.SelectedAssetsList");
        if(component.get("v.displaySelected") == false){
        if(selectedAssetsList.length > 0){
        	component.set("v.allAssets",selectedAssetsList);
            component.set("v.displaySelected",true);
            component.set("v.enableInfiniteLoading",false);
        } else {
            alert("Please select at least one record before clicking 'Show Selected'.");
        }
    }
        else {
        var data = component.get("v.totalQueriedAssets");
        component.set("v.displaySelected",false);
        component.set("v.allAssets",data);
        component.set("v.enableInfiniteLoading",true);
        }
    },
    displaySelectedAssetGroup : function(component,event,helper){
        if(component.get("v.displaySelectedAssetGroup") == false){
            var selectedAssetGroup = component.get("v.assetLinesObj");
            if(selectedAssetGroup.length > 0){
            component.set("v.assetLines",selectedAssetGroup);
            component.set("v.displaySelectedAssetGroup",true);
            }
            else{
                alert("Please select at least one record before clicking 'Show Selected'.");
            }
        }
        else{
            var data = component.get("v.totalAssetLines");
            component.set("v.assetLines",data);
            component.set("v.displaySelectedAssetGroup",false);
        }
    },
    downloadCsv : function(component,event,helper){
        var whichOne = event.getSource().getLocalId();
        console.log("whichOne : "+whichOne);
        var recordsList;
        if(whichOne == "asset"){
        	recordsList = component.get("v.SelectedAssetsList");
        }
        else{
            recordsList = component.get("v.assetLinesObj");
        }
        console.log("selected Assets: "+JSON.stringify(recordsList));
        var recordsList1 = JSON.stringify(recordsList);
        // call the helper function which returns the CSV data as a String
        var csv = helper.convertListToCSV(component, recordsList, whichOne);
        if (csv == null){ alert('Null Cont');return;}
        console.log('CSV 1101JS: '+csv);
        // Create a temporal <a> html tag to download the CSV file
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
        hiddenElement.target = '_self';
        var today = new Date();
		var date = (today.getMonth()+1)+'-'+today.getDate()+'-'+today.getFullYear();
		hiddenElement.download = date+".csv";//component.get("v.fileName");
        document.body.appendChild(hiddenElement); //Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})