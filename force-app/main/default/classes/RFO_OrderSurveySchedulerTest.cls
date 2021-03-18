@isTest
private class RFO_OrderSurveySchedulerTest {
    @testsetup static void createorderTestdata(){  
        List<Account> accList = new List<Account>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        //Creating an Account
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = '14098';
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        Database.insert(accList);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        Database.insert(opportunityList);
        //Creating a QuoteTeam
        quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRecord);
        
        //Creating a CPQ Quote
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        Database.insert(cpqQuoteList);
        //Creating a Product
        productRec = RFO_Utility_Test.createProduct();
        productRec.IsActive = True;
        Database.insert(productRec,false);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        Database.insert(orderList);
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);
    }
    
    private static testMethod void testOrderSurveyScheduler(){ 
        /* Test starts and stops here */             
        test.startTest();
        RFO_CpqTriggerSwitch.disableCpqTriggers(); 
        Account acclist=[select id from Account Limit 1];
        RFO_Commodity__c commodityList = [select id from RFO_Commodity__c Limit 1];
        Opportunity opportunityList = [Select id from Opportunity Limit 1 ];
        RFO_QuoteTeams__c quoteTeamRecord = [Select id from RFO_QuoteTeams__c Limit 1];
        Product2 productRec =[Select id from Product2 Limit 1];
        SBQQ__Quote__c cpqQuoteList =[Select id from SBQQ__Quote__c Limit 1];
        cpqQuoteList.RFO_Product__c=productRec.id;
        update cpqQuoteList;
        Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook);
        
        /** Creating a QuoteLine with Direct Sale as Transaction Type **/ 
        List<SBQQ__QuoteLine__c> quoteLineDsUpList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quotLine = RFO_Utility_Test.createQuoteLine(cpqQuoteList, productRec);
        quotLine.RFO_DirSaleQty__c = 1;
        quotLine.RFO_TransactionType__c = 'Direct Sale';
        quotLine.RFO_CustSelected__c = True;
        Database.insert(quotLine);
        quotLine.RFO_DirSaleQty__c = 6;
        quotLine.RFO_TransactionType__c = 'Direct Sale';
        quotLine.RFO_CustSelected__c = True;
        
        Database.insert(quoteLineDsUpList); 
        List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList, productRec); 
        for(Order ord : orderList1){
            ord.Type = 'Direct Sale';
            ord.RFO_File__c = 'ABC0002';
            ord.RFO_FirstShipWeek__c = system.today() -41;
        }
        Database.insert(orderList1);    
        RFO_OrderTriggerHelper.updateOrderFields(orderList1);
        Database.insert(quoteLineDsUpList);
        cpqQuoteList.RFO_BusinessAwarded__c= 'Yes';
        cpqQuoteList.SBQQ__Ordered__c = True;
        RFO_CpqTriggerSwitch.disableCpqTriggers();
        List<Contact> conList = [Select Id, RFO_ContactRole__c from Contact];
        for(Contact con : conList){
            con.RFO_ContactRole__c = 'Survey Contact';
            con.email = 'rest@test.com';
        }
        update conList;
        //RFO_OrderSurveyBatch batch = new RFO_OrderSurveyBatch();
        //database.executeBatch(batch);
        RFO_OrderSurveyScheduler sh1 = new RFO_OrderSurveyScheduler();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Send new car order survey', sch, sh1); 
        
        
        test.stopTest();
        system.assertEquals(cpqQuoteList.RFO_BusinessAwarded__c, 'Yes');       
    }
    
    
}