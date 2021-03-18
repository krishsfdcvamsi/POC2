/**
* @Author      : Accenture
* @Version     : 46.0
* @Created Date: 23rd July 2019
* @Description :This is test class for RFO_AssetTrigger.
**/
@isTest(SeeAllData = false)
private class RFO_AssetTriggerTest {
    /**
     * Creating Asset test Data
     **/
    @testsetup static void createAssetTestdata(){  
        List<Account> accList = new List<Account>();
        List<Asset> assetList = new List<Asset>();
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        RFO_QuoteTeams__c quoteTeamRecord = new RFO_QuoteTeams__c();
        List<Order> orderList = new List<Order>();
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        Product2 productRec = new Product2();
        List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>();
        //Creating an Account
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c ='14098';
        Database.insert(accList);
        //Creating a Commodity
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
        //Creating an Opportunity
        opportunityList=RFO_Utility_Test.createTankOpportunities(accList[0]);
        opportunityList[0].Requirement_Status__c = 'test';// Added By Vihari EPSI-691
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
        productRec.IsActive = True; //Added By Haseeb, Only Active products can be added to an Order
        Database.insert(productRec,false);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        orderList[0].RFO_FirstShipWeek__c = System.today();
        Database.insert(orderList); 
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        Database.insert(assetFileList) ;
        //Creating an Asset
        assetList = RFO_Utility_Test.createAssetRecord(accList[0].id);
        Database.insert(assetList) ;
        
        
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdAccount;           // Account Record Type
        acc1.Phone = '800-832-5452';   
        acc1.ownerid = userInfo.getUserId();            
        insert acc1;
        
        //Create Commodity
        RFO_Commodity__c commodity = new RFO_Commodity__c();
        commodity.Name = 'TESTCOMMODITY';
        commodity.RFO_Active__c = True;
        insert commodity;
        
        //Create Product
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.IsActive = True;
        insert p;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true,
            Name = 'Standard Price Book'
        );
        
        /* Added by Vihari - ALPHA-530 */
        PricebookEntry pbe = new PricebookEntry(pricebook2id=standardPricebook.id, product2id=productRec.id,unitprice=2.0, isActive=true);
     	insert pbe;
        /* End ALPHA-530*/
        
        update standardPricebook;
                    
        order o = new order();
        o.RecordTypeId = Schema.SObjectType.order.getrecordtypeinfosbydevelopername().get('RFO_NewCar').getRecordTypeId();
        o.AccountId = acc1.id;
        o.Type = 'Lease';
        o.Status = 'Initiated';
        o.RFO_ProposalRequired__c = 'Yes';
        o.RFO_SignedProposalDate__c = system.today();
        o.RFO_TankorFreight__c = 'Tank';
        o.EffectiveDate = system.today();
        o.RFO_JobCostDetails__c = 'Test';
        o.RFO_CarType__c = '200# CI';
        o.RFO_LeaseRate__c = 1;
        o.RFO_LeaseTerms__c = 1;
        o.RFO_Commodity_lookup__c = commodity.Id;
        o.RFO_Product__c = p.Id;
        o.RFO_Quantity__c = 1;
        o.RFO_SubType__c = 'Full Service';
        o.RFO_OrderReviewMeetingDate__c = system.today();
        insert o;
        
