({
    doInit : function(component, event, helper){        
        helper.hlpCheckValidity(component, event);       
        var assets = component.get("v.assets");
        var assetsExisting = component.get("v.assetsExisting");
        var assetsExisting1 = component.get("v.assetsExisting1");
        var assetsNonExisting = component.get("v.assetsNonExisting");
        var assetIds =  component.get("v.assetIds");
        if(assets.length == 1 && !assetIds.includes(assets[0].Id)){
            
            assetIds.push(assets[0].Id);
            assetsExisting1 = [];
            assetsExisting = [];
            assetsNonExisting.push(assets[0]);
            component.set("v.assetsNonExisting", assetsNonExisting);
            component.set("v.assetIds", assetIds);
            component.set("v.assetsExisting",assetsExisting);
            component.set("v.assetsExisting1",assetsExisting1);
            return;
        }

        if(assets){
            for(var i=0;i<assets.length;i++){
                if(!assetIds.includes(assets[i].Id)){
                    assetIds.push(assets[i].Id);
                    if(assets[i].isSRAvailable){
                        assetsExisting1.push(assets[i]);
                        assetsExisting.push(assets[i].Name+' - '+(assets[i].RFO_CurrComm__r != undefined ? ' - '
                                                                  +assets[i].RFO_CurrComm__r.Name + ' - '+ assets[i].RFO_CurrComm__r.RFO_STCC__c: ''));
                    }
                    else{
                        assetsNonExisting.push(assets[i]);
                    }
                }
            }
        }
        component.set("v.assetIds", assetIds);
        component.set("v.assetsNonExisting", assetsNonExisting);
        component.set("v.assetsExisting",assetsExisting);
        component.set("v.assetsExisting1",assetsExisting1);
        
    },
    
    getAsset : function(component, event, helper) {
        var aList =[];
        component.set("v.assetList", aList);
        var thisAsset = component.find("assetLookup").get("v.selectedValue");
        var assets = component.get("v.assets");
        var assetsExisting = component.get("v.assetsExisting");
        var assetsExisting1 = component.get("v.assetsExisting1");
        var foundAssetNames = component.get("v.foundAssetNames");
        var assetsNonExisting = component.get("v.assetsNonExisting");
        
        component.find("assetLookup").clearField();
        
        var getName = component.get("c.getAssetById");
        getName.setParams({ recordId : thisAsset });
        
        getName.setCallback(this, function(response) {
            
            try{

                var assetIds = component.get("v.assetIds");
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    
                    var stcc = res.asset.RFO_CurrComm__r != undefined ? ' - '+res.asset.RFO_CurrComm__r.Name + ' - '+ res.asset.RFO_CurrComm__r.RFO_STCC__c: ''
                    res.asset.isSRAvailable = res.isSRAvailable;
                    if(assets.length > 0){
                        if(!res.asset.RFO_CurrComm__r || !res.asset.RFO_CurrComm__r.RFO_STCC__c){
                            component.set("v.errorMsg","Selected asset does not have a STCC, please create a separate Service Request for that asset (Make sure the asset can be seen in the search box)");
                            return;
                        }
                        else if((!assets[0].RFO_CurrComm__r && res.asset.RFO_CurrComm__r) || 
                                (assets[0].RFO_CurrComm__r.RFO_STCC__c != res.asset.RFO_CurrComm__r.RFO_STCC__c)){
                            component.set("v.errorMsg","The selected asset has a different STCC code. Please select an asset(s) with the same STCC code in the below list. Please create a separate Service Request for the asset(s) with a different STCC code.");
                            return;
                        }
                    }
                    
                    if(assetIds.length == 0){
                        assetsNonExisting.push(res.asset);
                        assets.push(res.asset);
                        assetIds.push(res.asset.Id);
                        component.set("v.assetIds", assetIds);
                        component.set("v.assetsNonExisting", assetsNonExisting);
                        component.set("v.enableNext", true);
                        return;
                    }
                    else if(assetIds.length == 1 && !assetIds.includes(res.asset.Id)){
                        if(assetsNonExisting[0].isSRAvailable){
                            assetsExisting.push(assetsNonExisting[0].Name+stcc);
                            assetsExisting1 = assetsNonExisting
                            assetsNonExisting = [];
                        }
                    }
                    
                    if(!assetIds.includes(res.asset.Id)){
                        assets.push(res.asset);
                        assetIds.push(res.asset.Id);
                        if(res.isSRAvailable){
                            assetsExisting.push(res.asset.Name+stcc);
                            assetsExisting1.push(res.asset);
                            component.set("v.showExisting", true);
                        }
                        else{
                            assetsNonExisting.push(res.asset)
                        }
                    }
                    
                    component.set("v.assets", assets);
                    component.set("v.assetIds", assetIds);
                    component.set("v.assetsNonExisting", assetsNonExisting);
                    component.set("v.assetsExisting",assetsExisting);
                    component.set("v.assetsExisting1",assetsExisting1);
                }
                else if (state === "INCOMPLETE") {
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                
            }
            catch(e){
                console.log(e)
            }
        });
        if(assets.length < 10){
            component.set("v.errorMsg","")
            $A.enqueueAction(getName);
        }
        else
            component.set("v.errorMsg","A maximum of 10 assets are allowed for a multiple Service Request submission. Please submit another Service Request to select the remaining assets")
            
            var getCommodity = component.get("c.getAssetCommodity");
        getCommodity.setParams({ recordId : thisAsset });
        
        getCommodity.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
                if(response.getReturnValue() == "[]") {
                    component.set("v.assetCommodity", "None [None]");
                }
                else {
                    component.set("v.assetCommodity", response.getReturnValue());
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(getCommodity);
        
        //var a = component.get('c.showSelectedAssets');
        //$A.enqueueAction(a);
        
    },
    
    handlePillRemove : function(component,event,helper){
        var assetName = event.getSource().get("v.name");
        var assets = component.get("v.assets");
        //var assetsCopy = component.get("v.assets");
        var assetIds = component.get("v.assetIds");
        var assetsNonExisting = component.get("v.assetsNonExisting");
        var assetsExisting1 = component.get("v.assetsExisting1");
        var assetsExisting = component.get("v.assetsExisting");
        //var assetsNonExistingCopy = component.get("v.assetsNonExisting");
        
        for(var i=0;i<assets.length;i++){
            if(assetName == assets[i].Name){
                assetIds.splice(assetIds.indexOf(assets[i].Id),1);
                assets.splice(i,1);
            }
        }
        for(var i=0;i<assetsNonExisting.length;i++){
            if(assetName == assetsNonExisting[i].Name){
                assetsNonExisting.splice(i,1);
            }
        }

        if(assetsExisting1.length == 1 && assetsNonExisting.length == 0){
            assetsNonExisting = assetsExisting1;
            assetsExisting1 = [];
            assetsExisting = [];
        }        
        component.set("v.assets", assets);
        component.set("v.assetIds", assetIds);
        component.set("v.assetsNonExisting", assetsNonExisting);
        component.set("v.assetsExisting", assetsExisting);
        component.set("v.assetsExisting1", assetsExisting1);
    },
    
    handleExistingAssetsRemove : function(component,event, helper){
        var assetName = event.getSource().get("v.name");
        var assetIds = component.get("v.assetIds");
        var assets = component.get("v.assets");
        var assetsCopy = component.get("v.assets");
        var assetsExisting = component.get("v.assetsExisting");
        //var assetsExistingCopy = component.get("v.assetsExisting");
        var assetsExisting1 = component.get("v.assetsExisting1");
        var assetsNonExisting = component.get("v.assetsNonExisting");
        
        try{
            for(var i=0;i<assets.length;i++){
                if(assetName.includes(assets[i].Name)){
                    assetIds.splice(assetIds.indexOf(assets[i].Id),1);
                    assets.splice(i,1);
                }
            }
            for(var i=0;i<assetsExisting.length;i++){
                if(assetName == assetsExisting[i]){
                    assetsExisting.splice(i,1);
                    assetsExisting1.splice(i,1);
                }
            }
            
            if(assetsExisting.length == 1 && assetsNonExisting.length == 0){
                assetsNonExisting = assetsExisting1;
                assetsExisting = [];
                assetsExisting1 = [];
                component.set("v.showExisting",false);
            }
        }
        catch(e){
            console.log(e);
        }
        
        component.set("v.assets", assets);
        component.set("v.assetIds", assetIds);
        component.set("v.assetsExisting", assetsExisting);
        component.set("v.assetsExisting1", assetsExisting1);
        component.set("v.assetsNonExisting", assetsNonExisting);
    },
    
    gotoNext : function(component,event,helper){
        var actionClicked = event.getSource().getLocalId();
      // Fire that action
      var foundAssetNames = component.get("v.foundAssetNames");
        var assets = component.get("v.assets");
        for(var i=0;i<assets.length;i++){
            foundAssetNames += assets[i].Name +' ,';
        }
        if(assets.length > 1){
            component.set("v.isSingleAsset", true);
        }
        else{
            component.set("v.isSingleAsset", false);
        }
        foundAssetNames = foundAssetNames.substring(0,foundAssetNames.length-1);
        component.set("v.foundAssetNames", foundAssetNames);
      var navigate = component.get('v.navigateFlow');
      navigate(actionClicked);
    },
    
    showSelectedAssets : function(component, event, helper) {
        var aList =[];
        aList.push(v.buttonLabel);
        component.set("v.assetList", aList);
        
        
    },
    updateLookup : function(component,event,helper){
        //this.getAsset(component,event,helper);
        var action = component.get('c.getAsset');
        $A.enqueueAction(action);
    }
})