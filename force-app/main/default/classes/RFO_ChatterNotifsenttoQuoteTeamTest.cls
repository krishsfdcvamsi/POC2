/** @Author      : Accenture
* @Version     : 1.0
* @Created Date: 24 June 2019
* @Description : This class is used for sending the chatter notification to Quote Team User.
  **/
@isTest(SeeAllData=false)
private class RFO_ChatterNotifsenttoQuoteTeamTest {
    /**
* Test method with test data to pass batch class
**/   
    static testmethod void quotechattersenttoQuoteteam(){
        String cRON_EXP = '0 0 7 * * ?';
        
                                  
       // Account Creation        
            List<Account> accList = new List<Account>();
            accList = RFO_Utility_Test.createProspectAccounts();
            Database.insert(accList);        
           // System.debug('accountlist'+accList);
           
              
       // Opportunity Creation     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);
           // oppList[0].StageName = 'Quoting';
            Database.insert(oppList);           
         
        //QuoteTeam Creation
             

           RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
         quoteTeamRec = RFO_Utility_Test.createQuoteTeam(); 
         Database.insert(quoteTeamRec);

       
      SBQQ__Quote__c  quote1 = RFO_Utility_Test.createQuote(oppList[0]);
        quote1.RFO_QuoteTeam__c=quoteTeamRec.id; 
        Database.insert(quote1); 
       /* The following conditions check to be done when (current date -created date)>6 */
        quote1.RFO_PortfolioManagementSection_Started__c ='Yes';
       // quote1.RFO_PortfolioManagementSectionComplete__c ='  ';
        quote1.RFO_PortfolioManagementSectionComplete__c ='No';
        quote1.RFO_EngineeringSectionStarted__c = 'Yes'; 
        quote1.RFO_EstimatingSectionStarted__c = 'Yes';
        quote1.RFO_ProductionPlanningSection_Started__c = 'Yes';
        quote1.RFO_PricingSectionStarted__c = 'Yes';
        quote1.RFO_EngineeringSectionComplete__c='';
        quote1.RFO_EstimatingSectionCompleted__c='';
        quote1.RFO_ProdPlanSectionComplete__c='';
        quote1.RFO_PricingSectionComplete__c='';
        Database.update(quote1); 
     Test.setCreatedDate(quote1.Id, DateTime.newInstance(2019,10,21));
      
        //start test
       String jobId = System.schedule('ChatterNotifiScheduleApexClassTest', 
                                      cRON_EXP, new RFO_ChatterNotificationsenttoQuoteTeam());
        Test.startTest();
      
        CronTrigger cront = [SELECT Id, CronExpression, TimesTriggered,  
                          NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
        Test.stopTest();
         
        System.assertEquals(cRON_EXP, cront.CronExpression);
        System.assertEquals(0, cront.TimesTriggered);
    } 
}