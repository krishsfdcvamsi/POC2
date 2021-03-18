@isTest
public class ShareInvoiceFilesBatchTest {
    
    @isTest
    public static void shareInvoiceFilesBatch(){
        Account account = new Account(Name = 'Test');
        insert account;
        
        CDX_Invoice__c invoice = new CDX_Invoice__c(Name = 'test',CDX_Account__c=account.Id);
        insert invoice;
        
        ContentDocumentLinkHandler.isInvoiceFileShared = true;
        ContentVersion cv = new ContentVersion();
        cv.FirstPublishLocationId = invoice.Id;
        cv.Title = 'Test';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.SharingPrivacy = 'N';
        cv.Trinity_File_Type__c = 'Car Specification';
        insert cv;
        
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        
        Test.startTest();
        Database.executeBatch(new ShareInvoiceFilesBatch());
        Test.stopTest();
        
    }
}