trigger AssetLineTrigger on Asset_Lines__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
 

   //TriggerDispatcher.Run(new AssetLineTriggerHandler());
    if(trigger.isInsert && trigger.isbefore)
    {
        AssetLineTriggerHandler handler = new AssetLineTriggerHandler();
        handler.run();
    }



}