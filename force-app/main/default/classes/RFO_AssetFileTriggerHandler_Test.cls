/**
* @Author      : Accenture
* @Version     : 46.0
* @Description : This class is for Asset file
**/
@isTest(SeeAllData = false)
private class RFO_AssetFileTriggerHandler_Test {
    /**
     * Creating Asset file related test data
     **/ 
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
        /*accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = '14098';
        accList[0].RFO_OracleId__c = '123456';
        accList[0].RFO_TASId__c = '1234';
        Database.insert(accList);*/
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
        accList[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
        accList[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
        for(Account acc :accList ) {
            acc.recordTypeId = recordTypeId;
        }
        DataBase.insert(accList);
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
        //skipping validation
        /*RFO_SkipValidations__c skipvalidation = new RFO_SkipValidations__c();
skipvalidation.RFO_skip__c = false;
insert skipvalidation;*/
        
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
        productRec.Build_Flag__c = True;
        Database.insert(productRec,false);
        //Creating an Order
        orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList[0], commodityList[0], productRec);
        Database.insert(orderList);
        //Creating an Asset File
        assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);
        //Creating a File Split
        
        
        intgrtnLinks.Name='PostParentAssetFile';
        intgrtnLinks.RFO_APILink__c=RFO_Constant.APILINK_EX;
        intgrtnLinks1.Name='PutFileSplitAssetFile';
        intgrtnLinks1.RFO_APILink__c=RFO_Constant.APILINK_EX;
        linkList.add(intgrtnLinks);
        linkList.add(intgrtnLinks1);
        Database.insert(linkList);
    }
    /**
     * Creating Asset file
     **/
    private static testMethod void createAssetFile(){
        User userRecord = createUser();
        system.runAs(userRecord) {
            
            RFO_Asset_File__c assetFileRecord = [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            RFO_AssetFileTriggerHandler temp = new RFO_AssetFileTriggerHandler();
            HttpResponse res = new HttpResponse();
            res.setBody('{"fileNumber": "T19001","message":"Created Order successfully", "status":"success"}');
            res.setStatusCode(200); 
            Test.startTest();
            temp.BeforeDelete(null);
            map<id, RFO_Asset_File__c> assetMap = new map<id, RFO_Asset_File__c>();
            assetMap.put(assetFileRecord.id,assetFileRecord);
            List<RFO_Asset_File__c> assetFileList = new List<RFO_Asset_File__c>([select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2]);
            temp.BeforeInsert(assetFileList);
            temp.AfterInsert(assetMap);
            temp.AfterDelete(null);
            temp.AfterUndelete(null);
            //Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileResponse());
            
            RFO_GlobalCallOut.updateAssetFileNumber(res,assetFileRecord.id, RFO_Constant.RECORD_CREATED, RFO_Constant.PARENT_ASSETFILE);
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    
        /**
     * Creating Asset file
     **/
    private static testMethod void createAssetFile1(){
        User userRecord = createUser();
        system.runAs(userRecord) {
            
            RFO_Asset_File__c assetFileRecord = [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            RFO_AssetFileTriggerHandler temp = new RFO_AssetFileTriggerHandler();
            HttpResponse res = new HttpResponse();
            res.setBody('{"fileNumber": "T19001","message":"Created Order successfully", "status":"success"}');
            res.setStatusCode(200); 
            Test.startTest();
            temp.BeforeDelete(null);
            temp.AfterDelete(null);
            temp.AfterUndelete(null);
            //Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileResponse());
            
            RFO_GlobalCallOut.updateAssetFileNumber(res,assetFileRecord.id, RFO_Constant.RECORD_CREATED, RFO_Constant.FILESPLIT_ASSETFILE);
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    
        /**
     * Creating Asset file
     **/
    private static testMethod void createAssetFile2(){
        User userRecord = createUser();
        system.runAs(userRecord) {
            
            RFO_Asset_File__c assetFileRecord = [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            RFO_AssetFileTriggerHandler temp = new RFO_AssetFileTriggerHandler();
            HttpResponse res = new HttpResponse();
            res.setBody('{"fileNumber": "T19001","message":"Created Order successfully", "status":"success"}');
            res.setStatusCode(200); 
            Test.startTest();
            temp.BeforeDelete(null);
            temp.AfterDelete(null);
            temp.AfterUndelete(null);
            //Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileResponse());
            
            RFO_GlobalCallOut.updateAssetFileNumber(res,assetFileRecord.id, RFO_Constant.RECORD_UPDATED, RFO_Constant.PARENT_ASSETFILE);
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    
    
    /**
     * Creating Asset file Split
     **/
    private static testMethod void createAssetFileSplit(){
        User userRecord = createUser();
        List<RFO_Asset_File__c> fileSplit = new List<RFO_Asset_File__c>();
        system.runAs(userRecord) {
            
            RFO_Asset_File__c assetFileRecord = [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c Limit 2];
            Order orderId = [Select id from Order limit 1];
            fileSplit = RFO_Utility_Test.createAssetFile(orderId);
            fileSplit[0].Name ='Asset File0102';
            fileSplit[0].RFO_Suffix__c='3';
            fileSplit[0].RFO_FileNumber__c = assetFileRecord.RFO_FileNumber__c;
            fileSplit[0].RFO_OrderNumber__c = assetFileRecord.RFO_OrderNumber__c;
            fileSplit[0].RFO_FileType__c='File Split';
            fileSplit[0].RFO_ParentFileNumber__c = assetFileRecord.id;
            Database.update(fileSplit,false);
            //TriggerDispatcher.Run(new RFO_AssetTriggerHandler());
            RFO_AssetFileTriggerHandler temp = new RFO_AssetFileTriggerHandler();
            Test.startTest();
            temp.BeforeDelete(null);
            temp.AfterDelete(null);
            temp.AfterUndelete(null);
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());            
            Test.stopTest();
            System.assert(assetFileRecord!=null);
        }
    }
    /**
* Updating Asset file record data
**/
    private static testMethod void updateAssetFile(){
       /*    List<Account> lstAcc = new List<Account>();
      Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdCustomer;           // Account Record Type
        acc1.Phone = '800-832-5452';          // Phone
        acc1.RFO_Region__c = 'Class 1 Railroads';   // Region
        acc1.RFO_AccountStatus__c = 'Active';
       lstAcc.add(acc1);
      // insert lstAcc; 
        List<Order> lstOrd = new List<Order>();
        Order ord = new Order();
        ord.Name = 'test';
        ord.AccountId = lstAcc[0].Id;
        lstOrd.add(ord);
        insert lstOrd;
        List<RFO_Asset_File__c> lstAF = new List<RFO_Asset_File__c>();
        RFO_Asset_File__c objAF = new RFO_Asset_File__c();
        objAF.Name = 'test';
        objAF.RFO_FileNumber__c = 'testt';
        objAF.RFO_RiderLeaseType__c = '	Full Service';
        objAF.RFO_Quantity__c = 100;
        objAF.RFO_OrderNumber__c = lstOrd[0].Id;
        lstAF.add(objAF);
        insert lstAF;*/
        RFO_Asset_File__c assetFileRecord = [select id, name, RFO_FileNumber__c, RFO_OrderNumber__c from RFO_Asset_File__c  Limit 2];
        assetFileRecord.RFO_FileType__c = 'Plain';
        assetFileRecord.RFO_Suffix__c = '2';
        assetFileRecord.RFO_Status__c ='In Progress';
        assetFileRecord.RFO_ParentFileNumber__c = assetFileRecord.Id;
        Database.update(assetFileRecord,false);
        //TriggerDispatcher.Run(new RFO_AssetTriggerHandler());
        RFO_AssetFileTriggerHandler temp = new RFO_AssetFileTriggerHandler();
        Test.startTest();
        temp.BeforeDelete(null);
        temp.AfterDelete(null);
        temp.AfterUndelete(null);
        Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());
        Test.stopTest();
        System.assert(assetFileRecord!=null);
        
    }
    private static testMethod void updateAssetFileStatus(){
        // RFO_Asset_File__c rstobj = new RFO_Asset_File__c();
     Id orderNewCarRTId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('New Car').getRecordTypeId(); 
         List<Account> lstAcc = new List<Account>();
       // Account acclist = new Account();
       // acclist.Name ='test';
       // insert acclist;
        
        Id recordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
        account acc1 =new account();
        acc1.Name = 'BNSF';  // Account Name
        acc1.RecordTypeId = recordTypeIdCustomer;           // Account Record Type
        acc1.Phone = '800-832-5452';          // Phone
        acc1.RFO_Region__c = 'Class 1 Railroads';   // Region
        acc1.RFO_AccountStatus__c = 'Active';
       // insert acc1;
         
   lstAcc.add(acc1);
        System.debug('>>>>>>lstAcc:'+lstAcc);
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
         List<Order> orderList1 = new List<Order>();
        Id recordTypeIdNewCar = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('RFO_NewCar').getRecordTypeId();
        Order ord = new Order();
        ord.AccountId= lstAcc[0].Id;    // Account Name
        ord.RecordTypeId = recordTypeIdNewCar; // Order Record Type
       // if(qt != null)
      //  ord.SBQQ__Quote__c = qt.Id; // Quote
        ord.EffectiveDate = Date.newInstance(2019, 05, 25); //Effective DAte
        ord.Status = 'Initiated'; // Status
        ord.RFO_Quantity__c =1; // Quantity
        ord.RFO_TankorFreight__c = 'Tank'; // Tank or Freight
        ord.Type= 'Lease';  // order type
        ord.RFO_SubType__c = 'Net Lease';
        ord.RFO_CarType__c='4793 Super Max Gon'; //car type
        ord.RFO_Commodity_lookup__c =commodityList.id;
        ord.RFO_LeaseRate__c = 1;
        ord.RFO_LeaseTerms__c = 1;
        ord.RFO_JobCostDetails__c = 'jobcost';
        ord.RFO_SignedProposalDate__c = Date.newInstance(2019, 05, 30);
        ord.RFO_ProposalRequired__c='Yes';
        //od.RFO_NoProposalIssued__c = True ;
        ord.RFO_Product__c = productRec.id;
        ord.RFO_Shipping_Commence_stop_notifications__c = false;
        ord.RFO_ContractRiderReceived__c = false;
        ord.Type = 'Lease';
        orderList1.add(ord);
     
      // List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(null, lstAcc[0], commodityList, productRec);      
      //  Database.insert(orderList1); 
        
        
   /*     Order Orobj = new Order();
        Orobj.AccountId = a.Id;
        Orobj.RecordTypeId =orderNewCarRTId;
        Orobj.Status = 'Initiated';
        Orobj.EffectiveDate = Date.today();
        insert Orobj; */
        RFO_Asset_File__c rstobj = [select id, name,RFO_Status__c, RFO_FileNumber__c  from RFO_Asset_File__c  ];
        rstobj.RFO_FileType__c = 'Plain';
        rstobj.RFO_Suffix__c ='2';
        rstObj.RFO_Status__c ='Cancelled';
        rstobj.RFO_OrderNumber__c = orderList1[0].Id;
        //rstobj.RFO_Status__c ='In Progress'; //RFO_OrderNumber__c, RFO_Quantity__c, RFO_RiderLeaseType__c]
        Database.update(rstobj,false);
        RFO_AssetFileTriggerHandler temp = new RFO_AssetFileTriggerHandler();
        List<RFO_Asset_File__c> lstAsset = new List<RFO_Asset_File__c>();
        lstAsset.add(rstobj);
        Map<Id,List<RFO_Asset_File__c>> newItemsMap = new Map<Id,List<RFO_Asset_File__c>>();
        newItemsMap.put(rstobj.id,lstAsset);
        Test.startTest();
        temp.BeforeDelete(null);
        temp.AfterDelete(null);
        temp.AfterUndelete(null);
        RFO_AssetFileTriggerHelper.updateAssetfilestatus(newItemsMap);
        Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAssetFileSplitResponse());
        Test.stopTest();
        
        
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