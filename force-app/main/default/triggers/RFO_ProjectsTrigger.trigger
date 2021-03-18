trigger RFO_ProjectsTrigger on RFO_Projects__c (before insert,after insert,before update,after update,before delete, after delete) 
{
    RFO_ProjectsTriggerHandler handler = new RFO_ProjectsTriggerHandler();
    
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('>>>>>trigger isbeforeinsert');
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        System.debug('>>>>>trigger isafterinsert');
        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
    } 
     
    else if(Trigger.isUpdate && Trigger.isBefore){  
        
        System.debug('trigger beforeupdate');
        handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        RFO_ProjectsTriggerHandler.stopAlertEngineers(Trigger.new); // Alpha-588
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        RFO_ProjectsTriggerHandler.alertEngineers(Trigger.new,Trigger.oldMap); // Alpha-587
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
}