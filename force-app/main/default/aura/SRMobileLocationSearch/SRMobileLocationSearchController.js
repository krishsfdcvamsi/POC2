({
    doInit : function(component, event, helper) {
        helper.doInit(component, event);
    },
    setAddress : function(component, event, helper) {
        
        let newAddress = component.get("v.newAddress");
        newAddress = newAddress ? newAddress : {};

            if(component.get("v.selectedRecord").Name){
                newAddress.City__c = component.get("v.selectedRecord").City__c;
                newAddress.State__c = component.get("v.selectedRecord").State__c;
                newAddress.Country__c = component.get("v.selectedRecord").Country__c;
                newAddress.ZipCode__c  = component.get("v.selectedRecord").ZipCode__c;
                newAddress.Name = component.get("v.selectedRecord").Name;

                component.set("v.City", newAddress.City__c);
                component.set("v.State", newAddress.State__c);
                component.set("v.country", newAddress.Country__c);
                component.set("v.zipCode", newAddress.ZipCode__c);
                component.set("v.street", newAddress.Name);
                
                
                component.set("v.disableAddress", true);
                component.set("v.showAddress", false);
                component.set("v.showAddress", true);
                newAddress.Account__c = null;
                helper.validate(component);
            }
            component.set("v.newAddress", newAddress);
        
    },
    
    enableAdress : function(component, event, helper) {
        component.set("v.disableAddress", false);
        component.set("v.newAddress", {Account__c : component.get("v.accountId")});
        component.set("v.selectedRecord", {});
        component.set("v.addressSearch", null);
        component.set("v.showAddress", false);
        component.set("v.showAddress", true);
        
        component.set("v.City", null);
        component.set("v.State", null);
        component.set("v.country", null);
        component.set("v.zipCode", null);
        component.set("v.street", null);
    },

    setNewAddress : function(component, event, helper) {
        let newAddress = component.get("v.newAddress");
        newAddress = newAddress ? newAddress : {};
        component.set("v.City", newAddress.City__c);
        component.set("v.State", newAddress.State__c);
        component.set("v.country", newAddress.Country__c);
        component.set("v.zipCode", newAddress.ZipCode__c);
        component.set("v.street", newAddress.Name);
    },
    
    validate : function(component, event, helper) {
        helper.validate(component);
    }
    
})