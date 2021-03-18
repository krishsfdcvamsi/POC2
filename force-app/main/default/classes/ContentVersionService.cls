public  class ContentVersionService {
    public static Map<Id, ContentVersion>  getContentversionIdByFileType(Set<Id> contentDocumentIds, String fileType){
        Map<Id, ContentVersion> linkedEntityToContentDocMap =  new Map<ID, ContentVersion>( [select id, contentDocumentId from ContentVersion where contentDocumentId in: contentDocumentIds and Trinity_File_Type__c  =:fileType]);
        return linkedEntityToContentDocMap;
    }
}