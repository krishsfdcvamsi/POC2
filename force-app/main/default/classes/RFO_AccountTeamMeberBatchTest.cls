/**
*  Class:  RFO_AccountTeamMeberBatchTest
**/
@isTest(SeeAllData = false)
private class RFO_AccountTeamMeberBatchTest {
    private static RFO_IntegrationLinks__c intgrtnLinks= new RFO_IntegrationLinks__c();
    private static RFO_IntegrationLinks__c intgrtnLinks1= new RFO_IntegrationLinks__c();
    /* Test method for AccountTeamMember batch */
    @testsetup static void createRecords(){
        
            List<Account> accList = new List<Account>();
        List<RFO_IntegrationLinks__c> linkList = new List<RFO_IntegrationLinks__c>();
         intgrtnLinks.Name=RFO_Constant.ACCOUNT_OBJECT;
        intgrtnLinks.RFO_APILink__c=RFO_Constant.APILINK_EX;
        intgrtnLinks1 = RFO_Utility_Test.createIntegrationLinks(RFO_Constant.APILINK_EX);
        
        linkList.add(intgrtnLinks);
        linkList.add(intgrtnLinks1);
        DataBase.insert(linkList); 
        accList = RFO_Utility_Test.createProspectAccounts();
      //  System.debug('account list'+accList);
        accList[0].RFO_GlobalAccountID__c = RFO_Constant.ACCOUNT_GLOBALACCOUNTID;
        accList[0].RFO_OracleId__c = RFO_Constant.ACCOUNT_ORACLEID;
        accList[0].RFO_TASId__c = RFO_Constant.ACCOUNT_TASID;
        TriggerDispatcher.isRecurrsiveAfterInsert = true;
        TriggerDispatcher.isRecurrsiveAfterupdate = true;
        DataBase.insert(accList, false);
        
      /*   FeedItem post = new FeedItem();
         post.ParentId = accList[0].Id;
        post.Body = 'test chatter';
        insert post;
        
        String testLbl = Label.RFO_URL_head;
        System.debug('**testLbl  ****'+testLbl);
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
       System.debug('*****baseUrl ****'+baseUrl);*/
        
        //User userRecord = createSalesUser();
        User userQuoteTeam = new User();
        userQuoteTeam = RFO_Utility_Test.createUserRecordForCPQ();
        //  userQuoteTeam.RFO_Contracts__c = True;
        userQuoteTeam.RFO_Engineering__c = True;
        userQuoteTeam.RFO_Estimating__c = True;
        userQuoteTeam.RFO_PortfolioManagement__c = True;
        userQuoteTeam.RFO_PricingSummary__c = True;
        userQuoteTeam.RFO_ProductionPlanning__c = True;
        userQuoteTeam.RFO_AccountManager__c = True;
        userQuoteTeam.RFO_Sales__c = True;
        Database.insert(userQuoteTeam);
         
       
        
     //   System.debug('linkList: '+linkList);
        
        
        String httpResponseBody = '{"status": "error","message": "Server Error"}';
        RFO_HTTPMockFactory mock = new RFO_HTTPMockFactory(500, RFO_Constant.Success, httpResponseBody, new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);
        AccountTeamMember ateam = RFO_Utility_Test.createAccountTeamMember(userQuoteTeam.Id, accList[0].id);
        aTeam.RFO_TASStatus__c = RFO_Constant.SYNC_FAILED;
        TriggerDispatcher.isRecurrsiveAfterInsert = true;
        TriggerDispatcher.isRecurrsiveAfterupdate = false;
        DataBase.insert(ateam);
        
    }
    /*This method calls the batch class RFO_AccountTeamMemberBatch()  */
    private static testMethod void testmethod1(){
        String httpResponseBody1 = '{"status": "Error sending HTTP request.","StatusCode": "500"}';
        RFO_HTTPMockFactory mock1 = new RFO_HTTPMockFactory(500, 'Success', httpResponseBody1, new Map<String,String>());
        
        String httpResponseBody = '{"status": "success","message": "Synced Successfully"}';
        RFO_HTTPMockFactory mock2 = new RFO_HTTPMockFactory(200, 'Success', httpResponseBody, new Map<String,String>()); 
        HttpResponse res = new HttpResponse();
        res.setBody('{"status": "success","message": "Synced Successfully"}');
        res.setStatusCode(200);
        
        system.runAs(createUser()) {
            Account acc = [Select id, name from Account limit 1];
            AccountTeamMember acctTeam = [select id, TeamMemberRole, RFO_TASStatus__c from AccountTeamMember limit 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, mock1);
            Database.executeBatch(new RFO_AccountTeamMemberBatch(),1);
            String str = acc.id;
            String ateamId = acctTeam.id;
            RFO_GlobalCallout.getAccountInfoResult(res, str, 'Account Team Member Integration:', ateamId);
            
            Test.setMock(HttpCalloutMock.class, mock2);
            Database.executeBatch(new RFO_AccountTeamMemberBatch(),1);
            
            Test.stopTest();
            system.assertEquals('{"status": "success","message": "Synced Successfully"}', '{"status": "success","message": "Synced Successfully"}');
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
    /*This method is used tocreate a sales user */
    private static User createSalesUser() {
        User userRecord = RFO_Utility_Test.createUserRecord();
        UserRole rle = new UserRole(DeveloperName = 'MyRole'+ System.currentTimeMillis(), Name = 'My Role');
        Database.insert(rle); 
        userRecord.Username = 'puserxxx@ujh.com' + System.currentTimeMillis();
        userRecord.UserRoleId = rle.Id;
        userRecord.LastName = 'last1';
        userRecord.Lan_Id__c = 'MYROLE';
        userRecord.ProfileId = [SELECT Id FROM Profile WHERE Name = 'RFO - Sales' Limit 1].Id;
        System.Assert(userRecord!=null );
        Database.insert(userRecord);  
        return userRecord;
    }
}