global class RFO_QuoteRenewalEffSetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
	global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select Id,Name,RFO_QuoteStage__c,RFO_RenewalDate__c,recordtype.developerName from SBQQ__Quote__C where RFO_QuoteStage__c NOT IN (\'HPR Fully Executed\',\'PM Reviewed\',\'Signed HPR Received\') and recordtype.developerName=\'RFO_Renewal\' and RFO_RenewalDate__c!=null and RFO_RenewalDate__c=TODAY');
    }
    global void execute(Database.BatchableContext bc,  List<SBQQ__Quote__C> quoteList){
        for(SBQQ__Quote__C quote : quoteList){
            Date d = quote.RFO_RenewalDate__c;
			Date nextMonthDateFromToday = d.AddMonths(1);
			System.debug(nextMonthDateFromToday);
			Date nextMonthFirstDate =  date.valueof(nextMonthDateFromToday).toStartOfMonth();
			system.debug(nextMonthFirstDate);
            quote.RFO_RenewalDate__c = nextMonthFirstDate;
        }
        if(quoteList.size()>0){
        	update quoteList;
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }   
}