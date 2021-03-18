({
	doInit : function(component, event, helper) {
        
        component.set('v.columns', [
            /* {label: 'Title', fieldName: 'URL',
             type: 'url', typeAttributes: { label: {fieldName: 'name'} }},*/
            {label: 'Title', type: 'button',cellAttributes: { iconName: { fieldName: 'icon'} },
             typeAttributes: { label: { fieldName: 'Title'},name: {fieldName: 'Id'},variant:'base', title: 'Click to View Details'}},
            
            //{label: 'Title', fieldName: 'name', type: 'text'},
            {label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date'},
        ]);
        
        helper.doInit(component, event);
		
	},
    handleRowClick : function(component, event, helper){
            $A.get('e.lightning:openFiles').fire({
            recordIds: [event.getParam('row').Id]
                      });
	},
})