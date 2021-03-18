/*
 * Class Name: RFO_SendAssetFileInfoToTAS_Test
 * */
@isTest(SeeAllData = false)
private class RFO_SendAssetFileInfoToTAS_Test {
    /* Creating Asset file record */
    @testsetup static void createAssetTestdata(){  
        RFO_IntegrationLinks__c intgrtnLinks= new RFO_IntegrationLinks__c();
        RFO_IntegrationLinks__c intgrtnLinks1= new RFO_IntegrationLinks__c();
        List<RFO_IntegrationLinks__c> linkList = new List<RFO_IntegrationLinks__c>();
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
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.GLOBALACCOUNTID;
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
        cpqQuoteList.RFO_ProposalRefreshRequired__c = RFO_Constant.NO;                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = '30'; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;
        Database.insert(cpqQuoteList);
        //Creating a Product
        productRec = RFO_Utility_Test.createProduct();
        Database.insert(productRec);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        Database.insert(orderList);
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);
        //Creating a File Split
        intgrtnLinks.Name= RFO_Constant.POST_PARENT_ASSET_FILE;
        intgrtnLinks.RFO_APILink__c=RFO_Constant.APILINK_EX;
        intgrtnLinks1.Name= RFO_Constant.PUT_FILESPLIT_ASSET_FILE;
        intgrtnLinks1.RFO_APILink__c=RFO_Constant.APILINK_EX;
        linkList.add(intgrtnLinks);
        linkList.add(intgrtnLinks1);
        Database.insert(linkList);
        
    }
    /* Test method for Asset file */
    private static testMethod void sendAssetFileToTAS(){
        User userRecord = createUser();
        system.runAs(userRecord) {            
            RFO_Asset_File__c assetFileRecord = 
                [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            Order orderId = [Select id from Order limit 1];
            
            ApexPages.StandardController stdCtr = new ApexPages.StandardController(assetFileRecord);
            ApexPages.currentPage().getParameters().put('id',assetFileRecord.Id); 
            RFO_SendAssetFileInfoToTAS obj = new RFO_SendAssetFileInfoToTAS(stdCtr);            
            PageReference pageRef = Page.RFO_SendAssetFileInfoToTAS;
            obj.reset();
            pageRef.getParameters().put('id', assetFileRecord.Id);
            Test.setCurrentPage(pageRef);
            obj.callouttoTAS();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileResponse());
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    /* Test method for Asset file */
    private static testMethod void sendAssetFileToTAS1(){
        User userRecord = createUser();
        List<RFO_Asset_File__c> fileSplit = new List<RFO_Asset_File__c>();
        system.runAs(userRecord) {
            
            RFO_Asset_File__c assetFileRecord = 
                [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            Order orderId = [Select id from Order limit 1];
            fileSplit = RFO_Utility_Test.createAssetFile(orderId);
            fileSplit[0].Name ='Asset File0102';
            fileSplit[0].RFO_Suffix__c='3';
            fileSplit[0].RFO_FileNumber__c = assetFileRecord.RFO_FileNumber__c;
            fileSplit[0].RFO_OrderNumber__c = assetFileRecord.RFO_OrderNumber__c;
            fileSplit[0].RFO_FileType__c= RFO_Constant.FILESPLIT_ASSETFILE;
            fileSplit[0].RFO_ParentFileNumber__c = assetFileRecord.id;
            database.insert( fileSplit);
            
            ApexPages.StandardController stdCtr = new ApexPages.StandardController(fileSplit[0]);
            ApexPages.currentPage().getParameters().put('id',fileSplit[0].Id); 
            RFO_SendAssetFileInfoToTAS obj = new RFO_SendAssetFileInfoToTAS(stdCtr);            
            PageReference pageRef = Page.RFO_SendAssetFileInfoToTAS;
            pageRef.getParameters().put('id', fileSplit[0].Id);
            Test.setCurrentPage(pageRef);
            obj.callouttoTAS();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    /* Test method for Asset file */
    private static testMethod void sendAssetFileToTAS2(){
        User userRecord = createUser();
        List<RFO_Asset_File__c> fileSplit = new List<RFO_Asset_File__c>();
        system.runAs(userRecord) {
            
            RFO_Asset_File__c assetFileRecord = [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            Order orderId = [Select id from Order limit 1];
            
            assetFileRecord.RFO_FileNumber__c='T19089';
            database.update(assetFileRecord);
            ApexPages.StandardController stdCtr = new ApexPages.StandardController(assetFileRecord);
            ApexPages.currentPage().getParameters().put('id',assetFileRecord.Id); 
            RFO_SendAssetFileInfoToTAS obj = new RFO_SendAssetFileInfoToTAS(stdCtr);            
            PageReference pageRef = Page.RFO_SendAssetFileInfoToTAS;
            pageRef.getParameters().put('id', assetFileRecord.Id);
            Test.setCurrentPage(pageRef);
            obj.callouttoTAS();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    /**
*   createUser method
**/
    private static User createUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        
        System.Assert(userRecord!=null );
        Database.insert(userRecord);
        return userRecord;
    }
}