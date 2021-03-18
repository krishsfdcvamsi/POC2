public without sharing class QuoteConfigButtonController {
    @auraEnabled
    Public Static SBQQ__Quote__c getQuoteUIDetails(String QuoteId){
        return [SELECT id,Quote_UI__c FROM SBQQ__Quote__c WHERE Id=:QuoteId LIMIT 1];
    }
	@auraEnabled
    Public Static void configButton(String QuoteId){
        system.debug('QuoteId>>>>>>'+QuoteId);
        List<SBQQ__Quote__c> lstQuotes = New List<SBQQ__Quote__c>();
        SBQQ__Quote__c objQuote = [SELECT id,Quote_UI__c,CPQ_Quote__c,CPQ_Quote__r.CPQ_Quote_Opened__c FROM SBQQ__Quote__c WHERE Id=:QuoteId LIMIT 1];
        if(objQuote.CPQ_Quote__r.CPQ_Quote_Opened__c !='Yes'){
            SBQQ__Quote__c cpqQuote 			= New SBQQ__Quote__c();
        	cpqQuote.Id 						= objQuote.CPQ_Quote__c;
        	cpqQuote.CPQ_Quote_Opened__c 		= 'Yes';
            lstQuotes.add(cpqQuote);
        }
        
        
        if(String.isEmpty(objQuote.Quote_UI__c) || String.isBlank(objQuote.Quote_UI__c)){
            objQuote.Quote_UI__c  = 'CPQ Quote';
        }else if(objQuote.Quote_UI__c == 'Trinity Quote'){
            objQuote.Quote_UI__c  = 'CPQ Quote';
        }else if(objQuote.Quote_UI__c == 'CPQ Quote'){
            objQuote.Quote_UI__c  = 'Trinity Quote';
        }
        system.debug('objQuote>>>>>'+objQuote);
        lstQuotes.add(objQuote);
        update lstQuotes;
        //QuoteConfigButtonController
    }
}