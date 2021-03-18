({
	doInit : function(component, event, helper) {
		component.set('v.columns', [
            {label: 'Asset Name', fieldName: 'AssetName', type: 'text',initialWidth:120},
            {label: 'Actual Capacity', fieldName: 'ActualCapacity', type: 'text',initialWidth:150},
            {label: 'Light Weight', fieldName: 'LightWeight', type: 'text',initialWidth:140},
            {label: 'GRL', fieldName: 'GrossRailLimit', type: 'text',initialWidth:90},
            {label: 'Stencil Spec', fieldName: 'DOTStencilClass', type: 'text',initialWidth:120},
            {label: 'Date Built', fieldName: 'DateBuilt', type: 'text',initialWidth:120},
            {label: 'File #', fieldName: 'File', type: 'text',initialWidth:100},
            {label: 'Model Desc', fieldName: 'ModelDesc', type: 'text',initialWidth:120},
            {label: 'Plant Name', fieldName: 'PlantName', type: 'text',initialWidth:120},
            {label: 'Dot Class', fieldName: 'DotClass', type: 'text',initialWidth:120},
            {label: 'Car Type', fieldName: 'CarType', type: 'text',initialWidth:120},
        ]);
            component.set('v.relatedColumns', [

            {label: 'Asset File Name', fieldName: 'Name', type: 'text'},
            {label: 'File Type', fieldName: 'RFO_FileType__c', type: 'text'},
            {label: 'Current Quantity', fieldName: 'RFO_CurrentQuantity__c', type: 'text'},
            {label: 'Current Plant', fieldName: 'CurrentPlant', type: 'text'},

        ]);
        helper.getOrderById(component, event);
        helper.doInit(component, event);
        helper.getAssetFiles(component, event);
	}
})