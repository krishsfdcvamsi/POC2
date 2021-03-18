({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            /* {label: 'Title', fieldName: 'URL',
             type: 'url', typeAttributes: { label: {fieldName: 'name'} }},*/
            {label: 'Title', type: 'button',cellAttributes: { iconName: { fieldName: 'icon'} },
             typeAttributes: { label: { fieldName: 'name'},name: {fieldName: 'folderOrFileId'},variant:'base', title: 'Click to View Details'}},
            
            //{label: 'Title', fieldName: 'name', type: 'text'},
            {label: 'Last Modified Date', fieldName: 'lastModifiedDate', type: 'date'},
        ]);
            
            helper.doInit(component, event);
	},
	handleRowClick : function(component, event, helper){
		var row = event.getParam('row');
            var path = {};
            var pathLst = component.get("v.path");
            if(!row.isFile){
            	component.set("v.currentFolderId", row.folderOrFileId)
            	helper.getFilesByFolderId(component, event,row.folderOrFileId);
            	path.name = row.name;
            	path.id = row.folderOrFileId;
            	pathLst.push(path);
            	component.set("v.path", pathLst);
            }
            else{
            
            $A.get('e.lightning:openFiles').fire({
            recordIds: [row.folderOrFileId]
                      });
        
    }
            	
	},
 handlePathClick : function(component,event,helper){
    var folderId = event.getSource().get('v.value');
    var path = {};
    var pathLst = component.get("v.path");
    try{
    for(var i=0;i<pathLst.length;i++){
        if(folderId == pathLst[i].id && pathLst.length>1 &&
           component.get("v.currentFolderId") !==folderId){
            component.set("v.path", pathLst.slice(0,i-1));
            break;
        }
    }
    helper.getFilesByFolderId(component, event,folderId);
    }
    catch(e){
        console.log(e)
    }
}
})