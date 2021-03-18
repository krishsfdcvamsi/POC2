@isTest
public class AccountContactRelationHandlerTest {
@testSetup
    static void createTestData() {
        Account testAcc = new Account();
        testAcc.Name = 'testAccount';
        testAcc.RFO_AccountOwner__c = 'Me';
        testAcc.CDX_CopyCDMOnEmail__c = true;
        testAcc.RFO_TASID__c = '123456';
        insert testAcc;
        
        Contact cont = new Contact();
        cont.AccountId= testAcc.Id;
        cont.LastName = 'Testlast';
        cont.FirstName = 'Testlast1';
        cont.Title = 'Mr';
        cont.RFO_NickName__c = 'Bob';
        cont.Phone = '999 999 9999'; 
        cont.OtherPhone = '888 888 8888'; 
        cont.Fax = '111 111 1111'; 
        cont.mobilePhone = '777 777 7777';
        cont.Email = 'test@test.com'; 
        cont.CDX_EInvoice__c = true;
        cont.CDX_InvoiceType__c = 'Rental;Repairs;Mileage;Modification';
        cont.CDX_FileFormat__c = 'Text (.txt);PDF (.pdf);AAR Format (.dat);MS Excel (.xls);New MS Excel (.xlsx)'; 
        cont.RFO_ContactRole__c = 'Sales - Executive';
        cont.Customer_Interests__c = 'Billing';
        insert cont;
    }
    static testmethod void testcheckRoleonCon() {
         
        Contact con = [SELECT Id, firstName, lastName, Email, Accountid,RFO_ContactRole__c FROM Contact];
        List<AccountContactRelation> acr= [Select id,isDirect,Roles,ContactId from AccountContactRelation where isDirect = true and Contactid =:con.id];
        
        Test.startTest();
        acr[0].Roles = 'Legal Contact';
        update acr[0];
        Test.stopTest();
        Contact updatecon =[Select id,RFO_ContactRole__c from Contact where id = :acr[0].ContactId];
        System.assertEquals(acr[0].Roles,updatecon.RFO_ContactRole__c);
    }
    static testmethod void testcheckRoleonACR() {
         
        Contact con = [SELECT Id, firstName, lastName, Email, Accountid,RFO_ContactRole__c FROM Contact];
                
        Test.startTest();
        con.RFO_ContactRole__c = 'Legal Contact';
        update con;
        Test.stopTest();
        List<AccountContactRelation> acr= [Select id,isDirect,Roles,ContactId from AccountContactRelation where isDirect = true and Contactid =:con.id];
        System.assertEquals(con.RFO_ContactRole__c,acr[0].Roles);
    }
}