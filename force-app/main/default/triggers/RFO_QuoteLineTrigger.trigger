trigger RFO_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
 

        CPQQuoteLineDispatcher.Run(new RFO_QuoteLineTriggerHandler());

}