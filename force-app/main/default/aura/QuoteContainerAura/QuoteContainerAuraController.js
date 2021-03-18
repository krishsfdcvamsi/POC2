({
    showPricingScenario : function(component, event, helper) {
        //alert('open ..');
        //
        component.set("v.SpinnerLoaded",true);
        component.set("v.viewPopUp",true);
        let recordIdVal  = component.get("v.recordId");
        var cmpName =  'c:pmReview';
        //alert('aura'+recordIdVal);
        $A.createComponent(
            cmpName,{
                trinityQuoteId:recordIdVal
            },function(cmp){                
                if (component.isValid()) {
                    component.set("v.lwcCMP", cmp);
                    component.set("v.SpinnerLoaded",false);
                }
            });
    },
    handleEventApplication : function(component, event, helper){
        console.log('console....');
        var popup = event.getParam("popup");
        console.log('popup>>>>>>',popup);
    },
    showGapProcess : function(component, event, helper){
        component.set("v.SpinnerLoaded",true);
        component.set("v.viewPopUp",true);
        let recordIdVal  = component.get("v.CPQRecordId");
        //alert('aura'+recordIdVal);
        var cmpName =  'c:gapProcessBaseCmp';
        $A.createComponent(
            cmpName,{
                recordId:recordIdVal
            },function(cmp){                
                if (component.isValid()) {
                    component.set("v.lwcCMP", cmp);
                    component.set("v.SpinnerLoaded",false);
                }
            });
    },
    handleClose : function(component, event, helper){
        //alert('close')
        component.set("v.SpinnerLoaded",false);
		component.set("v.viewPopUp",false);
    },
    handleProductionClick : function(component, event, helper){
        //alert('Production Planinng..');
        component.set("v.SpinnerLoaded",true);
        component.set("v.viewPopUp",true);
        let recordIdVal  = component.get("v.recordId");
        //alert('aura'+recordIdVal);
        var cmpName =  'c:SLAReport';
        $A.createComponent(
            cmpName,{
                recordId:recordIdVal
            },function(cmp){                
                if (component.isValid()) {
                    component.set("v.lwcCMP", cmp);
                    component.set("v.SpinnerLoaded",false);
                }
            });
    },
    handleDetails : function(component, event, helper){
        component.set("v.detailsPopUp",true);
        //component.set("v.recordId",component.get("v.recordId"));
        //component.set("v.detailsPopUp",true);
        /*
        component.set("v.viewPopUp",true);
        let recordId = component.get("v.recordId");
        var cmpName =  'c:lwcCreateNewRecord';
        $A.createComponent(
            cmpName,
            {},
            function(cmp){                
                if (component.isValid()) {
                    component.set("v.lwcCMP", cmp);
                    component.set("v.SpinnerLoaded",false);
                }
            });
            /*
        let recordId = component.get("v.recordId");
          var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                 "recordId": recordId
           });
           editRecordEvent.fire();
           */
    },
    handleDetailsClose : function(component, event, helper){
        //alert('close details Page..');
        component.set("v.detailsPopUp",false);
    },
    doInit : function(component, event, helper){
        helper.doInit(component, event, helper);
        component.set("v.SpinnerLoaded",false);
    },
    handleRelatedList : function(component, event, helper){
        window.open('/lightning/o/SBQQ__ProductOption__c/home','_blank');
        /*
        console.log('handleRelatedList>>>>>');
        var urlEvent = $A.get("e.force:navigateToURL");
    	urlEvent.setParams({
      		"url": "lightning/o/SBQQ__ProductOption__c/home"
    	});
    	urlEvent.fire();
        */
        /*
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
    relatedListEvent.setParams({
        "relatedListId": "Cases",
        "parentRecordId": component.get("v.recordId")
    });
    relatedListEvent.fire();
        let recordId = component.get("v.CPQRecordId");
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "SBQQ__Quote__c",
            "parentRecordId": recordId
        });
        relatedListEvent.fire();
        */
    },
    handleAssetMatchingClick : function(component, event, helper){
        component.set("v.SpinnerLoaded",true);
        component.set("v.viewPopUp",true);
        let recordIdVal  = component.get("v.CPQRecordId");
        var cmpName =  'c:gapProcessSelectedCars';
        //alert('aura'+recordIdVal);
        $A.createComponent(
            cmpName,{
                recordId:recordIdVal
            },function(cmp){                
                if (component.isValid()) {
                    component.set("v.lwcCMP", cmp);
                    component.set("v.SpinnerLoaded",false);
                }
            });
    },
    handleReportClick:function(component, event, helper){
     //reportId
        helper.handleReportClick(component, event, helper);   
    }
})