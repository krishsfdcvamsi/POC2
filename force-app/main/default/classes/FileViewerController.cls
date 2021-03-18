/************************************************************************************
Name: FileViewerController
(c) 2020 Salesforce.com.

Purpose: Class to populate the fileID list to be used on LWC based on the recordId

History
-------
S-XXXXXX 30 March 2020        Tina Wilburn    Original

*************************************************************************************/

public with sharing class FileViewerController {
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs - Contract ID
        Map<ID, RFO_Rider__c> riderRecords = new Map<ID, RFO_Rider__c>(
            [SELECT RFO_Contract__c FROM RFO_Rider__c WHERE Id = :recordId LIMIT 1]
        );  
        //ID contractRecordId = recordId;
        List<RFO_Rider__c> contractRecordId = new List<RFO_Rider__c>();
        contractRecordId = riderRecords.values();
        system.debug('Rider Records: ' + contractRecordId[0].RFO_Contract__c);
        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :contractRecordId[0].RFO_Contract__c];
        system.debug('Files: ' + files);
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        // Filter PDF files 
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
        //    FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND FileExtension='pdf'];
        // All files
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }

        return mapIdTitle;
    }
}