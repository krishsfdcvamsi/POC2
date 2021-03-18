@isTest
public class CDX_FileUploadControllerTest
{
    @isTest static void FileUploadControllerTest()
    {
         Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CDX Customer - Super User' LIMIT 1];
        
        
          User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = 'jason.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
       
        contact con = new contact();
        con.AccountId = acct.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact 123';
        con.Email = 'abc@test.com';
        con.CDX_Project_Notification_Preference__c = True;
        insert con;
         Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
            .get('Other').getRecordTypeId();
         Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
         ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob; 
        cv.FirstPublishLocationId =acct.id;
            cv.Trinity_File_Type__c = 'OTMA';
            cv.recordTypeId = recordTypeId;
        cv.SharingPrivacy='N';
        insert cv;     
       System.debug('cv'+cv);
         // ContentDocumentLink contentlink=new ContentDocumentLink();
           //  insert contentlink;
        //System.runAs(usr)
       // {
        CDX_FileUploadController.saveTheFile(acct.Id, 'Penguins', 'Test Content', '/jpg');
        CDX_FileUploadController.saveTheChunk(acct.Id, 'Penguins1', 'Test Content2','/jpg','');
        CDX_FileUploadController.appendToFile(cv.Id,'Test Content3');
       // }
    }
    
}