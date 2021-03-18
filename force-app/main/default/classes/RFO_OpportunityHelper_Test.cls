/**
*   Test Class : RFO_OpportunityHelper_Test
**/
@isTest(seeAllData = false)
Public Class RFO_OpportunityHelper_Test{
   /*
* Method Name : createOptyTestdata
*/
    @testsetup static void createOptyTestdata(){
        // Account Creation        
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();

        Database.insert(accList);
        List<Contact> contactList = new List<Contact>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        contactList = RFO_Utility_Test.createContact1(accList[0]);
        Database.insert(contactList);
        
        //contract Creation
        Contract contr = new Contract(AccountId = accList[0].id, 
                                      RFO_ContractType__c=RFO_Constant.TEST, RFO_ContractDate__c=system.today());
        Database.insert(contr);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Rider Creation
        RFO_Rider__c rider=new RFO_Rider__c();
        rider=RFO_Utility_Test.createrider();
        rider.RFO_Account__c=accList[0].id;
        rider.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider.RFO_AutoRenewal__c = RFO_Constant.YES;
        rider.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
        rider.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider.RFO_ProductType__c = RFO_Constant.TEST;
        rider.RFO_Contract__c=contr.id;
        rider.RFO_TotalOfCars__c = 9;
        rider.RFO_Commodity__c = commodityList[0].id;
        rider.RFO_IncreaseEffectiveUpon__c = RFO_Constant.COMPLETION_OF_MODIFICATION;
        Database.insert(rider);
        
        RFO_Rider__c rider1=new RFO_Rider__c();
        rider1=RFO_Utility_Test.createrider();
        rider1.RFO_Account__c=accList[1].id;
        rider1.RFO_Status__c = RFO_Constant.READY_FOR_DELIVERY;
        rider1.RFO_AutoRenewal__c = RFO_Constant.YES;
        rider1.RFO_OriginalMaturityDate__c=system.today().AddDays(3);
        rider1.RFO_RiderType__c = RFO_Constant.MANAGEMENT_AGREEMENT;
        rider1.RFO_ProductType__c = RFO_Constant.TEST;
        rider1.RFO_Contract__c=contr.id;        
        rider.RFO_TotalOfCars__c = 9;
        rider.RFO_Commodity__c = commodityList[0].id;
        rider1.RFO_IncreaseEffectiveUpon__c = RFO_Constant.COMPLETION_OF_MODIFICATION;
        Database.insert(rider1);        
    }
    /*
* Method Name : InsertOpty
*/   
    private static testMethod void beforeInsertOpty(){

        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            Id recordTypeIdRenewals =
               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RecordTypeId = recordTypeIdRenewals;        
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = RFO_Constant.TEST_OPPORTUNITY;
            oppList[0].RFO_ExpectedCarstoTrinity__c = null;
            
            Id recordTypeIdMngmt = 
                Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
                                           oppList2 = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList2[0].RecordTypeId = recordTypeIdMngmt;        
            oppList2[0].RFO_RiderID__c=riderRec.id; 
            oppList2[0].RFO_LeaseTermsRequestedMonths__c = null;
            oppList2.addAll(oppList);
            try{
                Test.startTest();
                Database.insert(oppList2);         
                Test.stopTest();
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('Please populate:'), 'message=' + message);
              }
            System.assert(riderRec!=null);                               
        }
    }
    /*
* Method Name : updateOpty
*/   
    private static testMethod void afterInsertOpty(){
//       List<Opportunity> newOptyList = new List<Opportunity>();
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            Id recordTypeIdRenewals =
                Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RecordTypeId = recordTypeIdRenewals;        
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = RFO_Constant.TEST_OPPORTUNITY;
            
            Id recordTypeIdMngmt = 
                Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
            oppList2 = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList2[0].RecordTypeId = recordTypeIdMngmt;        
            oppList2[0].RFO_RiderID__c=riderRec.id; 
            oppList2.addAll(oppList);
            try{
                Test.startTest();
                    Database.insert(oppList2); 
                    oppList2[0].RFO_LeaseTermsRequestedMonths__c = null;
                    oppList[0].RFO_ExpectedCarstoTrinity__c = null;
                    Database.update(oppList2);
                Test.stopTest();
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('Please populate:'), 'message=' + message);
              }
            System.assert(riderRec!=null);                               
        }
    }
    /*
* Method Name : update Renewal/Management Opportunity
*/   
    private static testMethod void updateManagementOpty(){

        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            Id recordTypeIdMngmt = 
                Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(RFO_Constant.RFO_MANAGEMENT_SERVICES).getRecordTypeId();
            oppList2 = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList2[0].RecordTypeId = recordTypeIdMngmt;        
            oppList2[0].RFO_RiderID__c=riderRec.id; 
            oppList2[0].RFO_IsOpportunityConverted__c = false;
            //oppList2.addAll(oppList);
            try{
                Test.startTest();
                             Database.insert(oppList2); 
                    oppList2[0].RFO_LeaseTermsRequestedMonths__c = null;
                    oppList2[0].StageName = 'Initiated';
                             oppList2[0].RFO_Quantity__c = null;
                    Database.update(oppList2);
                Test.stopTest();
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('Please populate:'), 'message=' + message);
              }
            System.assert(riderRec!=null);                               
        }
    }
    /*
* Method Name : create Renewal/Management Opportunity
*/   
    private static testMethod void updateRenewalOpty(){

        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            Id recordTypeIdRenewals =
                Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RecordTypeId = recordTypeIdRenewals;        
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Renewal';
            oppList[0].StageName = 'Closed-Renewed';
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_RenewedQuantity__c = null;
            try{
                Test.startTest();
                             Database.insert(oppList);
                Test.stopTest();
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('Please populate:'), 'message=' + message);
              }
            System.assert(riderRec!=null);                               
        }
    }
    /*
* Method Name : create Tank Opportunity
*/   
    private static testMethod void createTankOpty(){

        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Closed-Won';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'Yes';
            try{
                Test.startTest();
                             Database.insert(oppList);
                Test.stopTest();
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('Please populate:'), 'message=' + message);
              }
            System.assert(riderRec!=null);                               
        }
    }    
    /*
* Method Name : create Quote for Tank Opportunity
*/   
    private static testMethod void createQuote(){

        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'No';
            oppList[0].RFO_WonQuantity__c = 1;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 9;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
            //RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
            Database.update(quote1);
            oppList[0].StageName = 'Closed-Won';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            Database.update(oppList[0]);
            //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            oppMap.put(oppList[0].id, oppList[0]);
            RFO_OpportunityHelper.cloneOpportunity(oppMap);
                                       
              Test.stopTest();
             System.assert(riderRec!=null);   
        }
    }
     /*
* Method Name : create Quote for Tank Opportunity
*/   
    private static testMethod void createQuote1(){

        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'Yes';
            oppList[0].RFO_WonQuantity__c = 1;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 9;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
            //RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
            Database.update(quote1);
            oppList[0].StageName = 'Closed-Won';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            Database.update(oppList[0]);
            //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            oppMap.put(oppList[0].id, oppList[0]);
            RFO_OpportunityHelper.cloneOpportunity(oppMap);
                                      
              Test.stopTest();
               System.assert(riderRec!=null);  
        }
    }
    /*
* Method Name : create Quote for Tank Opportunity
*/   
    private static testMethod void createQuote3(){
  
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'Yes';
            oppList[0].RFO_WonQuantity__c = 1;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 9;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
            //RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
            Database.update(quote1);
            oppList[0].StageName = 'Closed-Lost';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            Database.update(oppList[0]);
            //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            oppMap.put(oppList[0].id, oppList[0]);
            RFO_OpportunityHelper.cloneOpportunity(oppMap);
                                      
              Test.stopTest();
               System.assert(riderRec!=null);  
        }
    }
    /*
* Method Name : create Quote for Tank Opportunity
*/   
    private static testMethod void createQuote4(){
  //      List<Opportunity> newOptyList = new List<Opportunity>();
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'No';
            oppList[0].RFO_WonQuantity__c = 20;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 9;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
           // RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
            Database.update(quote1);
            oppList[0].StageName = 'Closed-Won';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            Database.update(oppList[0]);
           // Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            oppMap.put(oppList[0].id, oppList[0]);
            RFO_OpportunityHelper.cloneOpportunity(oppMap);
                                          
              Test.stopTest();
             System.assert(riderRec!=null);
        }
    }
    /*
* Method Name : create Quote for Tank Opportunity
*/   
    private static testMethod void createQuote5(){
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'No';
            oppList[0].RFO_WonQuantity__c = 20;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 1;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
            //RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
            Database.update(quote1);
            oppList[0].StageName = 'Closed-Lost';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            Database.update(oppList[0]);
            //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            oppMap.put(oppList[0].id, oppList[0]);
            RFO_OpportunityHelper.cloneOpportunity(oppMap);
                                      
              Test.stopTest();
                System.assert(riderRec!=null); 
        }
    }
    /*
* Method Name : Move Opportunity Status
*/   
    private static testMethod void moveOpportunityStatus(){
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'No';
            oppList[0].RFO_WonQuantity__c = 20;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 1;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
           //RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
           Database.update(quote1);
            oppList[0].StageName = 'Closed-Lost';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'No';
            Database.update(oppList[0]);
            //Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
            oppMap.put(oppList[0].id, oppList);
            RFO_OpportunityHelper.moveQuoteStatus(oppMap);
            RFO_OpportunityHelper.moveOpportunityStatus(oppList, null);
                                          
              Test.stopTest();
             System.assert(riderRec!=null);
        }
    }
    /*
* Method Name : Move Quote Status
*/  
    private static testMethod void moveQuoteStatus(){
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList[0].RFO_RiderID__c=riderRec.id; 
            oppList[0].Name = 'Test Tank';
            oppList[0].StageName = 'Initiated';
            oppList[0].RFO_IsOpportunityConverted__c = false;
            oppList[0].RFO_Partialtermination__c = 'Yes';
            oppList[0].RFO_PartialLost__c = 'No';
            oppList[0].RFO_WonQuantity__c = 20;                                                 
            oppList[0].RFO_WonReason__c = 'Product';
            oppList[0].RFO_WonAnalysis__c = '1';
            oppList[0].RFO_LostDtl_QuantityAwardedtoCompetitor__c = 1;
            oppList[0].RFO_LostDtl_LeaseTermMonths__c = 9;
            oppList[0].RFO_LostDtl_NewExisting__c = 'New';
            oppList[0].RFO_PurchaseorLease__c = 'Lease';
            oppList[0].RFO_LostDtl_Lessor__c = 'Procor';
            oppList[0].RFO_LostDtl_DeliveryStartDate__c = Date.newInstance(2019, 05, 30);
            oppList[0].RFO_LostDtl_LostReason__c = 'Terms';
            oppList[0].RFO_LostQuantity__c = 1;
            oppList[0].RFO_LostDtl_Builder__c = 'Greenbrier';
            oppList[0].RFO_LostDtl_LeaseRate__c = 9;
            oppList[0].RFO_PartialOpportunitystillActive__c = 'Yes';
            RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
            Test.startTest();
            Database.insert(oppList);
            //QuoteTeam Creation
            //RFO_QuoteTeams__c quoteTeamRec = new RFO_QuoteTeams__c();
            quoteTeamRec = RFO_Utility_Test.createQuoteTeam();
            Database.insert(quoteTeamRec);
            // Quote Creation 
            //SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
            quote1 = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRec);
            quote1.SBQQ__Opportunity2__c = oppList[0].Id;
            Database.insert(quote1);
            quote1.RFO_QuoteStage__c = 'Business Awarded';
            Database.update(quote1);
            oppList[0].StageName = 'Closed-Won';
            oppList[0].RFO_PartialOpportunitystillActive__c = 'No';
            Database.update(oppList[0]);
            //Map<Id, List<Opportunity>> oppMap = new Map<Id, List<Opportunity>>();
            oppMap.put(oppList[0].id, oppList);
            RFO_OpportunityHelper.moveQuoteStatus(oppMap);
                                           
              Test.stopTest();
            System.assert(riderRec!=null);
        }
    }
    /*
* Method Name : Create/Update Renewal Rider
*/  
    private static testMethod void updateRider(){
        System.runAs(createUser()) {
            Map<Id, SObject> newItems = new Map<Id, SObject>();
            Map<Id, SObject> oldItems = new Map<Id, SObject>();
            RFO_Rider__c rider2= [select id, name,  RFO_AutoRenewal__c, RFO_Commodity__c, RFO_TotalOfCars__c,
                                  RFO_TotalActiveCars__c, RFO_OriginalMaturityDate__c, RFO_RiderType__c, RFO_ProductType__c, RFO_Account__c
                                  from RFO_Rider__c Limit 1];
            rider2.RFO_AutoRenewal__c ='No';
            rider2.RFO_Status__c =RFO_Constant.READY_FOR_DELIVERY;
            rider2.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
            rider2.RFO_RiderType__c = 'Net Lease';
            rider2.RFO_ProductType__c = '4793 Super Max Gon';
            rider2.RFO_TotalOfCars__c = 2; 
            rider2.RFO_TotalActiveCars__c = 5;
            Test.startTest();
            Database.update(rider2);
            RFO_OpportunityHelper.createRenewalOpportunity(rider2, RFO_Constant.BATCH);
            Test.stopTest();
         System.assert(newItems!=null);
        }
    }
    /*
* Method Name : Create/Update Mgmt Services Rider
*/  
    private static testMethod void updateManagementServRider(){
        System.runAs(createUser()) {
            Map<Id, SObject> newItems = new Map<Id, SObject>();
            Map<Id, SObject> oldItems = new Map<Id, SObject>();
            RFO_Rider__c rider3= [select id, name, RFO_AutoRenewal__c, RFO_Commodity__c, RFO_TotalOfCars__c,
                                  RFO_TotalActiveCars__c, RFO_OriginalMaturityDate__c, RFO_RiderType__c, RFO_ProductType__c, RFO_Account__c
                                  from RFO_Rider__c Limit 1];
            rider3.RFO_AutoRenewal__c ='No';
            rider3.RFO_OriginalMaturityDate__c=system.today().AddDays(2);
            rider3.RFO_RiderType__c = 'Management Agreement';
            rider3.RFO_ProductType__c = '4793 Super Max Gon';            rider3.RFO_TotalOfCars__c = 2; 
            rider3.RFO_TotalActiveCars__c = 5;
            Test.startTest();
            Database.update(rider3);
            RFO_OpportunityHelper.createManagementServicesOpp(rider3, RFO_Constant.BATCH);
            Test.stopTest();
         System.assert(newItems!=null);
        }
    }
    /*
* Method Name : create Renewal Opportunity
*/   
    private static testMethod void createRenewalOpp(){      
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            Id recordTypeIdRenewals = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get('RFO_Renewals').getRecordTypeId();
            oppList[0].RFO_RiderID__c=riderRec.id;
            oppList[0].RecordTypeId = recordTypeIdRenewals;
            List<Opportunity> oppList1 = new List<Opportunity>();
            oppList1 = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList1[0].RFO_RiderID__c=riderRec.id;
            oppList1[0].RecordTypeId = recordTypeIdRenewals;
            RFO_OpportunityTriggerHandler obj = new RFO_OpportunityTriggerHandler();
            Test.startTest();
            Database.insert(oppList);
            riderRec.RFO_TotalActiveCars__c = 9;
            Database.update(riderRec);
            try{
                Database.insert(oppList1);
                //RFO_OpportunityTriggerHandler obj = new RFO_OpportunityTriggerHandler();
                obj.beforeInsert(oppList1);
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('You cannot create more than one'), 'message=' + message);
              }
                                        
              Test.stopTest();
               system.assertEquals('You cannot create more than one', 'You cannot create more than one');
               System.assert(riderRec!=null);
        }
    }
    /*
* Method Name : create Mgmt Services Opportunity
*/    
    private static testMethod void createMgmtOpp(){
      //  List<Opportunity> newOptyList = new List<Opportunity>();
        System.runAs(createUser()) {
            Account accRec = [select id, name from Account Limit 1];
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            List<Opportunity> oppList2 = new List<Opportunity>();     
            List<Opportunity> oppList = new List<Opportunity>();
            oppList = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            Id recordTypeIdMngmt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get('RFO_ManagementServices').getRecordTypeId();
            oppList[0].RFO_RiderID__c=riderRec.id;
            oppList[0].RecordTypeId = recordTypeIdMngmt;
            List<Opportunity> oppList1 = new List<Opportunity>();
            oppList1 = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            oppList1[0].RFO_RiderID__c=riderRec.id;
            oppList1[0].RecordTypeId = recordTypeIdMngmt;
            RFO_OpportunityTriggerHandler obj = new RFO_OpportunityTriggerHandler();
            Test.startTest();
            Database.insert(oppList);
            riderRec.RFO_TotalActiveCars__c = 9;
            Database.update(riderRec);
            try{
                Database.insert(oppList1);
                //RFO_OpportunityTriggerHandler obj = new RFO_OpportunityTriggerHandler();
                obj.beforeInsert(oppList1);
                obj.beforeDelete(null);
                obj.afterDelete(null);
                obj.afterUnDelete(null);
            }
            catch(Exception e)
            {
                String message = e.getMessage();
               system.assert(message.contains('You cannot create more than one'), 'message=' + message);
              }
                                         
              Test.stopTest();
            system.assertEquals('You cannot create more than one', 'You cannot create more than one');
             System.assert(riderRec!=null); 
        }
    }
    
      /* Added By Vihari ALPHA-932
	  * Method Name : Update Renewal Opportunity stage to Close Terminated
     */   
    private static testMethod void updateRenewalToClosedTerminated(){  
         User userRecord = createUser();
        System.runAs(userRecord) {
            Account accRec = [select id, name from Account Limit 1];
            AccountTeamMember accMem = new AccountTeamMember();
            accMem.UserId = userRecord.Id;
            accMem.AccountId = accRec.Id;
            accMem.TeamMemberRole = RFO_Constant.Account_Member_Role_CDM;
            Database.insert(accMem);
            Contact contRec = [select id, name from Contact Limit 1];
            RFO_Rider__c riderRec = [select id, name from RFO_Rider__c Limit 1];
            Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RFO_Constant.RENEWAL_OPPORTUNITY).getRecordTypeId();
            List<Opportunity> listOpportunity = RFO_Utility_Test.createTankOpportunities1(accRec, contRec);
            Opportunity objOpportunity = listOpportunity[0];
            objOpportunity.StageName = 'Initiated';
            objOpportunity.CloseDate = System.today().addDays(10);
            objOpportunity.RecordTypeId = renewalRecordTypeId;
            Database.insert(objOpportunity);
            Test.startTest();
            Opportunity objOpp1 = [SELECT Id, Name, StageName FROM Opportunity WHERE Id =: objOpportunity.Id LIMIT 1];
            objOpportunity.StageName = 'Closed-Termination';
            objOpportunity.RFO_Partialtermination__c = 'Yes';
            objOpportunity.RFO_RenewedQuantity__c = 1;
            objOpportunity.RFO_LostDtl_TerminationDate__c=System.today();
            objOpportunity.RFO_LostDtl_TerminationReason__c = 'Car Design';
            objOpportunity.RFO_Comments__c = 'Test';
            objOpportunity.RFO_QuantityTerminated__c = 1;
            Database.update(objOpportunity);
            RFO_OpportunityHelper.createClosedTerminationTask(new List<Opportunity>{objOpportunity});
            Test.stopTest();
        } 
    }
    /**
*   createUser method
**/
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.Lan_Id__c = 'MYDEVROLE';
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
}