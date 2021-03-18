({       
   navigateToBBRecord : function (component, event, helper) {
       var args = event.getParam("arguments");
       
       //Navigate to get Bulletin Board record reference to write to event log
       var sObjectEvent = $A.get("e.force:navigateToSObject"); 
        sObjectEvent .setParams({
            "recordId":  args.bbId,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
       
	   	//Redirect back to Home page	
        //window.parent.location = "/one/one.app#/Bulletin_Board__c/" + args.bbId + "/view";   
         if(!args.bbURL.includes(window.location.hostname)) {
       		//Redirect back to Home page for external links	
       		window.parent.location = "/one/one.app#/Bulletin_Board__c/" + args.bbId + "/view";
        }  
      
       //Redirect to URL Link from Bulletin Board record
       var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": args.bbURL,
            "isredirect": false
    	});
    	urlEvent.fire();
    }
})