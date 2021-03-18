({
	doInit : function(component, event, helper) {
        try{
		helper.doInit(component, event);
        }
        catch(e){
            console.log(e);
        }
	},
    
    //Pass parameters of the Bulletin Board record to redirect
    callBBRedirectComp : function(component, event, helper){
        var evtTarget = event.target;
        var bbId = evtTarget.getAttribute("data-Id");
        var bbURL = evtTarget.getAttribute("data-URL");
        
        var bbRedirectComponent = component.find("Bulletin_Board_Redirect");
  		bbRedirectComponent.redirectMethod(bbId, bbURL);
	}
})