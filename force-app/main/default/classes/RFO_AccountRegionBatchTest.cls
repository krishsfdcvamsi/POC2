@isTest
public class RFO_AccountRegionBatchTest {
    
    public static testmethod void updateRegion(){
        User adminUser = new User();
        adminUser.FirstName = 'Test';
        adminUser.LastName = 'Test';
        adminUser.Alias = 'Test';
        adminUser.Email = 'someemail@blabla.com';
        adminUser.UserName = 'someemail@blabla.com';
        adminUser.EmailEncodingKey = 'UTF-8';
        adminUser.LanguageLocaleKey = 'en_US';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.Region__c = 'Midwest';
        adminUser.TimezoneSidKey = 'America/Los_Angeles';
        adminUser.ProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ].Id;
        adminUser.UserRoleId = [SELECT Id,name FROM UserRole where PortalType != 'CustomerPortal' LIMIT 1].Id;
        insert adminUser;
        
        System.runAs(adminUser) {
            Account acc = new Account();
            acc.Name = 'testaccount';
            acc.RFO_Region__c = 'Sales Ops';
            insert acc;            
        }
        RFO_AccountRegionBatch region = new RFO_AccountRegionBatch();
        Database.executeBatch(region);
    }
    
}