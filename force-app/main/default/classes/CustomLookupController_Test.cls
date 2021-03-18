@isTest(seeAllData = false)
public class CustomLookupController_Test{   
    
    private static testMethod void lookupTest(){ 
        Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        Account ac = new Account();
        ac.Name = 'Test Account 1';
        ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
        ac.Phone = '800-832-5452';          // Phone
        ac.RFO_Region__c = 'Class 1 Railroads';   // Region
        ac.RFO_AccountStatus__c = 'Active';
        insert ac;
        CustomLookupController.fetchRecords('Account','Name','','');
    }
}