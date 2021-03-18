trigger AssetGroupTrigger on Asset_Group__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(trigger.isInsert && trigger.isbefore)
    {
        AssetGroupTriggerHandler handler = new AssetGroupTriggerHandler();
        handler.beforeInsert(Trigger.New);
    }

}