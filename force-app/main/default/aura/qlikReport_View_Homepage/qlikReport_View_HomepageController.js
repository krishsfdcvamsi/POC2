({
	myAction : function(component, event, helper) {
		
	},
    handleApplicationEvent : function(cmp, event) {
        var urlString = event.getParam("urlString");
 		var headerString = event.getParam("headerString");
        
        // set the handler attributes based on event data
        cmp.set("v.headerString", headerString);
        cmp.set("v.urlString", urlString);
    },
})