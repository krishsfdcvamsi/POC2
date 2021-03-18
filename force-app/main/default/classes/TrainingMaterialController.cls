public without sharing class TrainingMaterialController {
    
    public class Material{
        @AuraEnabled
        public Id folderOrFileId;
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public DateTime lastModifiedDate;
        
        @AuraEnabled
        public Boolean isFile;
        
        @AuraEnabled
        public String fileExtension;
        
        @AuraEnabled
        public Id parentFolderId;
    }
    
    @AuraEnabled
    public static List <ContentVersion> getTrainingMaterials(){
        Id workspaceId;
        if(Test.isRunningTest())
            workspaceId = [SELECT Id,RootContentFolderId FROM ContentWorkspace WHERE Name LIKE '%Test%' LIMIT 1][0].Id;
        else
        	workspaceId = [SELECT Id,RootContentFolderId FROM ContentWorkspace WHERE Name = 'Training Documents'][0].Id;
        List <ContentVersion> allDocuments = [SELECT Id,Title,ContentDocumentId,LastModifiedDate  FROM ContentVersion WHERE ContentDocument.ParentId = :workspaceId];
        return allDocuments;
    }
    
    @AuraEnabled
    public static List<Material> getTrainingFilesAndFolders(){
        List<Material> materials = new List<Material>();
        return getTrainigFolders();
    }
    
    
    public static List<Material> getTrainigFolders(){
        List<Material> materials = new List<Material>();
        Id rootFolderId ;
        if(Test.isRunningTest())
            rootFolderId = [SELECT Id,RootContentFolderId FROM ContentWorkspace WHERE 
                           Name LIKE '%Test%' LIMIT 1][0].RootContentFolderId;
        else
         rootFolderId = [SELECT Id,RootContentFolderId FROM ContentWorkspace WHERE Name = 'Training Documents'][0].RootContentFolderId;
        System.debug(rootFolderId);
        List<ContentFolder> folderList = [SELECT Id,Name,ParentContentFolder.Name,ParentContentFolderId,LastModifiedDate FROM ContentFolder WHERE ParentContentFolderId =: rootFolderId];
        for(ContentFolder cf : folderList){
            Material material = new Material();
            material.folderOrFileId = cf.Id;
            material.name = cf.Name;
            material.LastModifiedDate = cf.LastModifiedDate;
            material.isFile = false;
            material.parentFolderId = rootFolderId;
           // materials.add(material);
        }
        materials.addAll(getFilesByFolder(rootFolderId));
        return materials;
    }
    
    @AuraEnabled
    public static List <Material> getFilesByFolder(Id parentContentFolderId){
        List<ContentFolderMember> cfmList = [SELECT Id,ChildRecordId FROM ContentFolderMember WHERE
                                             ParentContentFolderId =: parentContentFolderId];
        List<ContentFolder> folderList = [SELECT Id,Name,ParentContentFolder.Name,ParentContentFolderId,
                                          LastModifiedDate FROM ContentFolder WHERE
                                          ParentContentFolderId =: parentContentFolderId];
        List<Material> materials = new List<Material>();
        for(ContentFolder cf : folderList){
            Material material = new Material();
            material.folderOrFileId = cf.Id;
            material.name = cf.Name;
            material.LastModifiedDate = cf.LastModifiedDate;
            material.isFile = false;
            material.parentFolderId = parentContentFolderId;
            materials.add(material);
        }
        List<Id> contentDocIds = new List<Id>();
        for(ContentFolderMember cfm : cfmList){
            contentDocIds.add(cfm.ChildRecordId);
        }
        
        List <ContentVersion> docsByFolder = [SELECT Id,Title,ContentDocumentId,LastModifiedDate,FileExtension  FROM ContentVersion 
                                              WHERE ContentDocumentId IN: contentDocIds];
        
        for(ContentVersion cv : docsByFolder){
            Material material = new Material();
            material.folderOrFileId = cv.ContentDocumentId;
            material.name = cv.Title;
            material.LastModifiedDate = cv.LastModifiedDate;
            material.isFile = true;
            material.fileExtension = cv.FileExtension;
            material.parentFolderId = parentContentFolderId;
            materials.add(material);
        }
        return materials;
    }
    
     @AuraEnabled
    public static List <ContentDocument> getMyDocuments(){
        return [SELECT Id,Title,LastModifiedDate,FileExtension From ContentDocument WHERE OwnerId =: Userinfo.getUserId()];
    }
}