        order o1 = new order();
        o1.RecordTypeId = Schema.SObjectType.order.getrecordtypeinfosbydevelopername().get('RFO_ExistingCar').getRecordTypeId();
        o1.AccountId = acc1.id;
        o1.Type = 'Lease';
        o1.Status = 'Initiated';
        o1.RFO_ProposalRequired__c = 'Yes';
        o1.RFO_SignedProposalDate__c = system.today();
        o1.RFO_TankorFreight__c = 'Tank';
        o1.EffectiveDate = system.today();
        o1.RFO_JobCostDetails__c = 'Test';
        o1.RFO_CarType__c = '200# C2';
        o1.RFO_LeaseRate__c = 1;
        o1.RFO_LeaseTerms__c = 1;
        o1.RFO_Commodity_lookup__c = commodity.Id;
        o1.RFO_Product__c = p.Id;
        o1.RFO_Quantity__c = 1;
        o1.RFO_SubType__c = 'Full Service';
        o1.RFO_OrderReviewMeetingDate__c = system.today();
        insert o1;
        
    }
    
    /**
*   Method : Updating order Item record
**/
    private static testMethod void updateorderitem(){
        User userRecord = createUser();
        system.runAs(userRecord) {
            Asset assetRecord = [select id, name, RFO_File__c from Asset Limit 1];
            //TriggerDispatcher.Run(new RFO_AssetTriggerHandler());
            RFO_AssetTriggerHandler temp = new RFO_AssetTriggerHandler();
            
           // temp.AfterUpdate(null,null);
            temp.BeforeUpdate(null,null);
            temp.BeforeDelete(null);
            temp.AfterDelete(null);
            temp.AfterUndelete(null);
            Test.startTest();
            
            System.assert(assetRecord!=null);
            
            account acc1 = [SELECT Id,ownerId FROM Account WHERE name = 'BNSF'];
            order newOrder = [SELECT Id FROM Order WHERE RecordType.DeveloperName = 'RFO_NewCar' AND RFO_CarType__c = '200# CI' LIMIT 1];
            order existingOrder = [SELECT Id FROM Order WHERE RecordType.DeveloperName = 'RFO_ExistingCar' AND RFO_CarType__c = '200# C2'];
            
            List<Asset> assetList = new List<Asset>();
            assetList.addAll(RFO_Utility_Test.createAssetRecord(acc1.id));
            assetList.addAll(RFO_Utility_Test.createAssetRecord(acc1.id));
            assetList[0].RFO_FileOrder__c = newOrder.id;
            assetList[0].Status = 'Assigned';
            assetList[1].RFO_BeginChargeDate__c = system.today().addDays(10);
            assetList[1].RFO_FileOrder__c = existingOrder.id;
            Database.insert(assetList) ;
            Test.stopTest();
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
    /*********************************************************************************
     * MethodName: testUMLEREscalation
     * Created By: Haseeb
     * Created Date: 11/2/2020
     * Jira: Alpha-678
     *********************************************************************************/
    static testMethod void testUMLEREscalation(){
        order o = [Select id, RFO_FirstShipWeek__c from order limit 1];
        RFO_Asset_File__c assetFile = [select id,RFO_OrderNumber__c from RFO_Asset_File__c limit 1];
        Asset a = [Select id,RFO_AssetFile__c from asset limit 1];
        assetFile.RFO_OrderNumber__c = o.Id;
        a.RFO_AssetFile__c = assetFile.Id;
        
        a.UMLER_Status__c = 'Not Sent';
        //Create Product
        Product2 p = new Product2();
        p.Name = 'Test Product1';
        p.IsActive = True;
        insert p;
        Pricebook2 pbook = new Pricebook2(
            Name = 'Standard Price Book',
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Database.update(pbook); 
        Test.startTest();
        update assetFile;
        TriggerDispatcher.isRecurrsiveAfterUpdate = False;
        update a;
        System.assertEquals(assetFile.Id,[Select id,whatId from task where whatid =: assetFile.Id and recordType.name = 'Escalation' limit 1].whatId);
        Test.stopTest();
        
    }
    
    /* Method to Create Asset Record
     * Added By Vihari 
     * User Story : ALPHA-530 
     */
    private static testMethod void testAfterInsert(){
        List<Account> accList = [Select id from Account];
        List<Order> orderList = [Select id from Order];
        
        List<Asset> assetList = new List<Asset>();
        assetList = RFO_Utility_Test.createAssetRecord(accList[0].id);
        assetList[0].RFO_FileOrder__c=orderList[0].id;
        test.startTest();
        try{
            Database.insert(assetList) ;
        }catch(Exception e){
            
        }
        test.stopTest();
        
        Order o = [Select id, Total_Asset_Count__c from Order where Id =:orderList[0].id];
        System.assertEquals(1, o.Total_Asset_Count__c);
        
        
    }
  
    
    /* Method to Delete Asset Record
     * Added By Vihari 
     * User Story : ALPHA-530 
     */
    private static testMethod void testAfterDelete(){
        List<Account> accList = [Select id from Account];
        List<Order> orderList = [Select id from Order];
        
        List<Asset> assetList = new List<Asset>();
        assetList = RFO_Utility_Test.createAssetRecord(accList[0].id);
        assetList[0].RFO_FileOrder__c=orderList[0].id;
        try{
            Database.insert(assetList) ;
        }catch(Exception e){
            System.debug('');
        }
        
        test.startTest();
        try{
            Database.delete(assetList) ;
        }catch(Exception e){
           System.debug('');
        }
        
        test.stopTest();
        
        Order o = [Select id, Total_Asset_Count__c from Order where Id =:orderList[0].id];
        System.assertEquals(0, o.Total_Asset_Count__c);
        
    }
      /** End By Vihari ALPHA-530*/
}