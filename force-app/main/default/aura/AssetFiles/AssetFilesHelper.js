({
	doInit : function(component, event) {
        var action = component.get("c.getAssets");
        action.setParams({orderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            var data = [];
            try{
            for(var i=0;i<resp.length;i++){
                if(resp[i].Asset_Mechanical__r){
                for(var j=0;j<resp[i].Asset_Mechanical__r.length;j++){

                    console.log(resp[i].Asset_Mechanical__r[j]);

                    data.push({
                        "ActualCapacity" : resp[i].Asset_Mechanical__r[j].Capacity__c,
                        "LightWeight" : resp[i].Asset_Mechanical__r[j].Light_Weight__c,
                        "GrossRailLimit" : resp[i].Asset_Mechanical__r[j].Weight_Gross_Rail_Load_Stencilled__c,
                        "DOTStencilClass" : resp[i].Asset_Mechanical__r[j].DOT_Stencil_Class__c,

                        "DateBuilt" : resp[i].Asset_Mechanical__r[j].Build_Date__c,
                        "File" : resp[i].Asset_Mechanical__r[j].File_Number__c,
                        "CarType" :  resp[i].RFO_CarType__c,
                        "AssetName":resp[i].Asset_Mechanical__r[j].Asset_Name__c,
                        "ModelDesc":resp[i].RFO_ModelDescription__c,
                        "PlantName": resp[i].RFO_AssetFile__r ? resp[i].RFO_AssetFile__r.RFO_CurrentPlant__r.Name : '',

                        "DotClass":resp[i].RFO_DOTClass__c,
                    })
                }
            }


            }
            }
            catch(E){
                console.log(E)
            }
            component.set("v.data", data);
        });
        $A.enqueueAction(action);
	},
    getOrderById : function(component,event){
        var action = component.get("c.getOrder");
        action.setParams({orderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {

            if(response.getReturnValue())

            component.set("v.recordType", response.getReturnValue().RecordType.Name);
        });
        $A.enqueueAction(action);
    },
    getAssetFiles : function(component,event){
        var action = component.get("c.getAssetFilesByOrderId");
        action.setParams({orderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var assetFiles = [];
            var resp = response.getReturnValue();

            if(resp){

            for(var i=0;i<resp.length;i++){
                if(resp[i].RFO_CurrentPlant__r)
                resp[i].CurrentPlant =  resp[i].RFO_CurrentPlant__r.Name;
                assetFiles.push(resp[i])
            }

            }

            component.set("v.assetFiles", assetFiles);
        });
        $A.enqueueAction(action);
    },
})