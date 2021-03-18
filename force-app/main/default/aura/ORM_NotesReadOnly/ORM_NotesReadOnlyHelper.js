({
	createObjectData: function(component, event) {
        var RowItemList = component.get("v.ormVar.actionItemList");
        RowItemList.push({
            'sobjectType': 'Action_Item__c',
            'Description__c': '',
            'Change_Analysis__c': false,
            'Responsible_Party__c': '',
            'Due_Date__c':null,
            'Status__c':'Not Sent'
        });
        component.set("v.ormVar.actionItemList", RowItemList);
    },
    updateNotes: function(component, event, isEmail) {
		component.set("v.Spinner", true);
		var action = component.get("c.updateORM");
		var ormData = component.get("v.ormVar");
		ormData.orm.World_Petroleum_Corp_Contacts__c = component.get("v.contactList").toString();
		ormData.orm.Trinity_Rail_Users__c = component.get("v.userList").toString();
		delete ormData.orm.Portfolio_Management__r;
        delete ormData.orm.Prepared_By_User__r;
        delete ormData.orm.Revised_By__r;
        var i;
        for(i=0;i<ormData.actionItemList.length; i++){
            delete ormData.actionItemList[i].Responsible_Party__r;
        }
        for(i=0;i<ormData.ORMTasks.length; i++){
            delete ormData.ORMTasks[i].Owner;
        }
        action.setParams({
			"ormJSON": JSON.stringify(ormData),
            "enableEmail" : isEmail
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") { 
				component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                var msg;
                if(isEmail) {
                	msg = 'ORM Notes has been updated and email sent successfully.';
                }
                else {
                    msg = 'ORM Notes has been updated successfully.';
                }
                toastEvent.setParams({
                    "title": "Success!",
                    "message": msg,
                    "type": "success"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
			}
		});
		$A.enqueueAction(action);
    },
})