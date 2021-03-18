public class CDX_FileUploadController { 
    @AuraEnabled  
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get('Other').getRecordTypeId();
        ContentVersion contentVersion = new ContentVersion(
            versionData = EncodingUtil.base64Decode(base64Data),       
            title = fileName,
            pathOnClient =  '/' + fileName,
            FirstPublishLocationId = parentId,
            Trinity_File_Type__c = 'OTMA',
            recordTypeId = recordTypeId);
            insert contentVersion; 
            return contentVersion.Id;      
        
        
    }
    
    @AuraEnabled
  
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
      @TestVisible
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion contentVersion = [
            SELECT Id, versionData
            FROM ContentVersion
            WHERE Id = :fileId
        ];
        String existingBody = EncodingUtil.base64Encode(contentVersion.versionData);
        contentVersion.versionData = EncodingUtil.base64Decode(existingBody + base64Data); 
        update contentVersion;   
    }
}