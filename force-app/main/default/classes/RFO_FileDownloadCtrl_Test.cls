@isTest
public class RFO_FileDownloadCtrl_Test {
    @testsetup
    static void testdata(){
        ContentWorkspace c = new ContentWorkspace ();
		c.DeveloperName = 'test321';
		c.name='test321';
		Insert c;
    }
    static testMethod void testFileDownload(){
        
        
        ContentVersion CV = new ContentVersion();
        CV.Title = 'Test';
        CV.VersionData = Blob.valueOf('Test Content');
        CV.PathOnClient = 'test.txt';
        CV.Trinity_File_Type__c = 'Other';
        insert CV;
        
        ID CD = [Select ContentDocumentID from ContentVersion where id =:CV.Id].ContentDocumentID;
        ID c = [select id from ContentWorkSpace where name = 'test321' limit 1].id;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.ContentDocumentId = cd;
        cdl.LinkedEntityId = c;
        insert cdl;
        
        RFO_FileDownloadCtrl.getAllFiles(10);
    }
}