({
	doInit : function(component,event,helper) {

        //alert(component.get("v.recordId"));
		//helper.createObjectData(component, event);
	},
	
	displayInfo : function(component,event,helper) {
		component.set("v.Spinner", true);
		var ormType = component.get("v.ormType");
		if(ormType == 'Internal ORM') {
			component.set("v.isInternal",true);
		}
		else if(ormType == 'External ORM'){
			component.set("v.isInternal",false);
		}
        component.set("v.contactList",[]);
        component.set("v.userList",[]);
		if(ormType == 'Internal ORM' || ormType == 'External ORM') {
			
			var action = component.get("c.getORMData");
			action.setParams({
				"recordId" : component.get("v.recordId"),
				"type" : component.get("v.ormType")
			});
			action.setCallback(this,function(response) {
				if (response.getState() === "SUCCESS") {
                    var responseVal =  response.getReturnValue();
                    component.set("v.options",responseVal.fileList);
                    component.set("v.serviceType",responseVal.serviceType);
                    component.set("v.selectedAssetFileNumber",responseVal.orm.selectedAssetFileNumber);
                    component.set("v.selectedServiceType",responseVal.orm.Service_Type__c);
                    //component.set("v.newAssetFileNumber",responseVal.orm.File_Number_Txt__c);
                    //console.log("selected File Number :"+responseVal.orm.File_Number_Txt__c);
                    //console.log("selectedAssetFileNumber " +component.get("v.selectedAssetFileNumber"));
                    //alert(component.get("v.options"));
					if(responseVal.orm.World_Petroleum_Corp_Contacts__c != undefined) {
						component.set("v.contactList",responseVal.orm.World_Petroleum_Corp_Contacts__c.split(','));
                        console.log("Contact List :"+component.get("v.contactList"));
                        console.log("response contact list :"+responseVal.orm.World_Petroleum_Corp_Contacts__c.split(','));
                        
                    }
                    if(responseVal.orm.Trinity_Rail_Users__c != undefined) {
                    	component.set("v.userList",responseVal.orm.Trinity_Rail_Users__c.split(','));
                    }
					component.set("v.ormVar",responseVal);
					component.set("v.isChanged",true);
                    component.set("v.enableMultiSelect",true);
                    component.set("v.enableCustomLookup",true);
					if(responseVal.actionItemList == undefined || responseVal.actionItemList == '') {
						helper.createObjectData(component, event);
					}
                    if(responseVal.ORMTasks == undefined || responseVal.ORMTasks == '') {
						helper.createObjectDataTask(component, event);
					}
				}
				else if (response.getState() === "ERROR") { 
					var errors = response.getError();
					alert(JSON.stringify(response.getError()));
				}
				component.set("v.Spinner", false);
			});
			$A.enqueueAction(action);
		}
	},
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    addNewRowTask: function(component, event, helper) {
        helper.createObjectDataTask(component, event);
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");   
        var AllRowsList = component.get("v.ormVar.actionItemList");
        AllRowsList.splice(index, 1);
        component.set("v.ormVar.actionItemList", AllRowsList);
    },
    removeDeletedRowTask: function(component, event, helper) {
        var index = event.getParam("indexVar");   
        var AllRowsList = component.get("v.ormVar.ORMTasks");
        AllRowsList.splice(index, 1);
        component.set("v.ormVar.ORMTasks", AllRowsList);
    },
    ormUpdate: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
	
        helper.updateNotes(component,event,false, false);
    },
    saveAndSend: function(component, event, helper) {
		helper.updateNotes(component,event,false, true);
        
    },
	typeSelection : function(component) {
		component.set("v.isChanged",false);
	},
	closeModal : function(component,event) {
		//$A.get("e.force:closeQuickAction").fire();
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
	}
})