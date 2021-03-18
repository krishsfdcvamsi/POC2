public class RiderContractFilesController {
    
    @AuraEnabled
    public static List<ContentDocumentLink> getFileIds(Id rfoRiderId){
        Id contractId = [SELECT RFO_Contract__c FROM RFO_Rider__c WHERE Id = :rfoRiderId].RFO_Contract__c;
        List<ContentDocumentLink> contentDocs = [SELECT Id,ContentDocumentId,LinkedEntityId,ContentDocument.Title 
                                                 FROM ContentDocumentLink WHERE Visibility= 'AllUsers'
                                                 AND (LinkedEntityId=: contractId OR LinkedEntityId =: rfoRiderId) ORDER BY ContentDocument.Title ASC];
        return contentDocs;
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> getEstimateFiles(Id rfoRiderId){
        Id estimateId = [SELECT Id FROM CDX_Estimate__c WHERE Id = :rfoRiderId].Id;
        List<ContentDocumentLink> contentDocs = [SELECT Id,ContentDocumentId,LinkedEntityId,ContentDocument.Title ,
                                                 ContentDocument.LastModifiedDate
                                                 FROM ContentDocumentLink WHERE Visibility= 'AllUsers'
                                                 AND (LinkedEntityId=: estimateId OR LinkedEntityId =: rfoRiderId) ORDER BY ContentDocument.Title ASC];
        return contentDocs;
    }
}