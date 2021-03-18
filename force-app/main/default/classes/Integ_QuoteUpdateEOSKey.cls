global class Integ_QuoteUpdateEOSKey implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.stateful{
	global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select Id, SBQQ__Key__c from SBQQ__Quote__C where SBQQ__Key__c!=null limit 10000');
    }
    global void execute(Database.BatchableContext bc,  List<SBQQ__Quote__c> quoteList){
        for (SBQQ__Quote__C quote : quoteList){
    		quote.RFO_EOS_Key__c = quote.SBQQ__Key__C;
    		quote.SBQQ__Key__C=null;
		}
		update quoteList;
		system.debug(quoteList.size());
    }
    global void finish(Database.BatchableContext bc){
        
    }   
}