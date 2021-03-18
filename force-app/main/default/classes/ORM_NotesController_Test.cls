@isTest(seeAllData = false)
public class ORM_NotesController_Test{

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
        
    
    private static testMethod void updateRider(){
        
        
        
        System.runAs(createUser()) { 
            Id RecordTypeIdCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RFO_Customer').getRecordTypeId();
            Account ac = new Account();
            ac.Name = 'Test Account 1';
            ac.RecordTypeId = RecordTypeIdCustomer;           // Account Record Type
            ac.Phone = '800-832-5452';          // Phone
            ac.RFO_Region__c = 'Class 1 Railroads';   // Region
            ac.RFO_AccountStatus__c = 'Active';
            insert ac;
            contact con = new contact();
            con = RFO_TestDataSetup_Factory.contactRecord1(ac.Id);
            
            test.startTest();
       RFO_CpqTriggerSwitch.disableCpqTriggers(); 
        Account acclist=[select id from Account Limit 1];
        List<RFO_Commodity__c> commodityList = new List<RFO_Commodity__c>();
        commodityList = RFO_Utility_Test.createCommodity1();
        Database.insert(commodityList);
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
       List<Order> orderList1 = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accList, commodityList[0], productRec);      
        Database.insert(orderList1);    
            
            
            
            
            ORM_NotesController.getORMData(orderList1[0].Id,'Internal ORM');
            
            ORM__c orm = new ORM__c();
            orm.Order__c = orderList1[0].Id;
            orm.World_Petroleum_Corp_Contacts__c = con.email;
            orm.Trinity_Rail_Users__c = userInfo.getUserId();
            orm.Type__c = 'Internal ORM';
            orm.Revised_By__c = userInfo.getUserId();
            orm.Portfolio_Management__c = userInfo.getUserId();
            insert orm;
            
            Action_Item__c  at = new Action_Item__c ();
            at.ORM_Note__c = orm.Id;
            at.Description__c = 'test';
            at.Responsible_Party__c = userInfo.getUserId();
            insert at;
            
            task t = new task();
            t.status ='Not Started';
            t.OwnerId = userInfo.getUserId();
            t.Subject = 'Test';
            t.WhatId = orm.Id;
            insert t;
            
            ORM_NotesController.getORMData(orderList1[0].Id,'Internal ORM');
            ORM_NotesController.OrmWrapper ormData = new ORM_NotesController.OrmWrapper();
            ormData.orm = orm;
            ormData.actionItemList = new list<Action_Item__c>{at};
                ormData.ORMTasks = new list<task>{t};
            ORM_NotesController.updateORM(JSON.serialize(ormData,true),true);
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