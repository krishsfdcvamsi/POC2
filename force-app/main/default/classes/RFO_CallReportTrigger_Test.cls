/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 11th Oct 2018
* @Description :This is test class for RFO_CallReportTrigger.
**/
@isTest
private class RFO_CallReportTrigger_Test{
    
    @isTest
    private static void callReportTestMethod(){
        List<Account> accList = new List<Account>();
        Account accnt1 = RFO_TestDataSetup_Factory.customerAccount();
        Account accnt2 = RFO_TestDataSetup_Factory.customerAccount();
        accList.add(accnt1);
        accList.add(accnt2);
        System.debug('--accList:--'+accList);
        
        List<Contact> cntList = new List<Contact>();
        Contact contactRec1 = RFO_TestDataSetup_Factory.contactRecord1(accList[0].id);
        Contact contactRec2 = RFO_TestDataSetup_Factory.contactRecord1(accList[1].id);
        cntList.add(contactRec1);
        cntList.add(contactRec2);
        System.debug('--cntList:--'+cntList);
        Profile profileId = [SELECT Id FROM Profile WHERE Name = : RFO_Constant.SALES_PROFILE LIMIT 1];
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@example.com',
                           Username = 'jason.liveston@example.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        
        Test.startTest();
        AccountTeamMember accTM1 = RFO_TestDataSetup_Factory.accTeam3(accList[0].id,usr.id);
        List<Call_Report__c> crList = new List<Call_Report__c>();
        Call_Report__c callReport1 = RFO_TestDataSetup_Factory.commSalesCR(accList[0].id, cntList[0].id);
        Call_Report__c callReport2 = RFO_TestDataSetup_Factory.commSalesCR(accList[1].id, cntList[1].id);
        Call_Report__c callReport3 = RFO_TestDataSetup_Factory.fieldServiceCR(accList[0].id, cntList[0].id);
        crList.add(callReport1);
        crList.add(callReport2);
        crList.add(callReport3);
        System.debug('--crList:--'+crList);
        Test.stopTest();
        
    } // end of method callReportTestMethod
}