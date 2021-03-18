({
	myAction : function(component, event, helper) {
		
	},
    handleOpenCases : function(cmp, event) {        
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "OC","headerString" : "Open Cases"});
        appEvent.fire();
    },
    handleTotalOpenTask : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "TOT","headerString" : "Total Open Tasks"});
        appEvent.fire();
    },
     handleEstimated : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "EAA","headerString" : "Estimates Awaiting Approval"});
        appEvent.fire();
    },
     handleAwaiting : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "AD","headerString" : "Awaiting Dispo"});
        appEvent.fire();
    },
     handleSRWaiting : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "SWR","headerString" : "SR's waiting Response"});
        appEvent.fire();
    },
     handleProject : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "PASA","headerString" : "Projects Awaiting Schedule Approval"});
        appEvent.fire();
    },
     handleCustomer : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "AWS","headerString" : "Awaiting Customer service"});
        appEvent.fire();
    },
     handleFCR : function(component, event, helper) {
        var appEvent = $A.get("e.c:passQlikURL_evnt");
        appEvent.setParams({"urlString" : "FCR","headerString" : "First call resolution"});
        appEvent.fire();
    },
})