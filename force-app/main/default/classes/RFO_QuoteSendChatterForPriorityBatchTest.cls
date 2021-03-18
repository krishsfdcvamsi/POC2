/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 29 May 2019
* @Description :This Test class written for Apex Class: RFO_QuoteSendChatterForPriorityBatchTEST.
**/
 
@isTest()
Public Class RFO_QuoteSendChatterForPriorityBatchTest{
/**
*   Test method with test data to pass batch class
**/
        
    static testmethod void schedulerTest() 
    {
                  /**
* Test method with test data to pass scheduled batch class 
**/
        String cRON_EXP = '0 0 5 * * ?';
        
        // User Creation for 
             User userQuoteTeam = new User();
             userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
           /*  userQuoteTeam.RFO_Contracts__c = True;
             userQuoteTeam.RFO_Engineering__c = True;
             userQuoteTeam.RFO_Estimating__c = True;
             userQuoteTeam.RFO_PortfolioManagement__c = True;
             userQuoteTeam.RFO_PricingSummary__c = True;
             userQuoteTeam.RFO_ProductionPlanning__c = True;
             userQuoteTeam.RFO_AccountManager__c = True;
             userQuoteTeam.RFO_Sales__c = True; */
             Database.insert(userQuoteTeam);
                          
       // Account Creation        
            List<Account> accList = new List<Account>();
            accList = RFO_Utility_Test.createProspectAccounts();
            Database.insert(accList);        
           // System.debug('accountlist'+accList);
           
              
       // Opportunity Creation     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);
            //oppList[0].StageName = 'Quoting';                    
            Database.insert(oppList);           
        
        //QuoteTeam Creation
           RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
        quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
           /*   Name = 'Test',                               // QuoteTeams Name
              RFO_PortfolioMember__c = userQuoteTeam.id,  // Portfolio Management
              RFO_EngineeringMember__c = userQuoteTeam.id,  // Engineering
              RFO_PlanningMember__c = userQuoteTeam.id,     // Production Planning
              RFO_EstimatingMember__c = userQuoteTeam.id,   // Estimating
              RFO_PricingMember__c = userQuoteTeam.id,      // Pricing
              RFO_ContractsMember__c = userQuoteTeam.id,    // Contract
              RFO_SalesMember__c = userQuoteTeam.id,     // Sales
              RFO_QuoteOwner__c = userQuoteTeam.id        //Account Manager
            ); */
            Database.insert(quoteTeamRec);
        
        // Create your test data
        List<SBQQ__Quote__c> quotes= new List<SBQQ__Quote__c>();
    
        SBQQ__Quote__c quote1= new SBQQ__Quote__c(); 
        quote1.SBQQ__Opportunity2__c  = oppList[0].id;       
        quote1.RFO_QuoteTeam__c =  quoteTeamRec.id; 
        quote1.RFO_Priority__c = 'Escalated Priority';
        quote1.RFO_PriorityDate__c =system.today().AddDays(-2) ;       
        
        Database.insert(quote1);
        quotes.add(quote1);
        
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  cRON_EXP, new RFO_QuoteSendChatterForPriorityBatch());
            CronTrigger cront = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];
     
        Test.stopTest();
        // Add assert here to validate result 
            System.assertEquals(cRON_EXP, cront.CronExpression);
            System.assertEquals(0, cront.TimesTriggered);

    }
}