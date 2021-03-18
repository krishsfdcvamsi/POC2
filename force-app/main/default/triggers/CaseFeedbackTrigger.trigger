trigger CaseFeedbackTrigger on Case_Feedback__c (before insert,after insert) {
    if(trigger.isBefore && trigger.isInsert)
    {
        CaseFeedbackTriggerHandler.populateAccountTeam(trigger.new);
    }
     if(trigger.isAfter && trigger.isInsert)
    {
        CaseFeedbackTriggerHandler.sendFeedbackEmail(trigger.new);
    }

}