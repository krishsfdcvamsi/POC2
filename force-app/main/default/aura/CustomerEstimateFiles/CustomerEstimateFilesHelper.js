({
	doInit : function(component,event) {
		var action = component.get("c.getEstimateFiles");
        
        action.setParams({rfoRiderId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var resp = response.getReturnValue();
            console.log(resp);
             
            var contentDocs = [];
            if(resp){
                for(var i=0;i<resp.length;i++){
                    var contentDoc = {}
                    //contentDoc.link = '/sfc/servlet.shepherd/document/download/'+resp[i].ContentDocumentId+'?operationContext=S1';
                    contentDoc.name = resp[i].ContentDocument.Title;
                    contentDoc.Id = resp[i].ContentDocumentId;
                    contentDoc.LastModifiedDate = resp[i].ContentDocument.LastModifiedDate;
                    contentDoc.icon = 'doctype:pdf';
                    contentDocs.push(contentDoc);
                }
            }
           component.set("v.contentDocs", contentDocs);
        });
        //https://sitb-trinityrail.cs4.force.com/sfc/servlet.shepherd/document/download/069P0000000eMpkIAE?operationContext=S1
        $A.enqueueAction(action);
	},
    
    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    
    handleSort: function(cmp, event) {
        try{
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = cmp.get("v.contentDocs").slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        cmp.set('v.contentDocs', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
        }
        catch(e){
            console.log(e);
        }
    }
})