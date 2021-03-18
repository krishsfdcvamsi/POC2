/** @Author      : Accenture
*   @Version     : 1.0 
*   @Created Date: 28 Sep 2019
*   @Description : This test class is for RFO_UpdateDaysBeforeProposal.
**/
@isTest(SeeAllData=false)
private Class RFO_UpdateDaysBeforeProposalTest{
    /**
*   Test method with test data to pass batch class
**/
    private static testmethod void updatedaysbefore() 
    {
        String cRON_EXP = '0 0 6 * * ?';
             
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Database.insert(accList);        
        
        // Opportunity Creation     
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);
        Database.insert(oppList);           
                        
        // Quote Creation  
        List<SBQQ__Quote__c> qto = RFO_Utility_Test.createQuoteList(oppList[0]);
        
        Test.startTest();
        String jobId = System.schedule('UpdateScheduleApexClassTest',  cRON_EXP, new RFO_UpdateDaysBeforeProposalBatch());
        CronTrigger ctron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
        
        /* RFO_UpdateDaysBeforeProposalBatch quoteBatch = new RFO_UpdateDaysBeforeProposalBatch();
DataBase.executeBatch(quoteBatch); */
        Test.stopTest();
        System.assertEquals(cRON_EXP, ctron.CronExpression);
        System.assertEquals(0, ctron.TimesTriggered);        
    }
}