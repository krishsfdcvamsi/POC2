@isTest(seeAllData = false)
private class RFO_OpportunityWithdrawRerunSchTest {
    
    
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
            
            RFO_OpportunityWithdrawRerunScheduler sh1 = new RFO_OpportunityWithdrawRerunScheduler();
        	String sch = '0 0 2 * * ?'; 
        	system.schedule('Opp Withdraw', sch, sh1); 
            Test.stopTest();
            
        }
    }
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        userRecord.Lan_Id__c = 'MYDEVROLE';
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
}