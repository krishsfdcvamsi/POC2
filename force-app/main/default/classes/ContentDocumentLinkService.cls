public  class ContentDocumentLinkService {

    public static Map<id,Id> getContentDocumentIdsByLinkedEntityId(set<Id> linkedEntityIds){
        Map<id,Id> contentDocToLinkedEntityMap = new Map<id,Id>(); 
        for(ContentDocumentLink cdl: [SELECT id,ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId  IN:linkedEntityIds]){
            contentDocToLinkedEntityMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        } 
        return contentDocToLinkedEntityMap;
    }

}