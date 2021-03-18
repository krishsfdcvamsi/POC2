@isTest(seeAllData = false)
public class MultiSelectLookupController_Test{   
    
    private static testMethod void lookupTest(){ 
    
        System.runAs(createUser()) { 
            Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
            Account ac = new Account();
            ac.Name = 'Test Account 1';
            ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
            ac.Phone = '800-832-5452';          // Phone
            ac.RFO_Region__c = 'Class 1 Railroads';   // Region
            ac.RFO_AccountStatus__c = 'Active';
            insert ac;
            list<string> userIds = new list<string>{userInfo.getUserId()};
            string str = userIds.toString();
            MultiSelectLookupController.fetchRecords('User','firstName','',JSON.serialize(userIds),'New',null);
            MultiSelectLookupController.fetchRecords('User','firstName','',JSON.serialize(userIds),'Existing',null);
            MultiSelectLookupController.fetchRecords('Contact','firstName','',JSON.serialize(userIds),'New',ac.Id);
        }
    }
    
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.Lan_Id__c = 'MYDEVROLE';
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
}