trigger RFO_AssetTrigger on Asset (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    TriggerDispatcher.Run(new RFO_AssetTriggerHandler());
}