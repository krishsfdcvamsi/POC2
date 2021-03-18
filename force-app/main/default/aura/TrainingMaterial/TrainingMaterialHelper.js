({
    doInit : function(component, event) {
        var action = component.get("c.getTrainingFilesAndFolders");
        var path = {};
        var pathLst = [];
        //action.setParams();
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            
            if(resp){
                resp.forEach(function(item) {
                    if(item.isFile){
                        item['icon'] = 'doctype:'+item.fileExtension;
                    }
                    else{
                        item['icon'] = 'doctype:folder';
                        path.name = 'Training Material';
                        path.id = item.parentFolderId;
                    }
                });
                if(path.id){
                    pathLst.push(path);
                    component.set("v.path", pathLst);
                }
                //console.log(resp)
                component.set("v.trainingMaterials", resp);
            }
        });
        
        $A.enqueueAction(action);
    },
    getFilesByFolderId : function(component, event,parentContentFolderId){
        
        var action = component.get("c.getFilesByFolder");
        action.setParams({ parentContentFolderId : parentContentFolderId });
        //action.setParams();
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            resp.forEach(function(item) {
                if(item.isFile){
                    item['icon'] = 'doctype:'+item.fileExtension;
                }
                else{
                    item['icon'] = 'doctype:folder'; 
                }
            });
            
            component.set("v.trainingMaterials", resp);
        });
        $A.enqueueAction(action);
    }
})