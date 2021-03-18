@isTest(SeeAllData=false)
private class RFO_QuoteRenewalEffSetSchedTest {
	@testSetup 
    static void setup() {
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = '14098';
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        database.insert(accList);
        List<Contact> conList = new List<Contact>();
        conList= RFO_Utility_Test.createContact(accList[0]);
        database.insert(conList);
        
        User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        //  userQuoteTeam.RFO_Contracts__c = True;
        userQuoteTeam.RFO_Engineering__c = True;
        userQuoteTeam.RFO_Estimating__c = True;
        userQuoteTeam.RFO_PortfolioManagement__c = True;
        userQuoteTeam.RFO_PricingSummary__c = True;
        userQuoteTeam.RFO_ProductionPlanning__c = True;
        userQuoteTeam.RFO_AccountManager__c = True;
        userQuoteTeam.RFO_Sales__c = True;
        Database.insert(userQuoteTeam);
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities1(accList[0],conList[0]);
        // oppList[0].StageName = 'Quoting'; 
        oppList[0].Requirement_Status__c= 'Test';// Added By Vihari 1/5/21
                           
        database.insert(oppList);
        
        RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c(
            Name = 'Test',                               // QuoteTeams Name
            RFO_PortfolioMember__c = userQuoteTeam.id,  // Portfolio Management
            RFO_EngineeringMember__c = userQuoteTeam.id,  // Engineering
            RFO_PlanningMember__c = userQuoteTeam.id,     // Production Planning
            RFO_EstimatingMember__c = userQuoteTeam.id,   // Estimating
            RFO_PricingMember__c = userQuoteTeam.id,      // Pricing
            // RFO_ContractsMember__c = userQuoteTeam.id,    // Contract
            RFO_SalesMember__c = userQuoteTeam.id,    // Sales
            Region__c='Eastern',
            Type__c='Tank'
        );
        database.insert(quoteTeamRec);
        Id recordTypeIdRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_Renewal').getRecordTypeId();  
        // Quote Creation 
        SBQQ__Quote__c  quotecreate = RFO_Utility_Test.createQuote(oppList[0]);
        quotecreate.RFO_QuoteTeam__c=quoteTeamRec.id;  
        quotecreate.RFO_PortfolioManagementSection_Started__c='Yes';
        quotecreate.RFO_EngineeringSectionStarted__c='Yes';
        quotecreate.RFO_EstimatingSectionStarted__c='Yes';
        quotecreate.RFO_ProductionPlanningSection_Started__c='Yes';
        quotecreate.RFO_PortfolioManagementSectionComplete__c =' ' ;
        quotecreate.RFO_PortfolioManagementSectionComplete__c ='No' ;
        quotecreate.RFO_ProdPlanSectionComplete__c='';
        quotecreate.RFO_PricingSectionStarted__c='Yes';
        quotecreate.RFO_PricingSectionComplete__c='';
        quotecreate.RecordtypeId=recordTypeIdRenewal; 
        quotecreate.RFO_RenewalDate__c=system.today();
        quotecreate.SBQQ__Primary__c=True;
        database.insert(quotecreate); 
        
        
    }
    
    static testmethod void testOrderSurveyScheduler(){
        Test.startTest();
        RFO_QuoteRenewalEffSetScheduler sh1 = new RFO_QuoteRenewalEffSetScheduler();
        String sch = '0 0 1 * * ?'; 
        system.schedule('Quote Renewal', sch, sh1); 
        Test.stopTest();
    }
}