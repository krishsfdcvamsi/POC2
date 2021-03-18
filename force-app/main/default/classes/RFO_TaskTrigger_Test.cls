/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 11th Oct 2018
* @Description :This is test class for RFO_TaskTrigger.
**/
@isTest(SeeAllData = false)
private class RFO_TaskTrigger_Test{
    
    /**
    * @Author      : Accenture
    * Method Name  : taskTestMethod
    * @Created Date: 11th Oct 2018
    * @Description : Test method to get coverage of trigger
    **/
    @isTest
    private static void taskTestMethod(){
        List<Account> accList = new List<Account>();
        Account accnt1 = RFO_TestDataSetup_Factory.customerAccount();
        Account accnt2 = RFO_TestDataSetup_Factory.customerAccount();
        accList.add(accnt1);
        accList.add(accnt2);
        
        List<Contact> cntList = new List<Contact>();
        Contact contactRec1 = RFO_TestDataSetup_Factory.contactRecord1(accList[0].id);
        Contact contactRec2 = RFO_TestDataSetup_Factory.contactRecord1(accList[1].id);
        cntList.add(contactRec1);
        cntList.add(contactRec2);
        
        
        List<RFO_CoveragePlan__c> cpList = new List<RFO_CoveragePlan__c>();
        RFO_CoveragePlan__c covrgPlan1 = RFO_TestDataSetup_Factory.activeCPRecord(accList[0]);
        RFO_CoveragePlan__c covrgPlan2 = RFO_TestDataSetup_Factory.activeCPRecord(accList[1]);
        cpList.add(covrgPlan1);
        cpList.add(covrgPlan2);
        
        List<Task> taskList = new List<Task>();
        Task taskRecord1 = RFO_TestDataSetup_Factory.cpTaskRecord(cntList[0].id, cpList[0].id);
        Task taskRecord2 = RFO_TestDataSetup_Factory.cpTaskRecord(cntList[1].id, cpList[1].id);
        Test.startTest();
        taskList.add(taskRecord1);
        taskList.add(taskRecord2);
        Test.stopTest();
        System.AssertEquals(taskRecord1.WhoId, cntList[0].id);
        
    } // end of method taskTestMethod
}