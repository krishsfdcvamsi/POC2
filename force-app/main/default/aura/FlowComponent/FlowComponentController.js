({
	init : function(component, event, helper) {
		 var flow = component.find("flowId");
        	flow.startFlow("Incident");
	},
    
   handleStatusChange : function (component, event) {
		//alert(event.getParam("status"));
      // console.log(event);
   		if(event.getParam("status") === "FINISHED") {
    		$A.get("event.force:closeQuickAction").fire();
    		
		}
 	} 

})