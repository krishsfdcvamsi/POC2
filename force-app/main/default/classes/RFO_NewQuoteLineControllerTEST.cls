/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 29 May 2019
* @Description : This Test Class covers Apex Class: RFO_NewQuoteLineController Code Coverage.
**/
@isTest(SeeAllData = false)
private Class RFO_NewQuoteLineControllerTEST{
    /* Test method to create test data for Quote and Quote Line creation */ 
    static testmethod void quoteTestMethod(){
        
        // User Creation for 
     /*   User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        // userQuoteTeam.RFO_Contracts__c = True;
        userQuoteTeam.RFO_Engineering__c = True;
        userQuoteTeam.RFO_Estimating__c = True;
        userQuoteTeam.RFO_PortfolioManagement__c = True;
        userQuoteTeam.RFO_PricingSummary__c = True;
        userQuoteTeam.RFO_ProductionPlanning__c = True;
        userQuoteTeam.RFO_AccountManager__c = True;
        userQuoteTeam.RFO_Sales__c = True;
        Database.insert(userQuoteTeam);  */
        
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Database.insert(accList);        
        
        
        // Opportunity Creation     
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);
        // oppList[0].StageName = 'Quoting';                    
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
            // RFO_ContractsMember__c = userQuoteTeam.id,    // Contract
            RFO_SalesMember__c = userQuoteTeam.id,     // Sales
            RFO_QuoteOwner__c = userQuoteTeam.id        //Account Manager
        ); */
        Database.insert(quoteTeamRec);
        //To compare Actual result with expected result 
        System.assertEquals('Test', quoteTeamRec.Name);
        
        // Quote Creation
        List<SBQQ__Quote__c> qtList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c qtln = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0],quoteTeamRec);
        qtln.SBQQ__Opportunity2__c  = oppList[0].id;       
        qtln.RFO_QuoteTeam__c =  quoteTeamRec.id;   
        //qt.RFO_CarType__c = 'High Pressure Large';      
        //insert qt; 
        qtList.add(qtln);
        Database.insert(qtList);     
        Test.setCurrentPage(Page.RFO_NewQuoteLine);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(qtList);
        ApexPages.StandardController standcon = new ApexPages.StandardController(qtln);
        ApexPages.currentPage().getParameters().put('Id',qtln.id);            
        RFO_NewQuoteLineController cls = new RFO_NewQuoteLineController(stdSetController);
        RFO_NewQuoteLineController newQLine = new RFO_NewQuoteLineController(standcon);
        cls.quoteLineRecordType();
        
        Database.delete(qtList);  
        newQLine.quoteLineRecordType();
    } 
}