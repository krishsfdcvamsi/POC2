/**
* @Author      : Accenture
* @Version     : 46.0
* @Description : This class is Change Order line item
**/
@isTest
private class RFO_ChangeOrderEmailController_Test {
      /**
     * changeOrderEmailController_Test-Method
     **/
    private static testmethod void changeOrderEmailController_Test(){
        
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        
        
        Account accRec = new Account();
        accRec.Name = 'testing';
        DataBase.insert(accRec);
        
        order orderTest = new order();
        orderTest.Name = 'testing';
        orderTest.AccountId = accRec.Id;
        orderTest.RFO_Commencement__c = date.today();
        orderTest.RFO_FirstShipWeek__c = date.today();
        orderTest.EffectiveDate = date.today();
        orderTest.Status = 'Draft';
        DataBase.insert(orderTest);
        
        //Adding below records as Asset File master detail to Change Order
        commodityList = RFO_Utility_Test.createCommodity1();
        DataBase.insert(commodityList);
        opportunityList=RFO_Utility_Test.createTankOpportunities(accRec);
        DataBase.insert(opportunityList);
        quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        DataBase.insert(quoteTeamRecord);
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
        cpqQuoteList.RFO_ProposalRefreshStatus__c = 'Resubmit for Pricing';   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = 'Yes';                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        DataBase.insert(cpqQuoteList);
        productRec = RFO_Utility_Test.createProduct();
        DataBase.insert(productRec,false);
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accRec, commodityList[0], productRec);
        DataBase.insert(orderList);
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        DataBase.insert(assetFileList);
        
        //Previous code
        RFO_ChangeOrder__c coTest = new RFO_ChangeOrder__c();
        coTest.Name = 'testing';
        coTest.RFO_ChangeOrderLetter__c = 'T';
        coTest.RFO_ChangeDueto__c = 'Advise cost plus pricing';
        coTest.RFO_OrderID__c=orderTest.id;
        coTest.RFO_AssetFile__c=assetFileList[0].id;
        DataBase.insert(coTest);
        
		
        RFO_ChangeOrderLineItem__c colineItem = new RFO_ChangeOrderLineItem__c();
        colineItem.Name = 'testing';
        colineItem.RFO_ChangeOrderLineItemComments__c = 'testing';
        colineItem.RFO_ChangeOrderID__c = coTest.Id;
        DataBase.insert(colineItem);
        
        RFO_ChangeOrderEmailController cls = new RFO_ChangeOrderEmailController();
        cls.orderId = colineItem.RFO_ChangeOrderID__c;
        test.startTest();
        cls.getchangeorderlineitems();
        test.stopTest();
    }
}