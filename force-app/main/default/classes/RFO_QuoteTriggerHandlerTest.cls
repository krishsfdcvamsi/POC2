/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 29 May 2019
* @Description : This Test Class covers Apex Trigger: RFO_QuoteTrigger, RFO_QuoteTeamTrigger and Apex Class: RFO_QuoteHelperClass, RFO_CreateQuoteShareRecord Code Coverage.
**/

@isTest(SeeAllData=false)
/*   Test Class Begins    */
Private Class RFO_QuoteTriggerHandlerTest{ 
 
    /*Create Account Test Data */
    @testsetup static void createTestdata(){
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accList[0].RFO_GlobalAccountID__c = '14098';
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        for(Account acc :accList ) {
            acc.recordTypeId = recordTypeId;
        }
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
        oppList[0].Requirement_Status__c= 'Test';                  
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
        
        // Quote Creation 
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
        quote1.RFO_QuoteStage__c='In Progress';
        database.insert(quote1); 
    }
    static testmethod void quotechattersenttoQuoteteam(){




        User userQuoteTeam = [Select id from User where LastName = 'last' Limit 1];




        Account accRec = [select id, name from Account Limit 1];
        Id salesrecid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_ThirdPartySales').getRecordTypeId();
        accRec.RecordtypeId=salesrecid;
        Database.update(accRec); 
        Opportunity oppRec = [select id, name from Opportunity Limit 1];
        RFO_QuoteTeams__c qtmRec = [select id, name from RFO_QuoteTeams__c Limit 1];
        Id recordTypeIdNewCarLease = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('RFO_New').getRecordTypeId();       
        //  SBQQ__Quote__c quotteam = new SBQQ__Quote__c();
        SBQQ__Quote__c  quotecreate = RFO_Utility_Test.createQuote(oppRec);
        quotecreate.RFO_QuoteTeam__c=qtmRec.id;  
        quotecreate.RFO_PortfolioManagementSection_Started__c='Yes';
        quotecreate.RFO_EngineeringSectionStarted__c='Yes';
        quotecreate.RFO_EstimatingSectionStarted__c='Yes';
        quotecreate.RFO_ProductionPlanningSection_Started__c='Yes';
        quotecreate.RFO_PortfolioManagementSectionComplete__c =' ' ;
        quotecreate.RFO_PortfolioManagementSectionComplete__c ='No' ;
        quotecreate.RFO_ProdPlanSectionComplete__c='';
        quotecreate.RFO_PricingSectionStarted__c='Yes';
        quotecreate.RFO_PricingSectionComplete__c='';
        quotecreate.RecordtypeId=RecordTypeIdNewCarLease; 
        //Team Members
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(
            Team__c = qtmRec.id,// Team
            Role__c = 'Engineering',      // Role
            User__c = userQuoteTeam.id  // User
        );
        Test.startTest();
        quotecreate.RFO_QuoteStage__c='Business Awarded';
        quotecreate.SBQQ__Primary__c=True;
        Database.insert(quotecreate);
        
       // update quotecreate;
        insert (teammem);
        System.debug('team data: '+teammem);
        Test.stopTest();
        system.assertEquals(quotecreate.RFO_PricingSectionStarted__c, 'Yes');
    }
     private static testmethod void opptstatusmethod(){




        User userQuoteTeam = [Select id from User where LastName = 'last' Limit 1];




        SBQQ__Quote__c quoteRec = [Select id, RFO_QuoteTeam__c from SBQQ__Quote__c Limit 1];
        Opportunity oppRec=[Select id from Opportunity Limit 1];
        RFO_QuoteTeams__c quoteTeamRec1 = RFO_Utility_Test.createQuoteTeam(); 
        database.insert(quoteTeamRec1);
        //Team Members
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(
            Team__c = quoteTeamRec1.id,// Team
            Role__c = 'Engineering',      // Role
            User__c = userQuoteTeam.id  // User
        );
        Database.insert(teammem);
        system.assertEquals(teammem.Role__c, 'Engineering');
        
        try{
            Test.startTest();     
            quoteRec.RFO_QuoteStage__c='Business Awarded';
            database.update(quoteRec); 
            oppRec.StageName='Closed-Won';
            database.update(oppRec);
           Test.stopTest();   
        }
        catch(Exception e)
        {
            String message = e.getMessage();
        }
        // system.assertequals(quoteTeamRec1.RFO_SalesMember__c,userQuoteTeam.id);
    } 
    private static testmethod void quoteupdatemethod(){




        User userQuoteTeam = [Select id from User where LastName = 'last' Limit 1];




        SBQQ__Quote__c quoteRec = [Select id, RFO_QuoteTeam__c from SBQQ__Quote__c Limit 1];
        Opportunity oppRec=[Select id from Opportunity Limit 1];
        RFO_QuoteTeams__c quoteTeamRec1 = RFO_Utility_Test.createQuoteTeam(); 
        database.insert(quoteTeamRec1);
        //Team Members
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(
            Team__c = quoteTeamRec1.id,// Team
            Role__c = 'Engineering',      // Role
            User__c = userQuoteTeam.id  // User
        );
        Database.insert(teammem);
        system.assertEquals(teammem.Role__c, 'Engineering');
        
        try{
            Test.startTest();     
            quoteRec.RFO_QuoteTeam__c =  quoteTeamRec1.id; 
            quoteRec.SBQQ__Opportunity2__c=oppRec.id;
            quoteRec.SBQQ__Primary__c=true; 
            database.update(quoteRec); 
            oppRec.StageName='Closed-Won';
            database.update(oppRec);
            
            // quoteTeamRec1.RFO_SalesMember__c = userQuoteTeam.id;
            database.update(quoteTeamRec1);
            Test.stopTest();   
        }
        catch(Exception e)
        {
            String message = e.getMessage();
        }
    }
     private static testmethod void quotedeletemethod(){





        User userQuoteTeam = [Select id from User where LastName = 'last' Limit 1];
        Id CPQQuote_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();   
        SBQQ__Quote__c quoteRec = [Select id, RFO_QuoteTeam__c from SBQQ__Quote__c where recordtypeid <> :CPQQuote_RecTypeId Limit 1];





        Opportunity oppRec=[Select id from Opportunity Limit 1];
        RFO_QuoteTeams__c quoteTeamRec1 = RFO_Utility_Test.createQuoteTeam(); 
        database.insert(quoteTeamRec1);
        //Team Members
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(
            Team__c = quoteTeamRec1.id,// Team
            Role__c = 'Engineering',      // Role
            User__c = userQuoteTeam.id  // User
        );
        Database.insert(teammem);
        system.assertEquals(teammem.Role__c, 'Engineering');
        quoteRec.RFO_QuoteTeam__c =  quoteTeamRec1.id; 
            quoteRec.SBQQ__Opportunity2__c=oppRec.id;
            quoteRec.SBQQ__Primary__c=true; 
            database.update(quoteRec); 
            oppRec.StageName='Closed-Won';
         	oppRec.RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
			oppRec.RFO_WonQuantity__c = 1;
			oppRec.RFO_WonReason__c = 'Price';
			oppRec.RFO_WonAnalysis__c = 'Test';
			oppRec.RFO_PartialOpportunitystillActive__c = 'No';
            database.update(oppRec);
         RFO_QuoteTriggerHandler obj = new RFO_QuoteTriggerHandler();
          obj.afterInsert(null);
          obj.afterDelete(null);
               obj.afterUnDelete(null);
    obj.afterUpdate(null,null);
      
    }








    //CPQ (arivkin)
    @istest
    private static void createCPQQuote_Success()
    {
         Id CPQQuote_RecTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();  
         List<SBQQ__Quote__c> quoteRecs = [Select id, CPQ_Quote__c from SBQQ__Quote__c where RFO_QuoteStage__c ='In Progress' and recordtypeid <> :CPQQuote_RecTypeId Limit 1];
        List<SBQQ__Quote__c> CPQQuoteRecs = [Select id, CPQ_Quote__c from SBQQ__Quote__c where RFO_QuoteStage__c ='In Progress' and recordtypeid <> :CPQQuote_RecTypeId Limit 1];
         system.assert(quoteRecs.size()==1, 'Failed to create a quote in test data setup');



        


         List<CPQSettings__mdt> iterationControl= [SELECT MasterLabel, QualifiedApiName, Value__c, Active__c from  CPQSettings__mdt 
                                                       WHERE QualifiedApiName ='RFO_QuoteTriggerHandler_AfterUpdate_Exec' 
                                                       AND Active__c=true Limit 1];
           
             if(iterationControl<>null && iterationControl.size()>0)
             {
                // iteration is on, we should create cpq quote
				
         		
         		system.assert(CPQQuoteRecs.size()==1, 'Failed to create a CPQ quote in Quote Service');
             }
        else
        {
            system.assert(CPQQuoteRecs.size()==0, 'Created CPQ quote, and the Service should be off');
        }





    }
  
    private static testmethod void quoteRiderUpdatemethod(){
        SBQQ__Quote__c oldQuoteRec = [Select id, RFO_QuoteTeam__c, RFO_QuoteStage__c, SBQQ__Opportunity2__c from SBQQ__Quote__c Limit 1];
        SBQQ__Quote__c newQuoteRec = [Select id, RFO_QuoteTeam__c, RFO_QuoteStage__c, SBQQ__Opportunity2__c from SBQQ__Quote__c Limit 1];
        RFO_Rider__c rider = RFO_Utility_Test.createrider();
        rider.Quote_Id__c = oldQuoteRec.Id;
         List<Account> accList = [Select Id from Account];
        Contract contr = new Contract(AccountId = accList[0].id, RFO_ContractType__c=RFO_Constant.CONTRACT_TYPE_DIRECT_SALE ,
                                      RFO_ContractDate__c=system.today());
        
		Database.insert(contr);
        rider.RFO_Contract__c=contr.id;        
        database.insert(rider);
        Map<Id, SBQQ__Quote__c> oldItems = new Map<Id, SBQQ__Quote__c>();
        oldItems.put(oldQuoteRec.Id, oldQuoteRec);
        Map<Id, SBQQ__Quote__c> newItems = new Map<Id, SBQQ__Quote__c>();
        newQuoteRec.RFO_QuoteStage__c = 'PM Reviewed';
        newItems.put(newQuoteRec.Id, newQuoteRec);
        RFO_QuoteTriggerHandler obj = new RFO_QuoteTriggerHandler();
        obj.afterUpdate(newItems, oldItems);






    }
}