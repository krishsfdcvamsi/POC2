public class RFO_FileDownloadCtrl {
    
    public class Doc {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public DateTime fileDate;
        @AuraEnabled
        public String fileId;
        @AuraEnabled
        public String fileType;
        @AuraEnabled
        public String fileurl;
        @AuraEnabled
        public String DownloadURL;
        @AuraEnabled
        public String viewFile;
        @AuraEnabled
        public String iconName;
    } 
    
    @AuraEnabled
    public static List<Doc> getAllFiles(Integer intLimit) { 
        String FolderName;
        String FolderId;
        List<Doc> vDocs = new List<Doc>();
        List<Id> lstIds = new List<Id>();
        String InstName = [select InstanceName from Organization limit 1].InstanceName;
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
		String replacement = '--c.'+InstName+'.content.force.com/sfc/servlet.shepherd/document/download';
        String DownloadURL = sfdcBaseURL.replace('.my.salesforce.com', replacement);
        if(!Test.isRunningTest()){
        	FolderName = Label.Library_Folder_Download;
        	FolderId = [select id,name from contentWorkSpace where name =: FolderName].Id;
        }
        else{
            FolderName = 'test321';
        	FolderId = [select id,name from contentWorkSpace where name =: FolderName].Id;
        }
        for(ContentDocument objConDoc : [SELECT Id from ContentDocument where ParentId =: FolderId]){
            lstIds.add(objConDoc.Id);
        }
       
        //List<ContentDocumentLink> lstContDoc = [SELECT Id, ContentDocument.Title,  ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink where ContentDocumentId IN: lstIds];
        List<ContentDocumentLink> lstContDoc = [SELECT Id, ContentDocument.Title,  ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink 
                                                where linkedEntityid =: FolderId ORDER BY ContentDocument.createdDate DESC limit : intLimit ];
        if(lstContDoc != null){
           for(ContentDocumentLink objContDoc : lstContDoc){
               Doc vDoc = new Doc();
               vDoc.fileId = objContDoc.ContentDocumentId;
               vDoc.viewFile = '/'+objContDoc.ContentDocumentId;
               vDoc.name = objContDoc.ContentDocument.Title;
               vDoc.fileType = objContDoc.ContentDocument.FileType;
               vDoc.fileDate = objContDoc.ContentDocument.CreatedDate;
               vDoc.fileurl = '/sfc/servlet.shepherd/document/download/' + objContDoc.ContentDocumentId;
               vDoc.iconName = 'Doctype:unknown';
               switch on objContDoc.ContentDocument.FileType {
                   when 'PDF' {
                       vDoc.iconName = 'doctype:pdf';
                   }
                   when 'EXCEL' {
                       vDoc.iconName = 'doctype:excel';
                   }
                   when 'EXCEL_X' {
                       vDoc.iconName = 'doctype:excel';
                   }
                   when 'JPG' {
                       vDoc.iconName = 'doctype:image';
                   }
                   when 'TEXT' {
                       vDoc.iconName = 'doctype:txt';
                   }
                   when else {
                       vDoc.iconName = 'doctype:unknown';
                   }
                }
               vDocs.add(vDoc);
            }
            if(vDocs.size()>0)
            	vDocs[0].DownloadURL = DownloadURL;
        }
        return vDocs;
    }
}