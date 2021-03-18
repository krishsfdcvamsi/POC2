/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 27 Sep 2019
* @Description : This trigger is to create records on ProductEntryObject for New Products.
*                
**/
trigger RFO_Product2Trigger on Product2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    If(Trigger.isAfter && Trigger.isInsert){
        TriggerDispatcher.Run(new RFO_Product2TriggerHandler());
    }
}