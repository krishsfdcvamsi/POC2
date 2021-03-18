({
	doInit : function(component,event) {
		var action = component.get("c.getFileIds");
        var path = {};
        var pathLst = [];
        console.log(component.get("v.recordId"))
        action.setParams({rfoRiderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            console.log(resp);
             
            var contentDocs = [];
            var contentDocsRider = [];
            if(resp)
            for(var i=0;i<resp.length;i++){
                var contentDoc = {}
                contentDoc.link = '/sfc/servlet.shepherd/document/download/'+resp[i].ContentDocumentId+'?operationContext=S1';
                contentDoc.title = resp[i].ContentDocument.Title;
                if(resp[i].LinkedEntityId.indexOf(component.get("v.recordId")) == -1){
                    contentDocs.push(contentDoc);
                }
                else{
                    contentDocsRider.push(contentDoc);
                }
            }
            
            component.set("v.contentDocs", contentDocs);
            component.set("v.contentDocsRider", contentDocsRider);
        });
        //https://sitb-trinityrail.cs4.force.com/sfc/servlet.shepherd/document/download/069P0000000eMpkIAE?operationContext=S1
        $A.enqueueAction(action);
	}
})