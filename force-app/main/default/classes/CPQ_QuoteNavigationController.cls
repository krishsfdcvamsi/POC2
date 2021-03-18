public without sharing class CPQ_QuoteNavigationController {
    @auraEnabled
    Public Static SBQQ__Quote__c getCPQQuoteInfo(String cpqQuoteId){
        SBQQ__Quote__c objCPQQUote = New SBQQ__Quote__c();
        objCPQQUote =  [SELECT Name,CPQ_Quote__c,Quote_UI__c FROM SBQQ__Quote__c WHERE CPQ_Quote__c=:cpqQuoteId];
        system.debug('objCPQQUote>>>>>>>>'+objCPQQUote);
        objCPQQUote.Quote_UI__c = 'CPQ Quote';
        update objCPQQUote;
        return objCPQQUote;
    }
}