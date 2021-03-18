@isTest
public class CallReportValidation_Test {
    private static testMethod Void validateCallReport(){
        //Create Account
	Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
	   account acc1 =new account();
	   acc1.Name = 'BNSF';  // Account Name
       acc1.RecordTypeId = recordTypeIdCustomer;           // Account Record Type
       acc1.Phone = '800-832-5452';         
        insert acc1;
        //Creat Contact
        Contact c = new contact();
        c.AccountId = acc1.Id;
        c.LastName = 'Blah';
        c.FirstName = 'Blah';
        c.Phone = '9999999999';
        c.RFO_ContactRole__c = 'Legal Contact';
        c.Email = 'Test@test.com';
        insert c;
        //Create Coverage Plan
        RFO_CoveragePlan__c cp = new RFO_CoveragePlan__c();
        Id recordTypeIdActive = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        cp.RecordTypeId = recordTypeIdActive;
        cp.RFO_AccountName__c = acc1.Id;
        cp.RFO_CoveragePlanApprovalStatus__c = 'Sent for Approval';
        insert cp;
        test.startTest();
        //Create Call Report
        Call_Report__c cr = new Call_Report__c();
        Id recordTypeIdCommercial = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByDeveloperName().get('RFO_Commercial_Sales').getRecordTypeId();
        cr.RecordTypeId = recordTypeIdCommercial;
        cr.Account__c = acc1.Id;
        cr.Contact__c = c.Id;
        cr.RFO_Purpose__c = 'Test';
        cr.Call_Date__c = system.today();
        cr.RFO_Hashtags__c = 'FaceToFace';
        cr.RFO_TotalFleetCount__c = 22;
        cr.Result__c = 'test';
        cr.RFO_Status__c = 'Completed';
        try{
        insert cr;
        }
        catch  (exception  e){
            system.debug('Error Message :'+e.getMessage());
            system.assertEquals(e.getMessage().contains('You cannot save the record as " Completed " because Coverage Plan is pending SVP approval'), true);
        }
        
        test.stopTest();
    }
}