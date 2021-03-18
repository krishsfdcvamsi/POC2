({
    doInit : function(component, event, helper) {
		component.set('v.assetColumns', [
            {label: 'Asset Name', fieldName: 'AssetName', type: 'text',initialWidth:150},
            {label: 'Actual Capacity', fieldName: 'ActualCapacity', type: 'text',initialWidth:150},
            {label: 'Light Weight', fieldName: 'LightWeight', type: 'text',initialWidth:150},
            {label: 'GRL', fieldName: 'GrossRailLimit', type: 'text',initialWidth:120},
            {label: 'Stencil Spec', fieldName: 'StencilSpec', type: 'text',initialWidth:120},
            {label: 'Date Built', fieldName: 'DateBuilt', type: 'text',initialWidth:120},
            {label: 'File #', fieldName: 'File', type: 'text',initialWidth:120},
            {label: 'Model Desc', fieldName: 'ModelDesc', type: 'text',initialWidth:150},
            //{label: 'Plant Name', fieldName: 'PlantName', type: 'text',initialWidth:120},
            {label: 'Dot Class', fieldName: 'DotClass', type: 'text',initialWidth:120},
            {label: 'Car Type', fieldName: 'CarType', type: 'text',initialWidth:120},
        ]);
        var data = [];
        var action = component.get("c.getAssetList");
        action.setParams({orderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var responseVal = response.getReturnValue();
            try{
				for(var i=0;i<responseVal.length;i++){
					data.push( {
						"AssetName":responseVal[i].Name,
						"ActualCapacity":responseVal[i].RFO_ActualCapacity__c,
						"LightWeight":responseVal[i].RFO_LightWeight__c,
						"GrossRailLimit":responseVal[i].RFO_GRL__c,
						"StencilSpec":responseVal[i].RFO_StencilSpec__c,
						"DateBuilt":responseVal[i].RFO_DateBuilt__c,
						"File":responseVal[i].RFO_File__c,
						"ModelDesc":responseVal[i].RFO_ModelDescription__c,
						//"PlantName":responseVal[i].RFO_MfgPlant__c,
						"DotClass":responseVal[i].RFO_DOTClass__c,
						"CarType" :responseVal[i].RFO_CarType__c
					})
				}
            }
            catch(errorMsg){
                console.log('Error Message = '+errorMsg);
            }
            component.set("v.assetData", data);
        });
        $A.enqueueAction(action);
		var action1 = component.get("c.getOrder");
		action1.setParams({orderId : component.get("v.recordId")});
		action1.setCallback(this, function(response) {
			var responseVal = response.getReturnValue();
			try{
				component.set("v.assetData", data);
				component.set("v.recordTypeName", responseVal);
			}
			catch(errorMsg){
				console.log('Error Message = '+errorMsg);
			}
			
		});
		$A.enqueueAction(action1);
	}
})