@isTest
public class RFO_CPPlanStatusSchedulerTest {
    static testMethod void testMethod1(){
    	List<RFO_CoveragePlan__c> cpList = new List<RFO_CoveragePlan__c>();
        Id activeRecordTypeId = Schema.SObjectType.RFO_CoveragePlan__c.getRecordTypeInfosByDeveloperName().get('RFO_Active').getRecordTypeId();
        account ac =new account();
		   ac.Name = 'BNSF';  // Account Name
		   ac.Phone = '800-832-5452';          // Phone
		   ac.RFO_Region__c = 'Class 1 Railroads';   // Region
		   ac.RFO_AccountStatus__c = 'Active';
		   //ac.OwnerId = usr1.id;
		   database.insert(ac,false);
		   
        
            RFO_CoveragePlan__c cp = new RFO_CoveragePlan__c(
				RFO_CoverageRecommendation__c = 'Minimal',               
				RFO_ReasonForCoverageChange__c = 'Other', 
				RFO_AccountName__c = ac.id,               
				RFO_CoveragePlan__c = 'Low', 
				RFO_RecordStatus__c=true,
				RecordTypeId = activeRecordTypeId,
				RFO_ActualContactDate__c = system.today(),
				RFO_CoveragePlanApprovalStatus__c = 'APPROVED',
				RFO_PlanningStatus__c = 'Need to Schedule',  
				RFO_SalesLastFacetoFaceDate__c = system.today(),
				RFO_SalesLastContactDate__c = system.today(),
                RFO_NextScheduledContactDate__c = (system.today()+365),
				RFO_Notes__c = 'CP Test'                
			);
			cpList.add(cp);
			
        
        insert cpList;
        Test.startTest();
        RFO_CPPlanStatusScheduler job = new RFO_CPPlanStatusScheduler();
        DataBase.executeBatch(job);
        String sch = '0 0 6 * * ?';
        Database.QueryLocator ql = job.start(null);
        job.execute(null,cpList);
        job.Finish(null);
        System.schedule('Test', sch, job);
        Test.stopTest();
    }
}