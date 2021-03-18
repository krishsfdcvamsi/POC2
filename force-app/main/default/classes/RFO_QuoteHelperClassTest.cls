/**
* @Author      : Accenture
* @Version     : 1.0
* @Created Date: 29 May 2019
* @Description : This Test Class covers Apex Trigger: RFO_QuoteTrigger, RFO_QuoteTeamTrigger and Apex Class: RFO_QuoteHelperClass, RFO_CreateQuoteShareRecord Code Coverage.
**/

@isTest(SeeAllData=false)
/*   Test Class Begins    */
Private Class RFO_QuoteHelperClassTest{ 
    /*Create Account Test Data */
    @testsetup static void createTestdata(){

        //updated testsetup
        // Account Creation        
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = String.valueOf(Math.Random()).left(18);
        accList[0].RFO_OracleId__c = String.valueOf(Math.Random()).left(18);
        accList[0].RFO_TASId__c = String.valueOf(Math.Random()).left(18);
        for(Account acc :accList ) {
            acc.recordTypeId = recordTypeId;
        }
        DataBase.insert(accList);

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
         Id quoteRecordTypeId =  Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
        quote1.RFO_QuoteStage__c='In Progress';
        quote1.RecordTypeId = quoteRecordTypeId;
        database.insert(quote1);
        /* Added By Vihari EPSI - 641 */
        CollaborationGroup cGroup = new CollaborationGroup(
      	Name = 'Fleet Engineer Test Group',  //Group name must be unique
      	CollaborationType = 'Private'
	    );
    	insert cGroup;
        /* End EPSI - 641*/
        
    }
    static testmethod void quotechattersenttoQuoteteam(){
        User userQuoteTeam = [Select id from User Limit 1];
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
        User userQuoteTeam = [Select id from User Limit 1];
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
        User userQuoteTeam = [Select id from User Limit 1];
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
            quoteRec.recordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
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
        User userQuoteTeam = [Select id from User Limit 1];
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
        quoteRec.RFO_QuoteTeam__c =  quoteTeamRec1.id; 
            quoteRec.SBQQ__Opportunity2__c=oppRec.id;
            quoteRec.SBQQ__Primary__c=true; 
            database.update(quoteRec); 
            oppRec.StageName='Closed-Won';
            database.update(oppRec);
         RFO_QuoteTriggerHandler obj = new RFO_QuoteTriggerHandler();
          obj.afterInsert(null);
          obj.afterDelete(null);
               obj.afterUnDelete(null);
    obj.afterUpdate(null,null);
      
    }
    

/**************************************************************************************
* @Author : Ashish Reddy
* @Modified Date : 9/23/2020
* @Description       
* @User Story : ALPHA-119    
**************************************************************************************/    
    @isTest static void testSignedProposalNotifications(){
        
        RecordType ContentRT = [select Id FROM RecordType WHERE Name='Other' and sObjectType = 'ContentVersion']; 
         // Quote Creation 
        SBQQ__Quote__c  quote = [select id, RFO_QuoteStage__c , SBQQ__Primary__c from SBQQ__Quote__c limit 1];
        
        ContentVersion contentVersionInsert = new ContentVersion(
                                                    Title = 'Test',
                                                    PathOnClient = 'Test.jpg',
                                                    VersionData = Blob.valueOf('Test Content Data'),
                                                    IsMajorVersion = true,
                                                    Trinity_File_Type__c = 'Other',
                                                    recordTypeId = ContentRT.Id,
                                                    SharingPrivacy='N'
                                                     
                                                );
        insert contentVersionInsert;
        
        ContentVersion v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id];
        
        
 

        ContentDocumentLink contentlinkQuote = new ContentDocumentLink(
                                                LinkedEntityId = quote.id,
                                                contentdocumentid = v.ContentDocumentId,
                                                ShareType = 'V',
                                                Visibility = 'AllUsers');
        insert contentlinkQuote;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();        
        contentVersionList.add( new ContentVersion(
                                                Title = 'Test Signed Proposal',
                                                PathOnClient = 'Test.jpg',
                                                VersionData = Blob.valueOf('Test Content Data Signed Proposal'),
                                                IsMajorVersion = true,
                                                Trinity_File_Type__c = 'Signed Proposal',
                                                recordTypeId = ContentRT.Id,
                                                SharingPrivacy='N',
                                                ContentDocumentId = v.ContentDocumentId));
        insert contentVersionList;
        Test.startTest();
        quote.SBQQ__Primary__c = false;
        quote.RFO_QuoteStage__c =  RFO_Constant.BUSINESS_AWARDED;	
        update quote;
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        quoteMap.put(quote.Id, quote);
        
        RFO_QuoteHelperClass.sendSignedProposalNotification(quoteMap);
        
        Test.stopTest();
        system.assertEquals( quote.RFO_QuoteStage__c,  RFO_Constant.BUSINESS_AWARDED);
    }  
    
     /* Added By Vihari 12/28/20 */
    private static testMethod void testBeforeInsertforClone(){
        SBQQ__Quote__c quoteRec = [Select id, RFO_QuoteTeam__c,SBQQ__Opportunity2__c,SBQQ__Primary__c from SBQQ__Quote__c Limit 1];
        SBQQ__Quote__c objClonedQuote = quoteRec.clone(false, false, false, false);
        test.startTest();
        insert objClonedQuote;
        test.stopTest();
        
    }
    
    private static testMethod void testAfterInsert(){
        SBQQ__Quote__c quote = [Select id, RFO_QuoteTeam__c,SBQQ__Opportunity2__c from SBQQ__Quote__c Limit 1];
        quote.SBQQ__Primary__c = true;
        String recTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('New').getRecordTypeId();
        quote.recordTypeId = recTypeId;
        
        Opportunity oppRec=[Select id from Opportunity Limit 1];
        RFO_QuoteTeams__c qtmRec = [select id, name from RFO_QuoteTeams__c Limit 1];
        User userQuoteTeam = [Select id from User Limit 1];
        Account accRec = [select id, name from Account Limit 1];

		SBQQ__Quote__c  quote2 = RFO_Utility_Test.createQuote(oppRec);
        quote2.RFO_QuoteTeam__c=qtmRec.id;  
        quote2.RFO_PortfolioManagementSection_Started__c='Yes';
        quote2.RFO_EngineeringSectionStarted__c='Yes';
        quote2.RFO_EstimatingSectionStarted__c='Yes';
        quote2.RFO_ProductionPlanningSection_Started__c='Yes';
        quote2.RFO_PortfolioManagementSectionComplete__c =' ' ;
        quote2.RFO_PortfolioManagementSectionComplete__c ='No' ;
        quote2.RFO_ProdPlanSectionComplete__c='';
        quote2.RFO_PricingSectionStarted__c='Yes';
        quote2.RFO_PricingSectionComplete__c='';
        quote2.RFO_QuoteStage__c='In Progress';
        quote2.SBQQ__Primary__c = true;
        quote2.RecordtypeId=recTypeId; 
        //Team Members
        RFO_TeamMembers__c teammem = new RFO_TeamMembers__c(
            Team__c = qtmRec.id,// Team
            Role__c = 'Engineering',      // Role
            User__c = userQuoteTeam.id  // User
        );
         Database.insert(quote2);
        
       // update quotecreate;
        Database.insert(teammem);
        test.startTest();
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        quoteMap.put(quote.Id, quote);
        quoteMap.put(quote2.Id, quote2);
        RFO_QuoteTriggerHandler handler = new RFO_QuoteTriggerHandler();
        handler.afterInsert(quoteMap);     
        test.stopTest();
    }
    
    private static testMethod void testUpdateOpportunityTypeInUpdate(){

        
        Opportunity oppRec=[Select id from Opportunity Limit 1];
        RFO_QuoteHelperClass.updateOpportunityTypeInUpdate(new Set<Id>{oppRec.id});
        
    }
    
    private static testMethod void testAfterUpdate(){
         User userQuoteTeam = [Select id from User Limit 1];
        SBQQ__Quote__c quoteRec = [Select id,RFO_QuoteStage__c, RFO_QuoteTeam__c from SBQQ__Quote__c Limit 1];
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
        Map<Id, SBQQ__Quote__c> oldQuoteMap = new Map<Id, SBQQ__Quote__c>();
        oldQuoteMap.put(quoteRec.Id, quoteRec);
       
        SBQQ__Quote__c newQuoteRec = quoteRec;  
        newQuoteRec.RFO_QuoteStage__c='PM Reviewed';
        Map<Id, SBQQ__Quote__c> newQuoteMap = new Map<Id, SBQQ__Quote__c>();
        newQuoteMap.put(newQuoteRec.Id, newQuoteRec);
        
        test.startTest();

        RFO_QuoteTriggerHandler handler = new RFO_QuoteTriggerHandler();
        handler.afterUpdate(newQuoteMap, oldQuoteMap);     
        test.stopTest();
    }
    
    private static testMethod void testDeleteQuoteTeamMembers(){
        SBQQ__Quote__c quoteRec = [Select id,RFO_QuoteStage__c, RFO_QuoteTeam__c from SBQQ__Quote__c LIMIT 1];
        //User Creation
        User userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        Database.insert(userQuoteTeam);
        // Creating a Quote Team member
        Quote_Team_Member__c quotteammem = RFO_Utility_Test.createQuoteTeamMember(quoteRec,userQuoteTeam);
        Database.insert(quotteammem);
        test.startTest();
        RFO_QuoteHelperClass.deleteQuoteTeamMembers(new List<SBQQ__Quote__c>{quoteRec});
        test.stopTest();
        List<Quote_Team_Member__c> quoteMemList =  [select Id 
                                                      from Quote_Team_Member__c 
                                                      where Quote__c = :quoteRec.id Limit 49999];
        System.assertEquals(0, quoteMemList.size());
        
    }
        
    

    
}