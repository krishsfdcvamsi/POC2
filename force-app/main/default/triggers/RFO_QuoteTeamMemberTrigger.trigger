/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 
* @Description : This Trigger is used to call quote team trigger actions.
                           
**/
trigger RFO_QuoteTeamMemberTrigger on Quote_Team_Member__c(before insert, before update, before delete, after insert, after update, after delete, after undelete){
   TriggerDispatcher.Run(new RFO_QuoteTeamMemberTriggerHandler());
}