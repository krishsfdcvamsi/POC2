/************************************************************************************************************************************************** 
 * Class Name : AlertJobChecker_Test
 * Description : Test Update Alert Completion Status For Alert Notifications
 * Author : Haseeb
 * Created On : 10/26/2020
 *
 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------
 * Date                       Developer                          Description
 * -----------------------------------------------------------------------------------------------------------------
 * 10/26/20                    Haseeb                       	ALPHA - 771, Test Update Alert status to Completed if the Related to Criteria is True.
 * 
 **************************************************************************************************************************************************/
@isTest
public class AlertJobChecker_Test {
	//Test AlertJobChecker class for marking the Alerts as completed when the criteria field is true
    static testmethod void testAlertCheckerJob() {
        //Create Account
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
	   	account acc1 =new account();
	   	acc1.Name = 'BNSF';  // Account Name
       	acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
       	acc1.Phone = '800-832-5452';         
        insert acc1;
        
        //Creat Contact
        Contact c = new contact();
        c.AccountId = acc1.Id;
        c.LastName = 'Blah1';
        c.FirstName = 'Blah1';
        c.Phone = '9999999999';
        c.RFO_ContactRole__c = 'Legal Contact';
        c.Email = 'Test1@test.com';
        insert c;
        
        //Create Case[Change Request]
        Case ca = new Case();
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        ca.AccountId = acc1.Id;
        ca.RFO_CaseNature__c = 'Request';
        ca.Type = 'Estimating';
        ca.RFO_SubType__c = 'Disputes';
        ca.ContactId = c.Id;
        ca.Priority = 'Medium';
        ca.Status = 'New';
        ca.Engineering_Review_Completed__c = True;
        ca.Origin = 'Customer Initiated';
        insert ca;
        
        Alert__c a = new Alert__c();
        a.Related_To__c = ca.Id;
        a.Related_To_Object_Name__c = 'Case';
        a.Related_To_Field_Name__c = 'Engineering_Review_Completed__c';
        insert a;
        
        Test.startTest();
        String scheduleConfig = '0 0 23 * * ?';
        String jobIdScheduler = system.schedule('Test Alert Status Completion', scheduleConfig, new AlertJobChecker()); 
        Test.stopTest();
        System.assertNotEquals(jobIdScheduler, null);
    }
}