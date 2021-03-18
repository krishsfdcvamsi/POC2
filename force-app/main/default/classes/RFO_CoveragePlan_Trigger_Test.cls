/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 11th Oct 2018
* @Description :This is test class for RFO_CoveragePlan_Trigger.
**/
@isTest
private class RFO_CoveragePlan_Trigger_Test{
    
      public static TestMethod void test(){
        Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdCustomer;           // Account Record Type
        acc1.Phone = '800-832-5452';          // Phone
        acc1.RFO_Region__c = 'Class 1 Railroads';   // Region
        acc1.RFO_AccountStatus__c = 'Active';
        insert acc1;
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        RFO_CoveragePlan__c covPlan = new RFO_CoveragePlan__c();
        covPlan.RFO_CoverageRecommendation__c = 'Minimal';               
        covPlan.RFO_ReasonForCoverageChange__c = 'Other'; 
        covPlan.RFO_AccountName__c = acc1.Id;               
        covPlan.RFO_CoveragePlan__c = 'Minimal'; 
        covPlan.RFO_RecordStatus__c=true;
        covPlan.RecordTypeId = activeRecordTypeId;
        covPlan.RFO_ActualContactDate__c = system.today();
        //RFO_CoveragePlanApprovalStatus__c = 'Approved';
        covPlan.RFO_PlanningStatus__c = 'Need to Schedule';  
        covPlan.RFO_SalesLastFacetoFaceDate__c = system.today();
        covPlan.RFO_SalesLastContactDate__c = system.today();
        covPlan.RFO_Notes__c = 'CP Test' ;
        insert covPlan;
           covPlan.RFO_Notes__c = 'CP Test2' ;
         update covPlan; 
    }
   /* 
    @isTest
    private static void coveragePlanTestMethod(){
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
        
        Test.startTest();
        List<RFO_CoveragePlan__c> cpList = new List<RFO_CoveragePlan__c>();
        RFO_CoveragePlan__c covrgPlan1 = RFO_TestDataSetup_Factory.activeCPRecord(accList[0]);
        RFO_CoveragePlan__c covrgPlan2 = RFO_TestDataSetup_Factory.activeCPRecord(accList[1]);
        cpList.add(covrgPlan1);
        cpList.add(covrgPlan2);
        System.debug('cpList:'+cpList);
        //insert cpList();
        Test.stopTest();
        
    } // end of method coveragePlanTestMethod
*/
}