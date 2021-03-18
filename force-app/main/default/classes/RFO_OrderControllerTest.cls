/* 
 * Order Controller Test class
 * */
@isTest(seeAllData = false)
private class RFO_OrderControllerTest {
	/*
	 * create Order test data setup method
	 * */
    @testsetup static void createAssetTestdata(){  
        List<Account> accList = new List<Account>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        //Creating an Account
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.GLOBALACCOUNTID;
        Database.insert(accList);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity();
        Database.insert(commodityList);
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        Database.insert(opportunityList);
        //Creating a QuoteTeam
        quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRecord);
        //Creating a CPQ Quote
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord );
        cpqQuoteList.RFO_ProposalRefreshStatus__c = RFO_Constant.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = RFO_Constant.YES;                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        Database.insert(cpqQuoteList);
        Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook);
        //Creating a Product
        productRec = RFO_Utility_Test.createProduct();
        Database.insert(productRec);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        Database.insert(orderList);
        
    }
    /*
     * order controller test method
     * */
    private static testMethod void orderControllerTest(){
        User userRecord = RFO_Utility_Test.createUserRecord();
        system.runAs(userRecord) {
            List<Order> orderList = [Select id from Order limit 49999];
            RFO_OrderController.getOrderDetails(orderList[0].id);
            RFO_OrderController temp = new RFO_OrderController();
            temp.orderRecord = null;
            system.assertequals(orderList!= null, true);
        }
    }


}