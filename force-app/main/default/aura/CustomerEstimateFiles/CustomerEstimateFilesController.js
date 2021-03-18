({
	doInit : function(component, event, helper) {
		/*component.set('v.columns', [
            {label: 'Title', type: 'button',cellAttributes: { iconName: { fieldName: 'icon'} },
             typeAttributes: { label: { fieldName: 'name'},name: {fieldName: 'folderOrFileId'},variant:'base', title: 'Click to View Details'}},
            {label: 'Last Modified Date', fieldName: 'lastModifiedDate', type: 'date'},
        ]);*/
        component.set('v.columns', [
            {label: 'Title',sortable: true, type: 'button',cellAttributes: { iconName: { fieldName: 'icon'} },
             typeAttributes: { label: { fieldName: 'name'},name: {fieldName: 'Id'},variant:'base', title: 'Click to View Details'}},
            {label: 'Last Modified Date',sortable: true, fieldName: 'LastModifiedDate', type: 'date'}
        ]);
        
        var contentDocs = [
            {name : "test",folderOrFileId : "1234"},
            {name : "test1",folderOrFileId : "1235"}
        ];
       // component.set("v.contentDocs", contentDocs);
		helper.doInit(component, event);
	},
            
	handleRowClick : function(component, event, helper){
        try{
            var row = event.getParam('row');
            console.log(row.Id);
            $A.get('e.lightning:openFiles').fire({
                recordIds: [row.Id]
            });
        }
        catch(e){
            console.log(e);
        }
	},
    
    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    }
})