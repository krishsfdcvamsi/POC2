@isTest
public class CDX_TestDataFactory_Test {

    static testMethod void testContentVersion()
    {
       
        ContentVersion contentVersionInsert1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            Trinity_File_Type__c ='SDS',
            SharingPrivacy='N'
            
        );
         insert contentVersionInsert1;
        system.debug('contentVersionInsert1'+contentVersionInsert1);
         Test.startTest();
        CDX_TestDataFactory.createTestData();
       
        Test.stopTest();
    }
}