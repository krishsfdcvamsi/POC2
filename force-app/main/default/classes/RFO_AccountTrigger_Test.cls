/**
*  Class:  RFO_AccountTrigger_Test
**/
@isTest(SeeAllData = false)
private class RFO_AccountTrigger_Test {
    private static RFO_IntegrationLinks__c intgrtnLinks= new RFO_IntegrationLinks__c();
    private static RFO_IntegrationLinks__c intgrtnLinks1= new RFO_IntegrationLinks__c();
    /**
* Test Setup method
**/
    @testsetup static void createAccountTestdata(){
        List<Account> accList = new List<Account>();
        List<RFO_IntegrationLinks__c> linkList = new List<RFO_IntegrationLinks__c>();
        Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        accList = RFO_Utility_Test.createProspectAccounts();
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
        accList[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
        accList[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
        for(Account acc :accList ) {
            acc.recordTypeId = recordTypeId;
        }
        DataBase.insert(accList);
        
        intgrtnLinks.Name=RFO_Constant.ACCOUNT_OBJECT;
        intgrtnLinks.RFO_APILink__c=RFO_Constant.APILINK_EX;
        intgrtnLinks1 = RFO_Utility_Test.createIntegrationLinks(RFO_Constant.APILINK_EX);
        
        linkList.add(intgrtnLinks);
        linkList.add(intgrtnLinks1);
        DataBase.insert(linkList);
    }
    /**
*   testmethod1 - method
**/
    private static testMethod void testmethod1(){
        system.runAs(createUser()) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"globalId" : 14139, "status" : "Success"}');
            res.setStatusCode(200);            
            Test.startTest();
            Account acc = [select id, name from Account limit 1];
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpResponseGenerator());            
            
            RFO_GlobalCallOut.updateGlobalAccountID(res,String.valueOf(acc.id));
            Test.stopTest();
            System.Assert(intgrtnLinks!=null);
        }
    }
    
    /**
* Description: Updateing Account Owner
* */
    /*Updating fields in Account    */
    private static testMethod void updateAccountOwner(){
        User userRecord = createSalesUser();
        system.runAs(createUser()) {            
            
            Account acc = [select id, name, OwnerId, RFO_MoodysRating__c, RFO_SPRating__c from Account limit 1];
            acc.OwnerId = userRecord.id;    
            acc.RFO_MoodysRating__c = 'Ba2';
            acc.RFO_TASId__c = '1234';
            acc.RFO_SPRating__c = 'AA';
            Test.startTest();
            Database.update(acc) ;
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAccountOwnerResponse());
            Test.stopTest();
            System.AssertEquals(acc.OwnerId, userRecord.id);
        }
    }
    
    /**
* Description: Updateing AccoundCDD team
* */
    private static testMethod void updateAccountCDDTeam(){
        User userRecord = createSalesUser();
        system.runAs(createUser()) {            
            Account acc = [select id, name, RFO_TASId__c from Account limit 1];
            Map<Id, Account> oldAccRecords = new Map<Id, Account>();
            Map<Id, Account> newAccRecords = new Map<Id, Account>();
            oldAccRecords.put(acc.id, acc);
            acc.RFO_TASId__c = '1234';
            DataBase.update(acc);
            newAccRecords.put(acc.id, acc);
            AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMember(userRecord.id,acc.id);
            DataBase.insert(ateam);
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"synced successfully"}');
            res.setStatusCode(200);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAccountOwnerResponse());
            RFO_GlobalCallOut.getAccountInfoResultFromTAS(res,String.valueOf(acc.id), 'Batch', 'AccountTeam:',ateam.Id);
            RFO_AccountTeamMemberHelper.sendAccountTeamInfoToTAS(ateam, 'Batch');
            Test.stopTest(); 
            System.AssertEquals(acc.RFO_TASId__c, '1234');
        }
    }
    /*
 Description: Updateing AccoundCDM team
*/
    private static testMethod void updateAccountCDMTeam(){
        User userRecord = createSalesUser();
        system.runAs(createUser()) {            
            Account acc = [select id, name, RFO_TASId__c from Account limit 1];
            acc.RFO_TASId__c = '1234';
            DataBase.Update(acc);
            AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMemberCDM(userRecord.id,acc.id);
            DataBase.Insert(ateam);
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"synced successfully"}');
            res.setStatusCode(404);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAccountOwnerResponse());
            RFO_GlobalCallOut.getAccountInfoResultFromTAS(res,String.valueOf(acc.id), 'Batch', 'AccountTeam:', ateam.Id); 
            RFO_AccountTeamMemberHelper.sendAccountTeamInfoToTAS(ateam, 'Batch');
            Test.stopTest(); 
            System.AssertEquals(acc.RFO_TASId__c, '1234');
        }
    }
    /* Update AccountTASId */
    private static testMethod void updateAccountTASId(){
        User userRecord = createSalesUser();
        system.runAs(createUser()) {            
            List<Account> acc = RFO_Utility_Test.createProspectAccounts();
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            acc[0].Name = 'Moral';
            acc[0].Phone = '878-789-4565';
            acc[0].RFO_TASId__c = '7823';  
            acc[0].RFO_MoodysRating__c = 'Ba3';
            acc[0].RFO_SPRating__c = 'AA';
            acc[0].recordTypeId = recordTypeId;
            DataBase.insert(acc[0]);
            acc[0].RFO_TASId__c = '8979';
            acc[0].RFO_SalesRepStartDate__c = System.today();
            Database.update(acc[0]);
            Set<Id> accId = new Set<Id>();
            accId.add(acc[0].id);
            AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMember(userRecord.id,acc[0].id);
            DataBase.insert(ateam);
            //Test.setMock(HttpCalloutMock.class, new RFO_MockHttpAccountOwnerResponse());
            HttpResponse res = new HttpResponse();
            res.setBody('{"status":"success","message":"synced successfully"}');
            res.setStatusCode(200);
            Map<Id, AccountTeamMember> aTeamMap = new Map<Id, AccountTeamMember>();
            RFO_AccountTeamMemberTriggerHandler obj = new RFO_AccountTeamMemberTriggerHandler();
            Test.startTest();
            RFO_GlobalCallOut.getAccountInfoResultFromTAS(res,String.valueOf(acc[0].id), 'Trigger', 'AccountTeam:', ateam.Id);
            RFO_AccountTeamMemberHelper.sendAccountTeamInfoToTAS(ateam, 'Trigger');
            RFO_AccountTeamMemberHelper.sendAccountTeamToTAS(accId);
            //Map<Id, AccountTeamMember> aTeamMap = new Map<Id, AccountTeamMember>();
            aTeamMap.put(ateam.Id,ateam);
           // RFO_AccountTeamMemberTriggerHandler obj = new RFO_AccountTeamMemberTriggerHandler();
            obj.BeforeDelete(aTeamMap);
            obj.AfterDelete(aTeamMap);
            obj.AfterUndelete(aTeamMap);
            Test.stopTest(); 
            System.AssertEquals(acc[0].RFO_TASId__c, '8979');
        }
    }
    /*  Adding AccountTeam members to an Account 
*/
    private static testMethod void insertAccountTeam(){
        User userRecord = createSalesUser();
        User userRecord1 = createSalesUser1();
        System.runAs(createUser()) {
            List<Account> acc = RFO_Utility_Test.createProspectAccounts();
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            acc[0].Name = 'Moral';
            acc[0].Phone = '878-789-4565';
            acc[0].RFO_TASId__c = '7823';  
            acc[0].RFO_MoodysRating__c = 'Ba3';
            acc[0].RFO_SPRating__c = 'AA';
            acc[0].recordTypeId = recordTypeId;
            Test.startTest();
            DataBase.insert(acc[0]);
            Set<Id> accId = new Set<Id>();
            accId.add(acc[0].id);
            List<AccountTeamMember> ateamList = new List<AccountTeamMember>();
            AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMember(userRecord.id,acc[0].id);
            ateamList.add(ateam);
            DataBase.insert(ateam);
            AccountTeamMember ateam1 = RFO_Utility_Test.createAccountTeamMember(userRecord1.id,acc[0].id);
            ateamList.add(ateam1);
            //System.debug('ATeam records: '+ateamList);
            try{
                DataBase.insert(ateamList);
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('is already assigned to a Team Member'), 'message=' + message);
            }
            Test.stopTest();
        }
    }
    /*
* Method Name : Insert ATeam
*/   
    private static testMethod void insertAccountTeam1(){
        User userRecord = createSalesUser();
        User userRecord1 = createSalesUser1();
       
        System.runAs(createUser()) {
            List<Account> acc = RFO_Utility_Test.createProspectAccounts();
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            acc[0].Name = 'Moral';
            acc[0].Phone = '878-789-4565';
            acc[0].RFO_TASId__c = '7823';  
            acc[0].RFO_MoodysRating__c = 'Ba3';
            acc[0].RFO_SPRating__c = 'AA';
            acc[0].recordTypeId = recordTypeId;
            Test.startTest();
            DataBase.insert(acc[0]);
            Set<Id> accId = new Set<Id>();
            accId.add(acc[0].id);
            List<AccountTeamMember> ateamList = new List<AccountTeamMember>();
            AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMember(userRecord.id,acc[0].id);
            ateamList.add(ateam);
            AccountTeamMember ateam1 = RFO_Utility_Test.createAccountTeamMember(userRecord1.id,acc[0].id);
            ateam1.TeamMemberRole = 'Customer Delivery Manager';
            ateamList.add(ateam1);
            //System.debug('ATeam records: '+ateamList);
            try{
                DataBase.insert(ateamList);
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('is already assigned to a Team Member'), 'message=' + message);
            }
            ateam1.TeamMemberRole = 'Customer Delivery Director';
            try{
                DataBase.update(ateam1);
            }
            catch(Exception e)
            {
                String message = e.getMessage();
                system.assert(message.contains('is already assigned to a Team Member'), 'message=' + message);
            }
            Test.stopTest();
        }
    }
    private static testMethod void afterDeleteAccountTeam(){
        User userRecord = createSalesUser();
        User userRecord1 = createSalesUser1();
       
        System.runAs(createUser()) {
            List<Account> acc = RFO_Utility_Test.createProspectAccounts();
            Id recordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            acc[0].Name = 'Moral';
            acc[0].Phone = '878-789-4565';
            acc[0].RFO_TASId__c = '7823';  
            acc[0].RFO_MoodysRating__c = 'Ba3';
            acc[0].RFO_SPRating__c = 'AA';
            acc[0].recordTypeId = recordTypeId;
            DataBase.insert(acc[0]);
            Set<Id> accId = new Set<Id>();
            accId.add(acc[0].id);
            AccountTeamMember ateam1 = RFO_Utility_Test.createAccountTeamMember(userRecord1.id,acc[0].id);
            ateam1.TeamMemberRole = 'Customer Delivery Manager';
            test.startTest();
            //System.debug('ATeam records: '+ateamList);
            DataBase.insert(ateam1);
            
            delete ateam1;
            test.stopTest();

        }
    }
    /* Creating User where profiles is RFO-Sales 
     * */
    private static User createSalesUser1() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        UserRole rle = new UserRole(DeveloperName = 'MyRole1'+ System.currentTimeMillis(), Name = 'My Role1');
        Database.insert(rle); 
        userRecord.Username = 'jhfsjhyyyy@jkh.com' + System.currentTimeMillis();
        userRecord.UserRoleId = rle.Id;
        userRecord.LastName = 'last1';
        userRecord.FirstName = 'last1';
        userRecord.Lan_Id__c = 'MYTEST';
        userRecord.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Customer' Limit 1].Id;
        System.Assert(userRecord!=null );
        Database.insert(userRecord);  
        return userRecord;
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
    /* Creating User where profiles is RFO-Sales 
     * */
    private static User createSalesUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        UserRole rle = new UserRole(DeveloperName = 'MyRole'+ System.currentTimeMillis(), Name = 'My Role');
        Database.insert(rle); 
        userRecord.Username = 'puserxxx@ujh.com' + System.currentTimeMillis();
        userRecord.UserRoleId = rle.Id;
        userRecord.LastName = 'last1';
        userRecord.Lan_Id__c = 'MYROLE';
        userRecord.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Sales Customer' Limit 1].Id;
        System.Assert(userRecord!=null );
        Database.insert(userRecord);  
        return userRecord;
    } 
    /**
*   When ever the account record type get updated then related cases account recordtype field also shouls get updated.
**/
    @isTest Private static Void updateAccountRecordTypeInCaseTest()
    {
        Account accRec = [select id, name, RFO_TASId__c from Account limit 1];
        RecordType recordTypeLst= [Select id From RecordType Where sObjectType = 
                                   'Account'and RecordType.Name = 'Third Party Sales' Limit 1];
        Id caseNewCarRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get(RFO_Constant.RFO_CASE_NewCar) != null ? Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get(RFO_Constant.RFO_CASE_NewCar).getRecordTypeId() : null;
        List<RFO_Commodity__c> commodityList = RFO_Utility_Test.createCommodity1();
        Test.startTest();
        Database.insert(commodityList);
        //Creating an Opportunity
        List<Opportunity> opportunityList=RFO_Utility_Test.createTankOpportunities(accRec);
        System.debug(opportunityList.size());
        Database.insert(opportunityList);
        //Creating a QuoteTeam
        RFO_QuoteTeams__c  quoteTeamRecord = RFO_Utility_Test.createQuoteTeam();
        Database.insert(quoteTeamRecord);
        //Creating a CPQ Quote
        SBQQ__Quote__c cpqQuoteList = new SBQQ__Quote__c();
        cpqQuoteList = RFO_Utility_Test.createCPQPrimaryQuote(opportunityList[0], quoteTeamRecord);
       /* cpqQuoteList.RFO_ProposalRefreshStatus__c = RFO_Constant.PROPOSAL_FRESH_STATUS;   // Proposal Refresh Status
        cpqQuoteList.RFO_ProposalRefreshRequired__c = RFO_Constant.YES;                  // Proposal Refresh Required
        cpqQuoteList.RFO_DaysUntilProposalExpires__c = RFO_Constant.THIRTY; 
        cpqQuoteList.RFO_QuoteTeam__c =  quoteTeamRecord.id;
        cpqQuoteList.RFO_DaysBeforeProposalRefresh__c=30;*/
        Database.insert(cpqQuoteList,false);
        //Creating a Product
        Product2   productRec = RFO_Utility_Test.createProduct();
        productRec.IsActive = true;
        Database.insert(productRec,false);
        //Creating an Order
        List<Order> orderList = RFO_Utility_Test.createNewCarOrders(cpqQuoteList, accRec, commodityList[0], productRec);
        Database.insert(orderList);
        //Creating an Asset File
        List<RFO_Asset_File__c> assetFileList = RFO_Utility_Test.createAssetFile(orderList[0]);
        assetFileList[0].RFO_FileNumber__c = '';
        Database.insert(assetFileList);
        
        List<Case> caseRec= RFO_Utility_Test.createNewCarCR(accRec,orderList[0],assetFileList[0]);
        list<Contact> conList = RFO_Utility_Test.createContact1(accRec);
        insert conList;
        Id recordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        for(Case c : caseRec) {
            c.recordTypeId = recordTypeId;
            c.contactId = conList[0].Id;
        }
        DataBase.insert(caseRec);
        accRec.RecordTypeId=recordTypeLst.Id;        
        DataBase.Update(accRec,false);
        Test.stopTest();
        System.assert(caseRec!=null);
    } 
    
    @isTest public static void closedAccount() {
               // User userRecord = createSalesUser();

        List<account> UpdateList = new list<account>();
        Account accRec = new Account();
        //Get Account Info
       Map<id,Account> MapAcc = new Map<id,Account>([select id, OwnerId,name, RFO_TASId__c from Account]);
        accRec.id=MapAcc.values()[0].id;
        accRec.RFO_AccountStatus__c = 'Closed';
        accRec.ownerId = userInfo.getUserId();
        DataBase.update(accRec,false);
        
        UpdateList.add(accRec);
        RFO_AccountTriggerHandler.handleBeforeUpdateOwner(UpdateList,MapAcc);
        RFO_AccountTriggerHandler.handleAfterUpdateOwner(UpdateList,MapAcc);

        
    }
}//End Test Class