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
                    //alert(component.get("v.options"));
					if(responseVal.orm.World_Petroleum_Corp_Contacts__c != undefined) {
						component.set("v.contactList",responseVal.orm.World_Petroleum_Corp_Contacts__c.split(','));
                        console.log("Contact List :"+component.get("v.contactList"));
                        console.log("response contact list :"+responseVal.orm.World_Petroleum_Corp_Contacts__c.split(','));
                    }
                    if(responseVal.orm.Trinity_Rail_Users__c != undefined) {
                    	component.set("v.userList",responseVal.orm.Trinity_Rail_Users__c.split(','));
                        console.log("User List :"+component.get("v.userList"));
                        console.log("response contact list :"+responseVal.orm.Trinity_Rail_Users__c.split(','));
                    }
					component.set("v.ormVar",responseVal);
					component.set("v.isChanged",true);
					if(responseVal.actionItemList == undefined || responseVal.actionItemList == '') {
						helper.createObjectData(component, event);
					}
				}
				else if (response.getState() === "ERROR") { 
					var errors = response.getError();
					alert(JSON.stringify(response.getError()));
				}
				component.set("v.Spinner", false);
                
            
                component.set("v.enableMultiSelect",true);
			});
			$A.enqueueAction(action);
		}
	},
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");   
        var AllRowsList = component.get("v.ormVar.actionItemList");
        AllRowsList.splice(index, 1);
        component.set("v.ormVar.actionItemList", AllRowsList);
    },
    ormUpdate: function(component, event, helper) {
        helper.updateNotes(component,event,false);
    },
    saveAndSend: function(component, event, helper) {
		helper.updateNotes(component,event,true);
    },
	typeSelection : function(component) {
		component.set("v.isChanged",false);
	},
	closeModal : function(component,event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        navEvt.fire();
	},
    print : function(component) {
		window.print();
	}
})