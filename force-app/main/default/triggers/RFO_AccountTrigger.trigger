trigger RFO_AccountTrigger on Account (before update,after insert, after update) {
    
    //Execute trigger only if RFO_TriggeSetting__mdt CMD of account is enabled
    RFO_TriggerSetting__mdt accountTrigger = [Select id,RFO_Active__c from RFO_TriggerSetting__mdt where MasterLabel='AccountTrigger'];    
    if(accountTrigger.RFO_Active__c) {        
        if(trigger.isBefore && trigger.isUpdate && RFO_AccountTriggerHandler.isRecurrsiveBefore==false){
            RFO_AccountTriggerHandler.beforeUpdate(Trigger.newMap,Trigger.oldMap); 
            RFO_AccountTriggerHandler.handleBeforeUpdateOwner(Trigger.new,Trigger.oldMap);
        }
        
        if(trigger.isAfter && trigger.isInsert && RFO_AccountTriggerHandler.isRecurrsiveAfter == false){
            RFO_AccountTriggerHandler.accountUpdate(trigger.New);
        }        
        if(trigger.isAfter && trigger.isUpdate && RFO_AccountTriggerHandler.isRecurrsiveAfter == false){                        
            RFO_AccountTriggerHandler.sendAccountInfoToTAS(trigger.NewMap, trigger.oldMap);
            RFO_AccountTriggerHandler.updateaccountRecordTypeinCase(Trigger.old,Trigger.new);




            RFO_AccountTriggerHandler.afterUpdate(Trigger.new,trigger.oldMap);  //Changes by MA ALPHA-33



        }   
        
        if(Trigger.isBefore) {
            RFO_AccountTriggerHandler.isRecurrsiveBefore = true;
        }
        if(Trigger.isAfter) {
            RFO_AccountTriggerHandler.isRecurrsiveAfter = true;
        }
        
    }
}