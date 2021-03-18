@isTest
private class CDX_MileageEqualizationTest
{
    @isTest 
   static void testContentVersion()
    {
        
      {
        UserRole urole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        adminUser.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Super User-20' LIMIT 1].Id;
        insert adminUser;
        System.runAs(adminUser) {
       
        Account ac=new Account();
        ac.Name='testAccount';
        insert ac;

        Contact con = new contact();
        con.AccountId = ac.Id;
        con.FirstName = 'Test';
        con.LastName = 'Contact 123';
        con.Email = 'aniketbajaj3150@gmail.com';
        insert con;              
        
		profile p =[Select id, name from profile where name = 'CDX Customer']; 
        
        User u1 = new User();
        u1.ContactId = con.id;
        u1.Alias = 'arvv1234';
        u1.Email='arvqq@testorg.com';
        u1.EmailEncodingKey='UTF-8';
        u1.LastName='Testing';
        u1.LanguageLocaleKey='en_US';
        u1.LocaleSidKey='en_US'; 
        u1.ProfileId = p.Id;
        u1.TimeZoneSidKey='America/Los_Angeles';
        u1.UserName='arv12305@gmail.com';
        u1.Lan_Id__c='arv123-LAN';
        insert u1;

        ContentVersion contentVersionInsert1 = new ContentVersion(Title = 'Test',PathOnClient = 'Test.jpg',VersionData = Blob.valueOf('Test Content Data'),IsMajorVersion = true,
                                                                   Trinity_File_Type__c ='Mileage Statement',SharingPrivacy='N');
        insert contentVersionInsert1;
        
        ContentVersion v2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert1.Id];
        ContentDocumentLink contentlink2 = new ContentDocumentLink();
        contentlink2.LinkedEntityId = ac.id;
        contentlink2.contentdocumentid = v2.ContentDocumentId; 
        contentlink2.ShareType = 'V';
        contentlink2.Visibility = 'AllUsers';
       insert contentlink2;
        //string userId=UserInfo.getProfileId();
        string userId=u1.id;
        Test.startTest();
        CDX_Mileage_Equalization.GetMileageEqualization(userId);
        Test.stopTest();
                    
          }
        }
    }
}