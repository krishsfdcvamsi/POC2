({
	doInit : function(component,event) {
		
        var action = component.get("c.getMyDocuments");
        var path = {};
        var pathLst = [];
        //action.setParams();
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            console.log(resp);
            var extension;
            if(resp)
            resp.forEach(function(item) {
                if(['png','jpg','jpeg'].indexOf(item.FileExtension.toLowerCase()) != -1)
                    extension =  'image';
                else if(['xlsx','xls'].indexOf(item.FileExtension.toLowerCase()) != -1)
                    extension =  'excel';
                else if(['doc','docx'].indexOf(item.FileExtension.toLowerCase()) != -1)
                    extension =  'word';
                else
                    extension =  item.FileExtension;
                    item['icon'] = 'doctype:'+extension
            });
            component.set("v.contentDocs", resp);
        });
        
        $A.enqueueAction(action);
        
	}
})