public with sharing class PathController {
    @auraEnabled
    Public Static SBQQ__Quote__c getQuoteStatus(String recordId){
        SBQQ__Quote__c objQuote = [SELECT CPQ_Quote__c  FROM SBQQ__Quote__c  WHERE Id=:recordId LIMIT 1];
        return objQuote;
    }

}