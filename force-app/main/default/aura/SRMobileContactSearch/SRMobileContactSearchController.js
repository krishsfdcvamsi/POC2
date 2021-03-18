({
    doInit : function(component, event, helper) {
        if(component.get("v.disableContact")){
            let newContact = component.get("v.newContact");
            
            newContact = newContact ? newContact : {};
            newContact.Last_Name__c = component.get("v.lastName");
            newContact.Email__c = component.get("v.email");
            newContact.Phone__c = component.get("v.phone");
            newContact.Name = component.get("v.firstName");
            component.set("v.newContact", newContact);
        }
        else{
            component.set("v.foundContact", {});
        }
        helper.doInit(component, event);
    },
    
    setContact : function(component, event, helper) {
        
        let newContact = component.get("v.newContact");
        newContact = newContact ? newContact : {};
        if(component.get("v.selectedRecord").Name){
            newContact.Last_Name__c = component.get("v.selectedRecord").Last_Name__c;
            newContact.Email__c = component.get("v.selectedRecord").Email__c;
            newContact.Phone__c = component.get("v.selectedRecord").Phone__c;
            newContact.Name = component.get("v.selectedRecord").Name;
            
            component.set("v.lastName", newContact.Last_Name__c);
            component.set("v.email", newContact.Email__c);
            component.set("v.phone", newContact.Phone__c);
            component.set("v.firstName", newContact.Name);
            component.set("v.newContact", newContact);
            component.set("v.disableContact", true);
            component.set("v.showContact", false);
            component.set("v.showContact", true);
            newContact.Account__c = null;
            helper.validate(component);
        }
        component.set("v.newContact", newContact);
    },
    
    enableContact : function(component, event, helper) {
        component.set("v.disableContact", false);
        component.set("v.newContact", {Account__c : component.get("v.accountId")});
        component.set("v.selectedRecord", {});
        component.set("v.foundContact", {});
        component.set("v.contactsSearch", '');
        component.set("v.showContact", false);
        component.set("v.showContact", true);
        component.set("v.lastName", null);
        component.set("v.email", null);
        component.set("v.phone", null);
        component.set("v.firstName", null);
    },
    
    setNewContact : function(component, event, helper) {
        let newContact = component.get("v.newContact");
        newContact = newContact ? newContact : {};
        component.set("v.lastName", newContact.Last_Name__c);
        component.set("v.email", newContact.Email__c);
        component.set("v.phone", newContact.Phone__c);
        component.set("v.firstName", newContact.Name);
        
    },
    
    validate : function(component, event, helper) {
        helper.validate(component);
    }
    
})