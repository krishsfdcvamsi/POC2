/* 
* Case error message test method. 
 * */
@isTest(SeeAllData = false)
private class RFO_ChangeRequestControllerTest {
	/*
     * Test setup method to create rider data
     * */
    @testsetup static void createTestData(){  
        List<Account> accList = new List<Account>();
        accList = RFO_Utility_Test.createProspectAccounts();
        system.assert(accList.size()>0);
        Database.insert(accList);
        accList[0].RFO_GlobalAccountId__c = RFO_Constant.GLOBALACCOUNTID;
        Database.update(accList[0]);
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = RFO_Utility_Test.createTankOpportunities(accList[0]);                    
        Database.insert(oppList);
        //Creating a QuoteTeam
        RFO_QuoteTeams__c quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        database.insert(quoteTeamRecord);
        
        //Creating a CPQ Quote
        SBQQ__Quote__c  cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(oppList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = RFO_CONSTANT.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = RFO_CONSTANT.YES;                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = RFO_CONSTANT.THIRTY; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        database.insert(cpqQuoteList);
        
        //Commodity creation
        List<RFO_Commodity__c> commList = new List<RFO_Commodity__c>();
        commList = RFO_Utility_Test.createCommodity1();
        Database.insert(commList);
        
        Pricebook2 pbook = new Pricebook2(
            Name = RFO_Constant.PRICEBOOK_NAME,
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook);
        //Product Creation
        Product2 prodObj = new Product2();
        prodObj = RFO_Utility_Test.createProduct();
        Database.insert(prodObj);
        
        // Order Creation
        List<Order> orderList = new List<Order>();
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList,accList[0],commList[0], prodObj );
        //System.debug('orderList'+orderList);
        orderList[0].RFO_Commencement__c = date.today();
        orderList[0].RFO_FirstShipWeek__c = date.today();
        orderList[0].EffectiveDate = date.today();
        orderList[0].Status = RFO_CONSTANT.DRAFT;
        Database.insert(orderList);
        
        // Asset File Creation
        List<RFO_Asset_File__c> assetfileList = new List<RFO_Asset_File__c>();
        assetfileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        Database.insert(assetfileList);
        
        // Change Request Creation
        List<Case> caseList = new List<Case>();
        caseList = RFO_Utility_Test.createNewCarCR(accList[0],orderList[0],assetfileList[0]);
        caseList[0].RFO_ChangeRequestRefreshDate__c = system.today().AddDays(2);
        Database.insert(caseList);
        //System.debug('case'+caseList);      
        
        //Create a ChangeRequestLineItem record
        List<RFO_ChangeRequestLineItem__c> crliList = new List<RFO_ChangeRequestLineItem__c>();
        crliList = RFO_Utility_Test.createNewCarCRLI(caseList[0]); 
        crliList[0].RFO_MaterialsCostExpirationDate__c = system.today();
        crliList[1].RFO_MaterialsCostExpirationDate__c = system.today().AddDays(1);
        Database.insert(crliList);
        
        system.assertEquals(caseList != null,true); 
    }
    /**
* Description: Updating Case Record
* */    
    private static testMethod void caseErrorMessage(){
        system.runAs(createUser()) { 
            Id standardPBId = Test.getStandardPricebookId();
            Case caseRec = [select id, Status from Case limit 1];
            List<RFO_ChangeRequestLineItem__c> cRLIList = [select id, name from RFO_ChangeRequestLineItem__c
                                                 where RFO_ChangeRequestID__c =: caseRec.id limit 2];
            String str = RFO_ChangeRequestController.showWarningMessage(caseRec.id);
            Test.startTest();
            Test.stopTest();
            System.AssertEquals(str, 
                                'Multiple Change Request Line Items has Material Cost Expiration Date which is less than the Change Request Refresh Date.');
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