/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description : This Trigger is used below functionalty.
               //For Chatter Notification US: 34.03.08               
**/

trigger RFO_QuoteTrigger on SBQQ__Quote__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
   TriggerDispatcher.Run(new RFO_QuoteTriggerHandler());
}